import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:core/core.dart';

import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/services/auth_completion_service.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

import '../repository/login_otp_repository.dart';
import 'login_otp_event.dart';
import 'login_otp_state.dart';

class LoginOtpBloc extends Bloc<LoginOtpEvent, LoginOtpState> {
  /// The Kansys JWT API dispatches 6-digit PINs (was 4 under the legacy
  /// two-factor-auth endpoint).
  static const int _otpLength = 6;

  final LoginOtpRepository repository;
  final AppUiConfigCubit appUiConfigCubit;
  final AuthCompletionService authCompletionService;

  LoginOtpBloc({
    required this.repository,
    required this.appUiConfigCubit,
    AuthCompletionService? authCompletionService,
    String initialMfaToken = '',
    String initialPhoneNumber = '',
    String initialApiPhoneNumber = '',
  })  : authCompletionService =
            authCompletionService ?? const AuthCompletionService(),
        super(
          LoginOtpState(
            mfaToken: initialMfaToken,
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
    final mfaToken = state.mfaToken.trim();
    final enteredCode = state.code.trim();

    if (apiPhoneNumber.isEmpty || mfaToken.isEmpty) {
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
      final response = await repository.verifyCode(
        phoneNumber: apiPhoneNumber,
        mfaToken: mfaToken,
        otpCode: enteredCode,
      );

      await authCompletionService.complete(
        session: response.session,
        appUiConfigCubit: appUiConfigCubit,
      );

      await Future.delayed(const Duration(milliseconds: 1500));

      await instance<AnalyticsService>().logLogin();

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
      final normalized = message.toLowerCase();
      final treatAsInvalidCode = normalized.contains('two factor') ||
          normalized.contains('twofactor');
      emit(
        state.copyWith(
          status: LoginOtpStatus.failure,
          errorType: errorType,
          codeFieldError: _isCodeInputRelatedError(errorType),
          errorMessage: treatAsInvalidCode ? 'Invalid OTP' : message,
        ),
      );
    }
  }

  // for testing purpose only
  Future<void> _printStorage(
    PrintStorage event,
    Emitter<LoginOtpState> emit,
  ) async {
    final accountInfoCubit = instance<AccountInfoCubit>();
    final account = accountInfoCubit.state.accountInfo;
    final session = instance<AuthManager>().currentSession;

    if (account == null) {
      debugPrint("⚠️ No account info available");
      return;
    }

    debugPrint("Email : ${account.email}");
    debugPrint("Account Status : ${account.accountStatus}");
    debugPrint("Account Type : ${account.accountType}");
    debugPrint("Payment Option : ${account.paymentOption}");
    debugPrint("Device Account ID : ${account.idAcc}");
    debugPrint("Access token exp : ${session?.accessExpiresAt}");
  }

  Future<void> _onResendRequested(
    LoginOtpResendRequested event,
    Emitter<LoginOtpState> emit,
  ) async {
    final apiPhoneNumber = state.apiPhoneNumber.trim();
    final mfaToken = state.mfaToken.trim();

    if (apiPhoneNumber.isEmpty || mfaToken.isEmpty) {
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
        mfaToken: mfaToken,
      );
      final updatedKey = resendResponse.mfaToken ?? mfaToken;
      emit(
        state.copyWith(
          resendStatus: LoginOtpResendStatus.done,
          mfaToken: updatedKey,
          errorMessage: null,
        ),
      );
      emit(
        state.copyWith(
          resendStatus: LoginOtpResendStatus.idle,
          mfaToken: updatedKey,
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
        lower.contains('two factor') ||
        lower.contains('twofactor') ||
        lower.contains('otp')) {
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
