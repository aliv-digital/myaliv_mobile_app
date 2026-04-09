import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:core/core.dart';
import '../../../../../core/networkService/api_paths.dart';
import '../login_otp_exception.dart';

/// Handles API calls for login OTP operations.
///
/// Responsibilities:
/// - Make authenticated API requests using NetworkService
/// - Map HTTP errors to LoginOtpException
/// - Handle network errors and timeouts
class LoginOtpApiClient {
  LoginOtpApiClient({NetworkService? networkService})
    : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  /// Sends OTP verification request to the server.
  ///
  /// Returns raw JSON response string on success.
  /// Throws [LoginOtpException] on errors.
  Future<String> verifyOtp({
    required String phoneNumber,
    required String twoFactorKey,
    required String pinCode,
  }) async {
    final payload = <String, dynamic>{
      'PhoneNumber': phoneNumber,
      'Key': twoFactorKey,
      'PinCode': pinCode,
    };

    if (kDebugMode) {
      debugPrint(
        'LoginOtpApiClient: Verify OTP request for phone=$phoneNumber',
      );
    }

    // Make API request using NetworkService
    final response = await _networkService.request<String>(
      Api.verifyOtpUrl,
      method: HttpMethod.post,
      data: payload,
    );

    if (kDebugMode) {
      debugPrint('LoginOtpApiClient: Verify OTP status=${response.statusCode}');
    }

    // Validate response
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw _mapErrorToException(
        statusCode: response.statusCode ?? 0,
        responseBody: response.data ?? '',
        operation: 'verify OTP',
      );
    }

    return response.data ?? '';
  }

  /// Sends OTP resend request to the server.
  ///
  /// Returns raw JSON response string on success.
  /// Throws [LoginOtpException] on errors.
  Future<String> resendOtp({
    required String phoneNumber,
    required String twoFactorKey,
  }) async {
    final payload = <String, dynamic>{
      'PhoneNumber': phoneNumber,
      'Key': twoFactorKey,
    };

    if (kDebugMode) {
      debugPrint(
        'LoginOtpApiClient: Resend OTP request for phone=$phoneNumber',
      );
    }

    // Make API request using NetworkService
    final response = await _networkService.request<String>(
      Api.resendOtpUrl,
      method: HttpMethod.post,
      data: payload,
    );

    if (kDebugMode) {
      debugPrint('LoginOtpApiClient: Resend OTP status=${response.statusCode}');
    }

    // Validate response
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw _mapErrorToException(
        statusCode: response.statusCode ?? 0,
        responseBody: response.data ?? '',
        operation: 'resend OTP',
      );
    }

    return response.data ?? '';
  }

  /// Maps HTTP error to typed exception.
  LoginOtpException _mapErrorToException({
    required int statusCode,
    required String responseBody,
    required String operation,
  }) {
    final serverMessage = _extractServerMessage(responseBody);

    // Timeout or no connection
    if (statusCode == 0) {
      if (responseBody.toLowerCase().contains('timeout')) {
        return LoginOtpException(
          type: LoginOtpErrorType.timeout,
          statusCode: statusCode,
          serverMessage: serverMessage ?? 'Request timeout',
        );
      }
      return LoginOtpException(
        type: LoginOtpErrorType.noInternet,
        statusCode: statusCode,
        serverMessage: serverMessage ?? 'No internet connection',
      );
    }

    // Map status codes to error types
    switch (statusCode) {
      case 401:
        return LoginOtpException(
          type: LoginOtpErrorType.unauthorized,
          statusCode: statusCode,
          serverMessage: serverMessage ?? 'Unauthorized',
        );
      case 408:
        return LoginOtpException(
          type: LoginOtpErrorType.timeout,
          statusCode: statusCode,
          serverMessage: serverMessage ?? 'Request timeout',
        );
      default:
        if (statusCode >= 500) {
          return LoginOtpException(
            type: LoginOtpErrorType.server,
            statusCode: statusCode,
            serverMessage: serverMessage ?? 'Server error',
          );
        } else if (statusCode >= 400) {
          return LoginOtpException(
            type: LoginOtpErrorType.badResponse,
            statusCode: statusCode,
            serverMessage: serverMessage ?? 'Bad request',
          );
        }
        return LoginOtpException(
          type: LoginOtpErrorType.unknown,
          statusCode: statusCode,
          serverMessage: serverMessage ?? 'Unknown error',
        );
    }
  }

  /// Extracts error message from response body.
  String? _extractServerMessage(String responseBody) {
    if (responseBody.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(responseBody);

      // String response
      if (decoded is String && decoded.trim().isNotEmpty) {
        return decoded.trim();
      }

      // Map response - check common error keys
      if (decoded is Map) {
        for (final key in [
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
