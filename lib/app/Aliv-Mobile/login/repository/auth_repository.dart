import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import '../model/auth_response_model.dart';

class LoginRepository {
  LoginRepository({NetworkService? networkService})
      : _network = networkService ?? instance<NetworkService>();

  final NetworkService _network;

  /// POST /Auth/login with the new JWT contract:
  ///   body: { Username, Password, Channel }
  /// Response is EITHER `{ access_token, refresh_token, expires_in, ... }`
  /// (direct authenticated session) OR `{ mfa_token }` (2FA challenge).
  ///
  /// Marked `skipAuth`: no bearer header is injected (there is no session
  /// yet), and 401s here are treated as bad credentials, not session
  /// expiry — they must not trigger the refresh-then-hard-logout path.
  Future<LoginResult> login({
    required String username,
    required String password,
  }) async {
    final payload = <String, dynamic>{
      'Username': username,
      'Password': password,
      'Channel': kAuthChannel,
    };

    try {
      final response = await _network.request<dynamic>(
        Api.loginUrl,
        method: HttpMethod.post,
        data: payload,
        options: Options(extra: {'skipAuth': true}),
      );

      final body = _asMap(response.data);
      if (kDebugMode) {
        // First-run debug aid: exact shape of the login body so the MFA
        // parser can be confirmed / adjusted without another build cycle.
        debugPrint('LOGIN RAW BODY: ${jsonEncode(body)}');
      }
      return LoginResponseParser.parse(body);
    } on DioException catch (e) {
      final body = _asMapOrNull(e.response?.data);
      final backendMessage = body == null ? null : _extractMessage(body);
      throw Exception(backendMessage ?? _fallbackFor(e));
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return decoded.map((k, v) => MapEntry(k.toString(), v));
    }
    throw const FormatException('Login response body was not a JSON object');
  }

  Map<String, dynamic>? _asMapOrNull(dynamic data) {
    try {
      return _asMap(data);
    } catch (_) {
      return null;
    }
  }

  String? _extractMessage(Map<String, dynamic> body) {
    final raw = body['Message'] ??
        body['message'] ??
        body['ErrorCodeName'] ??
        body['error'] ??
        body['detail'] ??
        body['Detail'];
    return raw?.toString();
  }

  String _fallbackFor(DioException e) {
    return e.message?.trim().isNotEmpty == true
        ? e.message!
        : 'Login failed. Please try again.';
  }
}
