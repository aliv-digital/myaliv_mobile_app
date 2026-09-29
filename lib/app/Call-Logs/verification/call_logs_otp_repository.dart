import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_resend_response_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_verify_response_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/base_login_otp_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/login_otp_repository.dart';

import 'call_logs_verification_repository.dart';

/// Reuses the existing OTP verification API while routing resend back through
/// the Call Logs challenge endpoint, which rotates the mfa_token.
class CallLogsOtpRepository implements BaseLoginOtpRepository {
  CallLogsOtpRepository({
    required CallLogsVerificationRepository verificationRepository,
    BaseLoginOtpRepository? verificationDelegate,
  })  : _verificationRepository = verificationRepository,
        _verificationDelegate = verificationDelegate ?? LoginOtpRepository();

  final CallLogsVerificationRepository _verificationRepository;
  final BaseLoginOtpRepository _verificationDelegate;

  @override
  Future<LoginOtpVerifyResponse> verifyCode({
    required String phoneNumber,
    required String mfaToken,
    required String otpCode,
  }) {
    return _verificationDelegate.verifyCode(
      phoneNumber: phoneNumber,
      mfaToken: mfaToken,
      otpCode: otpCode,
    );
  }

  @override
  Future<LoginOtpResendResponse> resendCode({
    required String phoneNumber,
    required String mfaToken,
  }) async {
    final challenge = await _verificationRepository.requestChallenge();
    return LoginOtpResendResponse(mfaToken: challenge.mfaToken);
  }
}
