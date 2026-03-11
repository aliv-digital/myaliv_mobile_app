import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../../../../core/localStorage/localStorage.dart';
import '../../../../core/networkService/api_paths.dart';
import '../../../../core/networkService/app_http_client.dart';
import '../../../../resources/appConstants.dart';

class LogoutRepository {
  LogoutRepository({ApiService? apiService})
    : _api = apiService ?? ApiService();

  final ApiService _api;

  /// Calls logout endpoint.
  ///
  /// Backend success response can be `{}` (or empty body), so this returns an
  /// empty map for successful 2xx responses when no fields are present.
  Future<dynamic> logout() async {
    // For this API, password in Basic Auth is the current ticket/session key.
    final String? ticket = await LocalStorage.getTicket();
    final String password = ticket?.trim() ?? '';
    if (password.isEmpty) {
      throw Exception('Missing session ticket. Please login again.');
    }

    final credentials = '${AppConstants.userName}:$password';
    final basicAuthToken = base64Encode(utf8.encode(credentials));

    if (kDebugMode) {
      debugPrint('Logout request initiated for user: ${AppConstants.userName}');
    }

    final response = await _api.postJson(
      Api.logOutUrl,
      headers: <String, String>{'Authorization': 'Basic $basicAuthToken'},
    );

    if (kDebugMode) {
      debugPrint(
        'Logout status: ${response.statusCode}, body: ${response.responseJson}',
      );
    }

    final parsedJson = _tryDecodeMap(response.responseJson);

    if (ApiService.isSuccessStatusCode(response.statusCode)) {
      await LocalStorage.clearAll();
      return true;
      
    }
   // Clear local storage on logout failure as well

    throw Exception(
      ApiService.friendlyErrorFromResponse(
            response,
            backendMessage: _extractBackendMessage(parsedJson),
          ) ??
          'Could not logout. Please try again.',
    );
  }

  Map<String, dynamic>? _tryDecodeMap(String raw) {
    if (raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        final mapped = <String, dynamic>{};
        for (final entry in decoded.entries) {
          mapped[entry.key.toString()] = entry.value;
        }
        return mapped;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _extractBackendMessage(Map<String, dynamic>? json) {
    if (json == null) return null;
    final message =
        json['message'] ??
        json['Message'] ??
        json['error'] ??
        json['Error'] ??
        json['detail'] ??
        json['Detail'] ??
        json['reason'] ??
        json['Reason'];
    return message?.toString();
  }
}
