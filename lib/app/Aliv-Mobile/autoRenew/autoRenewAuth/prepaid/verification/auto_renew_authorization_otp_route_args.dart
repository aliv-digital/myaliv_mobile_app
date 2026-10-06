import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

import '../repository/auto_renew_auth_prepaid_repository.dart';
import 'auto_renew_authorization_submission.dart';

abstract interface class AutoRenewAuthorizationVerificationAttempt {
  bool get isActive;
  AutoRenewPaymentMethodType get paymentMethod;
  CallLogsVerificationRepository get challengeRepository;
  Future<CallLogsChallenge> resendChallenge();
  Future<void> completeSession(TokenSession session, AppUiConfigCubit config);
  AutoRenewAuthorizationVerifiedResult? get verifiedResult;
  void cancel();
}

class AutoRenewAuthorizationOtpRouteArgs {
  const AutoRenewAuthorizationOtpRouteArgs({
    required this.challenge,
    required this.attempt,
  });

  final CallLogsChallenge challenge;
  final AutoRenewAuthorizationVerificationAttempt attempt;

  bool get isValid =>
      challenge.mfaToken.trim().isNotEmpty &&
      challenge.apiPhoneNumber.trim().isNotEmpty &&
      attempt.isActive;
}
