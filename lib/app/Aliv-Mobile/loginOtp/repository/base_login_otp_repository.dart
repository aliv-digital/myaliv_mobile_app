import '../model/login_otp_resend_response_model.dart';
import '../model/login_otp_verify_response_model.dart';

/// Abstract base class for login OTP repositories.
///
/// This interface defines the contract for OTP operations.
/// Implementations can be:
/// - Production repository (API-based)
/// - Mock repository (hardcoded data for testing/development)
/// - Test repository (for unit tests)
abstract class BaseLoginOtpRepository {
  /// Verifies the OTP code entered by the user.
  ///
  /// Returns [LoginOtpVerifyResponse] containing ticket and account ID on success.
  /// Throws [LoginOtpException] on errors.
  Future<LoginOtpVerifyResponse> verifyCode({
    required String phoneNumber,
    required String twoFactorKey,
    required String pinCode,
  });

  /// Resends a new OTP code to the user's phone.
  ///
  /// Returns [LoginOtpResendResponse] containing new key on success.
  /// Throws [LoginOtpException] on errors.
  Future<LoginOtpResendResponse> resendCode({
    required String phoneNumber,
    required String twoFactorKey,
  });
}
