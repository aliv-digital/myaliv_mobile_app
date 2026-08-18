import 'dart:convert';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import '../login_otp_exception.dart';

/// Handles API calls for login OTP operations.
///
/// Both endpoints are auth-endpoints: they bypass the bearer interceptor
/// via `extra['skipAuth']: true` so a stale/absent session can't reject
/// them, and a 401 here means "bad OTP", not "session expired".
class LoginOtpApiClient {
  LoginOtpApiClient({NetworkService? networkService})
      : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  /// POST /Auth/2fa/verify
  /// Body: { PhoneNumber, mfa_token, otp_code, Channel }
  Future<String> verifyOtp({
    required String phoneNumber,
    required String mfaToken,
    required String otpCode,
  }) async {
    final payload = <String, dynamic>{
      'PhoneNumber': phoneNumber,
      'mfa_token': mfaToken,
      'otp_code': otpCode,
      'Channel': kAuthChannel,
    };

    try {
      final response = await _networkService.request<dynamic>(
        Api.verifyOtpUrl,
        method: HttpMethod.post,
        data: payload,
        options: Options(extra: {'skipAuth': true}),
      );
      return _encodeResponse(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e, 'verify OTP');
    }
  }

  /// POST /Auth/2fa/resend
  /// Body: { PhoneNumber, Key }
  Future<String> resendOtp({
    required String phoneNumber,
    required String mfaToken,
  }) async {
    final payload = <String, dynamic>{
      'PhoneNumber': phoneNumber,
      'mfa_token': mfaToken,
    };

    try {
      final response = await _networkService.request<dynamic>(
        Api.resendOtpUrl,
        method: HttpMethod.post,
        data: payload,
        options: Options(extra: {'skipAuth': true}),
      );
      return _encodeResponse(response.data);
    } on DioException catch (e) {
      throw _mapDioException(e, 'resend OTP');
    }
  }

  /// Dio decodes JSON automatically when `Accept: application/json`; the
  /// existing parser layer still expects a String, so re-encode here to
  /// keep that seam intact without rewriting the parser.
  String _encodeResponse(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }

  LoginOtpException _mapDioException(DioException e, String operation) {
    final statusCode = e.response?.statusCode ?? 0;
    final body = e.response?.data;
    final serverMessage = _extractServerMessage(body);

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return LoginOtpException(
          type: LoginOtpErrorType.timeout,
          statusCode: statusCode,
          serverMessage: serverMessage ?? 'Request timeout',
        );
      case DioExceptionType.connectionError:
        return LoginOtpException(
          type: LoginOtpErrorType.noInternet,
          statusCode: statusCode,
          serverMessage: serverMessage ?? 'No internet connection',
        );
      case DioExceptionType.cancel:
        return LoginOtpException(
          type: LoginOtpErrorType.unknown,
          statusCode: statusCode,
          serverMessage: serverMessage ?? 'Request cancelled',
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        break;
    }

    if (statusCode == 401) {
      return LoginOtpException(
        type: LoginOtpErrorType.unauthorized,
        statusCode: statusCode,
        serverMessage: serverMessage ?? 'Unauthorized',
      );
    }
    if (statusCode >= 500) {
      return LoginOtpException(
        type: LoginOtpErrorType.server,
        statusCode: statusCode,
        serverMessage: serverMessage ?? 'Server error ($operation)',
      );
    }
    if (statusCode >= 400) {
      return LoginOtpException(
        type: LoginOtpErrorType.badResponse,
        statusCode: statusCode,
        serverMessage: serverMessage ?? 'Bad request ($operation)',
      );
    }
    return LoginOtpException(
      type: LoginOtpErrorType.unknown,
      statusCode: statusCode,
      serverMessage: serverMessage ?? 'Unknown error ($operation)',
    );
  }

  String? _extractServerMessage(dynamic body) {
    if (body == null) return null;
    dynamic decoded = body;
    if (body is String) {
      if (body.trim().isEmpty) return null;
      try {
        decoded = jsonDecode(body);
      } catch (_) {
        return body.trim();
      }
    }
    if (decoded is String && decoded.trim().isNotEmpty) {
      return decoded.trim();
    }
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
        'ErrorCodeName',
      ]) {
        final value = decoded[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
    return null;
  }
}
