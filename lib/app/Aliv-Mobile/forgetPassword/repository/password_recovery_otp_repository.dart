import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_resend_response_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_verify_response_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/base_login_otp_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/otp_attempt_failure.dart';

import '../logic/password_recovery_otp_attempts.dart';

class PasswordRecoveryInvalidOtpException implements OtpAttemptFailure {
  const PasswordRecoveryInvalidOtpException({
    required this.cause,
    required this.feedback,
  });

  @override
  final NetworkException cause;
  final PasswordRecoveryOtpFeedback? feedback;

  @override
  int get incorrectAttempts => feedback?.incorrectAttempts ?? 0;

  @override
  String toString() => feedback?.message ?? cause.toString();
}

/// Adapts only recovery verification results; transport and other OTP flows
/// continue to use the existing repository and global error mapping unchanged.
class PasswordRecoveryOtpRepository implements BaseLoginOtpRepository {
  PasswordRecoveryOtpRepository({
    required this.delegate,
    required this.attempts,
  });

  final BaseLoginOtpRepository delegate;
  final PasswordRecoveryOtpAttempts attempts;

  @override
  Future<LoginOtpVerifyResponse> verifyCode({
    required String phoneNumber,
    required String mfaToken,
    required String otpCode,
  }) async {
    try {
      final response = await delegate.verifyCode(
        phoneNumber: phoneNumber,
        mfaToken: mfaToken,
        otpCode: otpCode,
      );
      attempts.verified(mfaToken);
      return response;
    } on NetworkException catch (error) {
      if (!OtpAttemptFailure.isIncorrectCode(error)) {
        rethrow;
      }
      throw PasswordRecoveryInvalidOtpException(
        cause: error,
        feedback: attempts.recordIncorrectCode(mfaToken),
      );
    }
  }

  @override
  Future<LoginOtpResendResponse> resendCode({
    required String phoneNumber,
    required String mfaToken,
  }) async {
    final response = await delegate.resendCode(
      phoneNumber: phoneNumber,
      mfaToken: mfaToken,
    );
    if (response.mfaToken != null) {
      attempts.replaceChallenge(response.mfaToken!);
    }
    return response;
  }
}
