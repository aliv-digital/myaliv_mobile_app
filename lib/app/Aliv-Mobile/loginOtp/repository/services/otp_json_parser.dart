import 'dart:convert';
import 'package:core/core.dart';
import '../../model/account_info_model.dart';
import '../../model/login_otp_resend_response_model.dart';
import '../../model/login_otp_verify_response_model.dart';
import '../login_otp_exception.dart';

/// Service for parsing OTP-related JSON responses.
class OtpJsonParser {
  Map<String, dynamic>? tryDecodeMap(String raw) {
    if (raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Parses verify OTP response JSON into a [TokenSession] wrapper.
  LoginOtpVerifyResponse parseVerifyResponse(String rawJson) {
    final parsedJson = tryDecodeMap(rawJson);
    if (parsedJson == null) {
      throw const LoginOtpException(
        type: LoginOtpErrorType.invalidResponse,
        serverMessage: 'Invalid JSON response from verify OTP',
      );
    }
    try {
      return LoginOtpVerifyResponse(
        session: TokenSession.fromLoginJson(parsedJson),
      );
    } catch (e) {
      throw LoginOtpException(
        type: LoginOtpErrorType.invalidResponse,
        serverMessage: 'Failed to parse verify OTP response',
        debugMessage: e.toString(),
      );
    }
  }

  LoginOtpResendResponse parseResendResponse(String rawJson) {
    final parsedJson = tryDecodeMap(rawJson);
    if (parsedJson == null) {
      throw const LoginOtpException(
        type: LoginOtpErrorType.invalidResponse,
        serverMessage: 'Invalid JSON response from resend OTP',
      );
    }
    try {
      return LoginOtpResendResponse.fromJson(parsedJson);
    } catch (e) {
      throw LoginOtpException(
        type: LoginOtpErrorType.invalidResponse,
        serverMessage: 'Failed to parse resend OTP response',
        debugMessage: e.toString(),
      );
    }
  }

  AccountInfoModel parseAccountInfo(String rawJson) {
    final parsedJson = tryDecodeMap(rawJson);
    if (parsedJson == null) {
      throw const LoginOtpException(
        type: LoginOtpErrorType.invalidResponse,
        serverMessage: 'Invalid JSON response from account info',
      );
    }
    try {
      return AccountInfoModel.fromJson(parsedJson);
    } catch (e) {
      throw LoginOtpException(
        type: LoginOtpErrorType.invalidResponse,
        serverMessage: 'Failed to parse account info response',
        debugMessage: e.toString(),
      );
    }
  }

  String? extractErrorMessage(String responseBody) {
    if (responseBody.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is String && decoded.trim().isNotEmpty) return decoded.trim();
      if (decoded is Map) {
        for (final key in const [
          'message',
          'Message',
          'error',
          'Error',
          'detail',
          'Detail',
          'reason',
          'Reason',
        ]) {
          final value = decoded[key];
          if (value is String && value.trim().isNotEmpty) return value.trim();
        }
      }
    } catch (_) {}
    final trimmed = responseBody.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
