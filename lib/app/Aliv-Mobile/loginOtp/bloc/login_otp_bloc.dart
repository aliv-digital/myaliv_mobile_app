import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:myaliv_mobile_app/core/localStorage/localStorage.dart';
import 'package:core/core.dart';
import '../../../../core/appConfig/app_ui_config_cubit.dart';
import '../../../Home/home/data/home_ui_config.dart';
import '../../account-information/cubit/account_info_cubit.dart';
import '../../account-information/cubit/account_info_state.dart';
import 'login_otp_event.dart';
import 'login_otp_state.dart';
import '../repository/login_otp_repository.dart';

class LoginOtpBloc extends Bloc<LoginOtpEvent, LoginOtpState> {
  static const int _otpLength = 4;
  final LoginOtpRepository repository;
  final AppUiConfigCubit appUiConfigCubit;

  LoginOtpBloc({
    required this.repository,
    required this.appUiConfigCubit,
    String initialTwoFactorKey = '',
    String initialPhoneNumber = '',
    String initialApiPhoneNumber = '',
  }) : super(
         LoginOtpState(
           twoFactorKey: initialTwoFactorKey,
           phoneNumber: initialPhoneNumber,
           apiPhoneNumber: initialApiPhoneNumber,
         ),
       ) {
    on<LoginOtpCodeChanged>((event, emit) {
      emit(
        state.copyWith(
          code: event.code,
          status: LoginOtpStatus.initial,
          errorType: LoginOtpErrorType.none,
          codeFieldError: false,
          errorMessage: null,
        ),
      );
    });

    on<LoginOtpSubmitted>(_onSubmitted);
    on<LoginOtpResendRequested>(_onResendRequested);
    on<PrintStorage>(_printStorage);
  }

