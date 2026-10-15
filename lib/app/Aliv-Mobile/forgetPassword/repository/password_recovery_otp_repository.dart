import 'dart:convert';

import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_resend_response_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_verify_response_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/base_login_otp_repository.dart';

import '../logic/password_recovery_otp_attempts.dart';

class PasswordRecoveryInvalidOtpException implements Exception {
  const PasswordRecoveryInvalidOtpException({
    required this.cause,
    required this.feedback,
  });

  final NetworkException cause;
  final PasswordRecoveryOtpFeedback? feedback;

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
      if (!_isIncorrectCode(error)) {
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

  bool _isIncorrectCode(NetworkException error) {
    if (error.statusCode != 400 ||
        error is ServerException ||
        error is SessionExpiredException) {
      return false;
    }
    dynamic body = error.data;
    if (body is String) {
      try {
        body = jsonDecode(body);
      } catch (_) {
        return false;
      }
    }
    // This exact structured pair is confirmed by the recovery endpoint. HTTP
    // status or human-readable text alone is not evidence of an incorrect OTP.
    return body is Map &&
        body['ErrorCode'] == 202 &&
        body['ErrorCodeName'] == 'TwoFactorKeyInvalid';
  }
}
