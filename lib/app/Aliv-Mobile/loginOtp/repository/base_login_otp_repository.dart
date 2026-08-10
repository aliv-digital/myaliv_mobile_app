import '../model/login_otp_resend_response_model.dart';
import '../model/login_otp_verify_response_model.dart';

/// Abstract base class for login OTP repositories.
abstract class BaseLoginOtpRepository {
  /// Verifies the 6-digit OTP the user entered.
  ///
  /// Returns a [LoginOtpVerifyResponse] carrying the fresh JWT
  /// [TokenSession] on success. Throws [LoginOtpException] on errors.
  Future<LoginOtpVerifyResponse> verifyCode({
    required String phoneNumber,
    required String mfaToken,
    required String otpCode,
  });

  /// Resends a new OTP code to the user's phone.
  ///
  /// Returns [LoginOtpResendResponse] carrying the (possibly rotated)
  /// mfa token on success. Throws [LoginOtpException] on errors.
  Future<LoginOtpResendResponse> resendCode({
    required String phoneNumber,
    required String mfaToken,
  });
}