  Future<void> _onSubmitted(
    LoginOtpSubmitted event,
    Emitter<LoginOtpState> emit,
  ) async {
    final apiPhoneNumber = state.apiPhoneNumber.trim();
    final twoFactorKey = state.twoFactorKey.trim();
    final enteredCode = state.code.trim();

    if (apiPhoneNumber.isEmpty || twoFactorKey.isEmpty) {
      emit(
        state.copyWith(
          status: LoginOtpStatus.failure,
          errorType: LoginOtpErrorType.missingVerificationContext,
          codeFieldError: false,
          errorMessage: 'Missing verification details. Please login again.',
        ),
      );
      return;
    }

    if (enteredCode.isEmpty) {
      emit(
        state.copyWith(
          status: LoginOtpStatus.failure,
          errorType: LoginOtpErrorType.emptyCode,
          codeFieldError: true,
          errorMessage: 'Please enter the code',
        ),
      );
      return;
    }

    if (enteredCode.length < _otpLength) {
      emit(
        state.copyWith(
          status: LoginOtpStatus.failure,
          errorType: LoginOtpErrorType.incompleteCode,
          codeFieldError: true,
          errorMessage: 'Please enter the full code',
        ),
      );
      return;
    }

    final bool isConnected = await InternetConnection().hasInternetAccess;
    if (isConnected == false) {
      emit(
        state.copyWith(
          status: LoginOtpStatus.failure,
          errorType: LoginOtpErrorType.unknown,
          codeFieldError: false,
          errorMessage: 'No Internet Connection',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: LoginOtpStatus.loading,
        errorType: LoginOtpErrorType.none,
        codeFieldError: false,
        errorMessage: null,
      ),
    );

    try {
      debugPrint("OTP CODE : ${state.code}");
      await repository
          .verifyCode(
            phoneNumber: apiPhoneNumber,
            twoFactorKey: twoFactorKey,
            pinCode: enteredCode,
          )
          .then((response) async {
            debugPrint("Ticket : ${response.ticket}");
            debugPrint("Account id : ${response.accountId}");

            final ticket = response.ticket.toString();
            final accountId = response.accountId.toString();

            // ========== Use AuthManager to save auth first ==========
            // This stores the ticket, which is required for fetchAccountInfo
            final authManager = instance<AuthManager>();
            await authManager.saveAuth(
              username: userName,
              ticket: ticket,
              deviceAccountID: accountId,
              storeTicket: (t) => LocalStorage.storeTicket(ticket: t),
              storeAccountID: (id) =>
                  LocalStorage.storeAccountID(accountID: id),
            );

            // ========== Update NetworkService with new auth headers ==========
            final networkService = instance<NetworkService>();
            networkService.updateAuthHeaders();

            // ========== Fetch account info using AccountInfoCubit ==========
            // Credentials are read automatically from AuthManager
            final accountInfoCubit = instance<AccountInfoCubit>();
            await accountInfoCubit.fetchAccountInfo();

            // Verify account info was fetched successfully
            if (accountInfoCubit.state.status != AccountInfoStatus.success) {
              final errorMsg =
                  accountInfoCubit.state.errorMessage ??
                  'Failed to fetch account information';
              throw Exception(errorMsg);
            }

            final accountInfo = accountInfoCubit.state.accountInfo;
            if (accountInfo == null) {
              throw Exception('Account information is missing');
            }

            // Set UI config for logged-in user
            await _setLoggedInUserUiConfig();

            if (kDebugMode) {
              debugPrint('✅ Login: Auth saved and NetworkService updated');
            }
          });

      await Future.delayed(Duration(milliseconds: 1500));

      emit(
        state.copyWith(
          status: LoginOtpStatus.success,
          errorType: LoginOtpErrorType.none,
          codeFieldError: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      final message = _extractErrorMessage(e);
      final errorType = _mapErrorTypeFromMessage(message);
      if (message.toString() == "Two Factor P I N Invalid") {
        emit(
          state.copyWith(
            status: LoginOtpStatus.failure,
            errorType: errorType,
            codeFieldError: _isCodeInputRelatedError(errorType),
            errorMessage: "Invalid OTP",
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: LoginOtpStatus.failure,
            errorType: errorType,
            codeFieldError: _isCodeInputRelatedError(errorType),
            errorMessage: message,
          ),
        );
      }
    }
  }

  // NOTE: This method is no longer needed as auth is now saved via AuthManager
  // Kept for reference but can be removed in future cleanup
  //
  // Future<void> _saveAccountInfo({required String password}) async {
  //   final accountInfo = await repository.getAccountInfo(
  //     username: userName,
  //     password: password,
  //   );
  //   await LocalStorage.storeAccountInfoMap(accountInfo: accountInfo.toJson());
  //   _setLoggedInUserUiConfig();
  // }

  /// Central config setup after successful OTP verification.
  ///
  /// Gets account info from AccountInfoCubit (HydratedBloc) and sets UI config.
  Future<void> _setLoggedInUserUiConfig() async {
    // Get account info from AccountInfoCubit
    final accountInfoCubit = instance<AccountInfoCubit>();
    final account = accountInfoCubit.state.accountInfo;

    if (account == null) {
      if (kDebugMode) {
        debugPrint('⚠️ No account info available for UI config');
      }
      return;
    }

    final accountType = account.accountType;
    final paymentOption = account.paymentOption;

    if (kDebugMode) {
      debugPrint("Account Type : $accountType");
    }

    appUiConfigCubit.setConfig(
      HomeUiConfig(
        userType: paymentOption == "PrePay"
            ? UserType.prepaid
            : UserType.postpaid,
        hasActivePlan: true,
        isFuturePlan: false,
        openMyLimits: false,
      ),
    );
  }

  // for testing purpose only
  Future<void> _printStorage(
    PrintStorage event,
    Emitter<LoginOtpState> emit,
  ) async {
    // Get account info from AccountInfoCubit (HydratedBloc)
    final accountInfoCubit = instance<AccountInfoCubit>();
    final account = accountInfoCubit.state.accountInfo;
    final ticket = await LocalStorage.getTicket();

    if (account == null) {
      debugPrint("⚠️ No account info available");
      return;
    }

    final email = account.email;
    final deviceAccountID = account.idAcc; // device account id
    final accountStatus = account.accountStatus;
    final accountType = account.accountType;
    final paymentOption = account.paymentOption;
    debugPrint("Email : $email");
    debugPrint("Account Status : $accountStatus");
    debugPrint("Account Type : $accountType");
    debugPrint("Payment Option : $paymentOption");
    debugPrint("Device Account ID : $deviceAccountID");
    debugPrint("Ticket : $ticket"); // works as password
  }

  Future<void> _onResendRequested(
    LoginOtpResendRequested event,
    Emitter<LoginOtpState> emit,
  ) async {
    final apiPhoneNumber = state.apiPhoneNumber.trim();
    final twoFactorKey = state.twoFactorKey.trim();

    if (apiPhoneNumber.isEmpty || twoFactorKey.isEmpty) {
      emit(
        state.copyWith(
          resendStatus: LoginOtpResendStatus.idle,
          errorMessage: 'Missing verification details. Please login again.',
        ),
      );
      return;
    }

    final bool isConnected = await InternetConnection().hasInternetAccess;
    if (isConnected == false) {
      emit(
        state.copyWith(
          resendStatus: LoginOtpResendStatus.idle,
          errorMessage: 'No Internet Connection',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        resendStatus: LoginOtpResendStatus.loading,
        errorMessage: null,
      ),
    );
    try {
      final resendResponse = await repository.resendCode(
        phoneNumber: apiPhoneNumber,
        twoFactorKey: twoFactorKey,
      );
      final updatedKey = resendResponse.key ?? twoFactorKey;
      emit(
        state.copyWith(
          resendStatus: LoginOtpResendStatus.done,
          // Backend may rotate key on resend; keep state in sync.
          twoFactorKey: updatedKey,
          errorMessage: null,
        ),
      );
      // Reset to idle so future status changes do not re-trigger resend success UI.
      emit(
        state.copyWith(
          resendStatus: LoginOtpResendStatus.idle,
          twoFactorKey: updatedKey,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          resendStatus: LoginOtpResendStatus.idle,
          errorMessage: _extractErrorMessage(e),
        ),
      );
    }
  }

  String _extractErrorMessage(Object error) {
    final raw = error.toString();
    const prefix = 'Exception:';
    if (raw.startsWith(prefix)) {
      return raw.substring(prefix.length).trim();
    }
    final trimmed = raw.trim();
    return trimmed.isEmpty
        ? 'OTP verification failed. Please try again.'
        : trimmed;
  }

  LoginOtpErrorType _mapErrorTypeFromMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid') ||
        lower.contains('incorrect') ||
        lower.contains('wrong') ||
        lower.contains('failedusernameorpassword') ||
        lower.contains('pin code') ||
        lower.contains('pincode')) {
      return LoginOtpErrorType.invalidCode;
    }
    return LoginOtpErrorType.unknown;
  }

  bool _isCodeInputRelatedError(LoginOtpErrorType type) {
    return type == LoginOtpErrorType.emptyCode ||
        type == LoginOtpErrorType.incompleteCode ||
        type == LoginOtpErrorType.invalidCode;
  }
}
