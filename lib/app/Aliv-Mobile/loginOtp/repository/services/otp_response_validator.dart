import '../../model/account_info_model.dart';
import '../../model/login_otp_resend_response_model.dart';
import '../../model/login_otp_verify_response_model.dart';
import '../login_otp_exception.dart';

/// Service for validating OTP response data.
///
/// Ensures required fields are present and valid in API responses.
class OtpResponseValidator {
  /// Validates verify OTP response for required fields.
  ///
  /// Throws [LoginOtpException] if ticket is missing or empty.
  void validateVerifyResponse(LoginOtpVerifyResponse response) {
    final ticket = response.ticket?.trim() ?? '';
    if (ticket.isEmpty) {
      throw LoginOtpException(
        type: LoginOtpErrorType.missingTicket,
        serverMessage: _resolveMessage(
          response.reason,
          fallback: 'Ticket missing in OTP verify response',
        ),
      );
    }
  }

  /// Validates resend OTP response for required fields.
  ///
  /// Throws [LoginOtpException] if key is missing or empty.
  void validateResendResponse(LoginOtpResendResponse response) {
    final key = response.key?.trim() ?? '';
    if (key.isEmpty) {
      throw LoginOtpException(
        type: LoginOtpErrorType.missingKey,
        serverMessage: _resolveMessage(
          response.reason,
          fallback: 'Key missing in OTP resend response',
        ),
      );
    }
  }

  /// Validates account info response.
  ///
  /// Currently performs basic validation. Can be extended for specific field checks.
  void validateAccountInfo(AccountInfoModel accountInfo) {
    // Currently no specific validation required
    // Can be extended to check for required fields if needed
  }

  /// Resolves message with fallback.
  ///
  /// Returns the provided message if non-empty, otherwise returns fallback.
  String _resolveMessage(String? message, {required String fallback}) {
    final trimmed = message?.trim() ?? '';
    if (trimmed.isNotEmpty) return trimmed;
    return fallback;
  }
}
