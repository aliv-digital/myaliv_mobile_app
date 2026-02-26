// lib/login/login_repository.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/networkService/api_paths.dart';
import '../../../../core/networkService/app_http_client.dart';
import '../model/auth_response_model.dart';

class LoginRepository {
  LoginRepository({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;

  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    final payload = <String, dynamic>{
      'username': username,
      'password': password,
    };

    debugPrint('Login API payload: $payload');

    final response = await _api.postJson(Api.loginUrl, body: payload);

    if (kDebugMode) {
      debugPrint(
        'Login API status: ${response.statusCode}, body: ${response.responseJson}',
      );
    }

    final parsedJson = _tryDecodeMap(response.responseJson);
    final authResponse = AuthResponse.fromJson(parsedJson);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final key = authResponse.twoFactorKey?.trim() ?? '';
      if (key.isEmpty) {
        throw Exception(_resolveMessage(
          authResponse.message,
          fallback: 'TwoFactorKey missing in login response',
        ));
      }
      return authResponse;
    }

    throw Exception(
      _resolveMessage(
        authResponse.message,
        fallback: _networkFallbackMessage(response.statusCode, response.responseJson),
      ),
    );
  }

  Map<String, dynamic>? _tryDecodeMap(String raw) {
    if (raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  String _resolveMessage(String? message, {required String fallback}) {
    final trimmed = message?.trim() ?? '';
    if (trimmed.isNotEmpty) return trimmed;
    return fallback;
  }

  String _networkFallbackMessage(int statusCode, String rawBody) {
    if (statusCode == 0 || statusCode == 408) {
      final trimmed = rawBody.trim();
      return trimmed.isNotEmpty ? trimmed : 'Network request failed';
    }
    return 'Login failed ($statusCode)';
  }
}
