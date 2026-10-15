import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_route_args.dart';

import '../logic/password_recovery_otp_attempts.dart';

/// Transient route-owned challenge. Reopening the same challenge retains its
/// feedback sequence and latest resend token; a new OTP request creates a new one.
class PasswordRecoveryOtpChallenge extends LoginOtpRouteArgs {
  PasswordRecoveryOtpChallenge({
    required super.mfaToken,
    required super.phoneNumber,
    required super.apiPhoneNumber,
  }) : attempts = PasswordRecoveryOtpAttempts(mfaToken: mfaToken);

  final PasswordRecoveryOtpAttempts attempts;
}
