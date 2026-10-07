import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

import 'action_verified_result.dart';

abstract interface class ActionVerificationAttempt<T extends Object> {
  bool get isActive;
  T get paymentMethod;
  CallLogsVerificationRepository get challengeRepository;
  Future<CallLogsChallenge> resendChallenge();
  Future<void> completeSession(TokenSession session, AppUiConfigCubit config);
  ActionVerifiedResult<T>? get verifiedResult;
  void cancel();
}

class ActionOtpRouteArgs<T extends Object> {
  const ActionOtpRouteArgs({required this.challenge, required this.attempt});

  final CallLogsChallenge challenge;
  final ActionVerificationAttempt<T> attempt;

  bool get isValid =>
      challenge.mfaToken.trim().isNotEmpty &&
      challenge.apiPhoneNumber.trim().isNotEmpty &&
      attempt.isActive;
}
