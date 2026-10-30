import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/repository/auto_renew_auth_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/services/auth_completion_service.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_state.dart'
    hide LoginOtpErrorType;
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_resend_response_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_verify_response_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/base_login_otp_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/login_otp_exception.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/login_otp_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/otp_attempt_failure.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/theme/login_otp_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/widgets/otp_bottom_actions.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/widgets/otp_code_fields.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/widgets/otp_header.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';

import 'action_otp_route_args.dart';
import 'action_verified_result.dart';

/// Returns an attempt-bound result; the requesting owner performs the action.
class ActionOtpScreen extends StatefulWidget {
  const ActionOtpScreen({super.key, required this.args});

  final ActionOtpRouteArgs<Object> args;

  @override
  State<ActionOtpScreen> createState() => _ActionOtpScreenState();
}

class _ActionOtpScreenState extends State<ActionOtpScreen> {
  final _codeFieldsKey = GlobalKey<OtpCodeFieldsState>();
  bool _returned = false;

  @override
  void dispose() {
    if (!_returned) {
      widget.args.attempt.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.args.isValid) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Verification expired. Please try again.'),
        ),
      );
    }
    final isChangePassword =
        widget.args.attempt.paymentMethod ==
        ProtectedAccountAction.changePassword;

    return BlocProvider(
      create: (context) => LoginOtpBloc(
        repository: _AuthorizationOtpRepository(
          widget.args.attempt,
          trackChangePasswordAttempts: isChangePassword,
        ),
        appUiConfigCubit: context.read<AppUiConfigCubit>(),
        authCompletionService: _AuthorizationSessionCompletion(
          widget.args.attempt,
        ),
        analyticsService: _NoOpAnalytics(),
        initialMfaToken: widget.args.challenge.mfaToken,
        initialPhoneNumber: widget.args.challenge.apiPhoneNumber,
        initialApiPhoneNumber: widget.args.challenge.apiPhoneNumber,
        preventDuplicateSubmissions: true,
        incorrectAttemptLimitMessage:
            switch (widget.args.attempt.paymentMethod) {
              AutoRenewPaymentMethodType.card =>
                'Too many failed OTP attempts. Please try again',
              AutoRenewPaymentMethodType.postpaidInvoice =>
                'Too many failed OTP attempts. Please try again.',
              _ => null,
            },
        offlineVerificationMessage:
            "We couldn't verify the OTP due to a network error. Please try again later",
      ),
      child: StripedScaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: BlocListener<LoginOtpBloc, LoginOtpState>(
            listenWhen: (previous, current) =>
                previous.status != current.status ||
                previous.resendStatus != current.resendStatus ||
                previous.errorMessage != current.errorMessage,
            listener: (context, state) {
              if (!mounted ||
                  _returned ||
                  !widget.args.attempt.isActive ||
                  ModalRoute.of(context)?.isCurrent != true) {
                return;
              }
              if (state.status == LoginOtpStatus.success) {
                final result = widget.args.attempt.verifiedResult;
                if (result != null) {
                  _returned = true;
                  context.pop(result);
                }
              } else if (state.errorMessage != null) {
                AppToast.show(
                  message: state.errorMessage!,
                  type: ToastType.error,
                );
                if (state.status == LoginOtpStatus.failure &&
                    state.shouldExitOtpFlow) {
                  context.go(AppRoutes.home);
                }
              } else if (state.resendStatus == LoginOtpResendStatus.done) {
                AppToast.show(
                  message: 'Verification code resent successfully.',
                  type: ToastType.success,
                );
              }
            },
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                const SliverToBoxAdapter(child: OtpHeader()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: LoginOtpPaddings.contentHorizontal,
                    child: BlocBuilder<LoginOtpBloc, LoginOtpState>(
                      builder: (context, state) => AbsorbPointer(
                        absorbing:
                            state.status == LoginOtpStatus.loading ||
                            state.resendStatus == LoginOtpResendStatus.loading,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: LoginOtpSizes.contentTopGap),
                            OtpCodeFields(key: _codeFieldsKey),
                            SizedBox(
                              height: LoginOtpSizes.otpToBottomActionsGap,
                            ),
                            OtpBottomActions(
                              clearCodeOnResend: isChangePassword,
                              onResendPressed: isChangePassword
                                  ? () =>
                                        _codeFieldsKey.currentState?.clearCode()
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthorizationSessionCompletion extends AuthCompletionService {
  _AuthorizationSessionCompletion(this.attempt);
  final ActionVerificationAttempt<Object> attempt;

  @override
  Future<void> complete({
    required TokenSession session,
    required AppUiConfigCubit appUiConfigCubit,
  }) => attempt.completeSession(session, appUiConfigCubit);
}

class _AuthorizationOtpRepository implements BaseLoginOtpRepository {
  _AuthorizationOtpRepository(
    this.attempt, {
    this.trackChangePasswordAttempts = false,
  });

  final ActionVerificationAttempt<Object> attempt;
  final bool trackChangePasswordAttempts;
  final BaseLoginOtpRepository _delegate = LoginOtpRepository();
  bool _busy = false;
  int _consecutiveFailures = 0;
  String? _activeMfaToken;

  @override
  Future<LoginOtpVerifyResponse> verifyCode({
    required String phoneNumber,
    required String mfaToken,
    required String otpCode,
  }) async {
    if (_busy || !attempt.isActive) {
      throw const CallLogsVerificationException(
        'Please wait or retry verification.',
      );
    }
    _busy = true;
    try {
      final response = await _delegate.verifyCode(
        phoneNumber: phoneNumber,
        mfaToken: mfaToken,
        otpCode: otpCode,
      );
      if (trackChangePasswordAttempts) {
        _consecutiveFailures = 0;
      }
      return response;
    } catch (e) {
      if (trackChangePasswordAttempts && _isIncorrectCode(e)) {
        final currentChallengeToken = mfaToken.trim();
        if (_activeMfaToken != currentChallengeToken) {
          _activeMfaToken = currentChallengeToken;
          _consecutiveFailures = 0;
        }
        _consecutiveFailures++;
        final cause = _consecutiveFailures >= 6
            ? const LoginOtpException(
                type: LoginOtpErrorType.badResponse,
                statusCode: 400,
                serverMessage:
                    'Too many failed OTP attempts. Please try again.',
              )
            : e;
        throw OtpAttemptFailure(
          cause: cause,
          incorrectAttempts: _consecutiveFailures,
        );
      }
      rethrow;
    } finally {
      _busy = false;
    }
  }

  @override
  Future<LoginOtpResendResponse> resendCode({
    required String phoneNumber,
    required String mfaToken,
  }) async {
    if (_busy || !attempt.isActive) {
      throw const CallLogsVerificationException(
        'Please wait or retry verification.',
      );
    }
    _busy = true;
    try {
      final challenge = await attempt.resendChallenge();
      if (trackChangePasswordAttempts && challenge.mfaToken.trim().isNotEmpty) {
        _activeMfaToken = challenge.mfaToken.trim();
        _consecutiveFailures = 0;
      }
      return LoginOtpResendResponse(mfaToken: challenge.mfaToken);
    } finally {
      _busy = false;
    }
  }

  bool _isIncorrectCode(Object error) {
    if (error is LoginOtpException) {
      if (error.statusCode != 400 && error.statusCode != 401) {
        return false;
      }
      if (error.type == LoginOtpErrorType.noInternet ||
          error.type == LoginOtpErrorType.timeout ||
          error.type == LoginOtpErrorType.server) {
        return false;
      }
      final msg = (error.serverMessage ?? '').toLowerCase();
      if (msg.contains('expired') ||
          msg.contains('too many') ||
          msg.contains('throttl') ||
          msg.contains('timeout')) {
        return false;
      }
      return msg.contains('two factor') ||
          msg.contains('twofactor') ||
          msg.contains('invalid') ||
          msg.contains('wrong');
    }
    if (error is DioException) {
      final statusCode = error.response?.statusCode ?? 0;
      if (statusCode != 400 && statusCode != 401) {
        return false;
      }
      final data = error.response?.data;
      if (data is Map) {
        final code = data['ErrorCode'];
        final name = data['ErrorCodeName']?.toString().toLowerCase();
        if (code == 203 || name == 'twofactorkeyexpired') {
          return false;
        }
        if (code == 202 || name == 'twofactorkeyinvalid') {
          return true;
        }
      }
      final msg = (error.message ?? '').toLowerCase();
      if (msg.contains('expired') || msg.contains('too many')) {
        return false;
      }
      return msg.contains('two factor') ||
          msg.contains('invalid') ||
          msg.contains('wrong');
    }
    final raw = error.toString().toLowerCase();
    if (raw.contains('expired') || raw.contains('too many')) {
      return false;
    }
    return raw.contains('two factor') ||
        raw.contains('twofactor') ||
        raw.contains('invalid') ||
        raw.contains('wrong');
  }
}

class _NoOpAnalytics extends AnalyticsService {
  @override
  Future<void> logLogin() async {}
}
