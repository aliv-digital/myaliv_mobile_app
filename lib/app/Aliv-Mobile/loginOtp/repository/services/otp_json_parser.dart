import 'dart:convert';
import '../../model/account_info_model.dart';
import '../../model/login_otp_resend_response_model.dart';
import '../../model/login_otp_verify_response_model.dart';
import '../login_otp_exception.dart';

/// Service for parsing OTP-related JSON responses.
///
/// Handles JSON decoding and model conversion with proper error handling.
class OtpJsonParser {
  /// Attempts to decode a JSON string into a Map.
  ///
  /// Returns null if the string is empty or invalid JSON.
  Map<String, dynamic>? tryDecodeMap(String raw) {
    if (raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Parses verify OTP response JSON.
  ///
  /// Throws [LoginOtpException] if parsing fails.
  LoginOtpVerifyResponse parseVerifyResponse(String rawJson) {
    final parsedJson = tryDecodeMap(rawJson);

    if (parsedJson == null) {
      throw const LoginOtpException(
        type: LoginOtpErrorType.invalidResponse,
        serverMessage: 'Invalid JSON response from verify OTP',
      );
    }

    try {
      return LoginOtpVerifyResponse.fromJson(parsedJson);
    } catch (e) {
      throw LoginOtpException(
        type: LoginOtpErrorType.invalidResponse,
        serverMessage: 'Failed to parse verify OTP response',
        debugMessage: e.toString(),
      );
    }
  }

  /// Parses resend OTP response JSON.
  ///
  /// Throws [LoginOtpException] if parsing fails.
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

  /// Parses account info response JSON.
  ///
  /// Throws [LoginOtpException] if parsing fails.
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

  /// Extracts error message from response body.
  ///
  /// Checks common error message keys in the JSON response.
  String? extractErrorMessage(String responseBody) {
    if (responseBody.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(responseBody);

      // String response
      if (decoded is String && decoded.trim().isNotEmpty) {
        return decoded.trim();
      }

      // Map response - check common error keys
      if (decoded is Map) {
        for (final key in ['message', 'Message', 'error', 'Error', 'detail', 'Detail', 'reason', 'Reason']) {
          final value = decoded[key];
          if (value is String && value.trim().isNotEmpty) {
            return value.trim();
          }
        }
      }
    } catch (_) {
      // Not JSON, return as-is
    }

    final trimmed = responseBody.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
