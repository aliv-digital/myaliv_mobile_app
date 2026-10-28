import 'dart:convert';

import 'package:core/core.dart';

import 'login_otp_exception.dart';

/// Carries a challenge-owned count while preserving the existing error text.
class OtpAttemptFailure implements Exception {
  const OtpAttemptFailure({
    required this.cause,
    required this.incorrectAttempts,
  });

  final Object cause;
  final int incorrectAttempts;

  @override
  String toString() => cause.toString();

  static bool isIncorrectCode(Object error) {
    if (error is NetworkException) {
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
      // Match the endpoint's structured invalid-code response; status or a
      // human-readable message alone must not count network/backend failures.
      return body is Map &&
          body['ErrorCode'] == 202 &&
          body['ErrorCodeName'] == 'TwoFactorKeyInvalid';
    }
    if (error is LoginOtpException) {
      if (error.type == LoginOtpErrorType.invalidOtp) {
        return true;
      }
      if ((error.statusCode != 400 && error.statusCode != 401) ||
          (error.type != LoginOtpErrorType.badResponse &&
              error.type != LoginOtpErrorType.unauthorized)) {
        return false;
      }
      final message = (error.serverMessage ?? '').toLowerCase();
      return message.contains('two factor key invalid') ||
          message.contains('twofactorkeyinvalid') ||
          message == 'invalid otp' ||
          message == 'invalid otp code';
    }
    return false;
  }
}
