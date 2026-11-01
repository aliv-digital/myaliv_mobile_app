import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:core/core.dart';

import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/services/auth_completion_service.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

import '../repository/base_login_otp_repository.dart';
import '../repository/login_otp_repository.dart';
import '../repository/otp_attempt_failure.dart';
import 'login_otp_event.dart';
import 'login_otp_state.dart';

/// Which calling flow is driving the OTP screen. The bloc keeps a single
/// code-verification path but has to fire different analytics events
/// depending on whether the user is signing in or recovering a password
/// (recovery OTP success leaves the user unauthenticated — no `login` /
/// `logged_in` property to set — and the matching failure event is
/// `password_reset_failed`, not `login_failure`).
enum AuthFlow { login, passwordRecovery }

class LoginOtpBloc extends Bloc<LoginOtpEvent, LoginOtpState> {
  /// The Kansys JWT API dispatches 6-digit PINs (was 4 under the legacy
  /// two-factor-auth endpoint).
  static const int _otpLength = 6;

  final BaseLoginOtpRepository repository;
  final AppUiConfigCubit appUiConfigCubit;
  final AuthCompletionService authCompletionService;
  final InternetConnection _internetConnection;
  final AnalyticsService _analyticsService;
  final bool preventDuplicateSubmissions;
  final String offlineVerificationMessage;
  final bool resetValidationOnResend;
  final String? incorrectAttemptLimitMessage;
  final AuthFlow authFlow;
  bool _submissionInProgress = false;

  LoginOtpBloc({
    required this.repository,
    required this.appUiConfigCubit,
    AuthCompletionService? authCompletionService,
    InternetConnection? internetConnection,
    AnalyticsService? analyticsService,
    String initialMfaToken = '',
    String initialPhoneNumber = '',
    String initialApiPhoneNumber = '',
    this.preventDuplicateSubmissions = false,
    this.offlineVerificationMessage = 'No Internet Connection',
    this.resetValidationOnResend = false,
    this.incorrectAttemptLimitMessage,
    this.authFlow = AuthFlow.login,
  }) : authCompletionService =
           authCompletionService ?? const AuthCompletionService(),
       _internetConnection = internetConnection ?? InternetConnection(),
       _analyticsService = analyticsService ?? instance<AnalyticsService>(),
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
    if (state.shouldExitOtpFlow ||
        (preventDuplicateSubmissions && _submissionInProgress)) {
      return;
    }

    if (preventDuplicateSubmissions) _submissionInProgress = true;
    try {
      await _submit(event, emit);
    } finally {
      if (preventDuplicateSubmissions) _submissionInProgress = false;
    }
  }

  Future<void> _submit(
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
          errorMessage: 'enter all 6 digits of your verification code',
        ),
      );
      return;
    }

    final bool isConnected = await _internetConnection.hasInternetAccess;
    if (isConnected == false) {
      emit(
        state.copyWith(
          status: LoginOtpStatus.failure,
          errorType: LoginOtpErrorType.unknown,
          codeFieldError: false,
          errorMessage: offlineVerificationMessage,
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
      if (state.mfaToken.trim() != mfaToken) {
        return;
      }

      await authCompletionService.complete(
        session: response.session,
        appUiConfigCubit: appUiConfigCubit,
      );

      await Future.delayed(const Duration(milliseconds: 1500));

      await _analyticsService.logOtpVerified();
      await _analyticsService.logLogin(userId: apiPhoneNumber);
      await _analyticsService.setLoggedIn();
      // Recovery flow fires `password_reset_completed` from the create-
      // password success handler — not here — since OTP verification is
      // only a mid-flow step. The user IS authenticated at this point
      // (backend returns a session on recovery OTP success too), hence
      // `login`+`logged_in` fire on both paths.

      emit(
        state.copyWith(
          status: LoginOtpStatus.success,
          errorType: LoginOtpErrorType.none,
          codeFieldError: false,
          errorMessage: null,
          incorrectAttempts: 0,
        ),
      );
    } catch (e) {
      if (state.mfaToken.trim() != mfaToken) {
        return;
      }
      final message = _extractErrorMessage(e);
      final errorType = _mapErrorTypeFromMessage(message);
      final normalized = message.toLowerCase();
      final treatAsInvalidCode =
          normalized.contains('two factor') || normalized.contains('twofactor');
      final wasIncorrectCode = OtpAttemptFailure.isIncorrectCode(e);
      final incorrectAttempts =
          e is OtpAttemptFailure && e.incorrectAttempts > 0
          ? e.incorrectAttempts
          : state.incorrectAttempts + (wasIncorrectCode ? 1 : 0);

      final otpFailureReason = AnalyticsOtpFailureReason.classify(
        e,
        wasIncorrectCode: wasIncorrectCode,
      );
      if (otpFailureReason != null) {
        await _analyticsService.logOtpFailed(failureReason: otpFailureReason);
      }
      if (authFlow == AuthFlow.login) {
        await _analyticsService.logLoginFailure(
          method: AnalyticsLoginMethod.otp,
          failureReason: AnalyticsLoginFailureReason.classify(
            e,
            wasIncorrectCode: wasIncorrectCode,
          ),
        );
      } else {
        await _analyticsService.logPasswordResetFailed(
          failureReason: AnalyticsPasswordResetFailureReason.classify(
            e,
            wasIncorrectCode: wasIncorrectCode,
          ),
        );
      }

      final failureState = state.copyWith(
        status: LoginOtpStatus.failure,
        errorType: errorType,
        codeFieldError: _isCodeInputRelatedError(errorType),
        errorMessage: treatAsInvalidCode ? 'Invalid OTP' : message,
        incorrectAttempts: incorrectAttempts,
      );
      emit(
        failureState.shouldExitOtpFlow && incorrectAttemptLimitMessage != null
            ? failureState.copyWith(errorMessage: incorrectAttemptLimitMessage)
            : failureState,
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
    if (state.shouldExitOtpFlow) {
      return;
    }
    if (resetValidationOnResend) {
      emit(
        state.copyWith(
          code: event.clearCode ? '' : state.code,
          status: LoginOtpStatus.initial,
          errorType: LoginOtpErrorType.none,
          codeFieldError: false,
          errorMessage: null,
        ),
      );
    } else if (event.clearCode) {
      emit(state.copyWith(code: '', errorMessage: state.errorMessage));
    }
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

    final bool isConnected = await _internetConnection.hasInternetAccess;
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
      await _analyticsService.logOtpRequested();
      final updatedKey = resendResponse.mfaToken ?? mfaToken;
      emit(
        state.copyWith(
          resendStatus: LoginOtpResendStatus.done,
          mfaToken: updatedKey,
          incorrectAttempts: updatedKey != mfaToken
              ? 0
              : state.incorrectAttempts,
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
