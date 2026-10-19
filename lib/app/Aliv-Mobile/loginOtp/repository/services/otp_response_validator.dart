import '../../model/account_info_model.dart';
import '../../model/login_otp_resend_response_model.dart';
import '../../model/login_otp_verify_response_model.dart';
import '../login_otp_exception.dart';

/// Service for validating OTP response data.
class OtpResponseValidator {
  void validateVerifyResponse(LoginOtpVerifyResponse response) {
    final access = response.session.accessToken.trim();
    if (access.isEmpty) {
      throw const LoginOtpException(
        type: LoginOtpErrorType.missingTicket,
        serverMessage: 'Access token missing in OTP verify response',
      );
    }
  }

  void validateResendResponse(LoginOtpResendResponse response) {
    final key = response.mfaToken?.trim() ?? '';
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

  void validateAccountInfo(AccountInfoModel accountInfo) {
    // Currently no specific validation required.
  }

  String _resolveMessage(String? message, {required String fallback}) {
    final trimmed = message?.trim() ?? '';
    if (trimmed.isNotEmpty) return trimmed;
    return fallback;
  }
}
