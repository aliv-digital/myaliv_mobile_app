import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/core/networkService/app_http_client.dart';

class AppSettingsRepository {
  AppSettingsRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService(requestTimeout: const Duration(seconds: 20));

  final ApiService _apiService;

  Future<String?> fetchUrlValue(String endpoint) async {
    try {
      final response = await _apiService.get(endpoint);
      if (!ApiService.isSuccessStatusCode(response.statusCode)) {
        if (kDebugMode) {
          debugPrint(
            'AppSettings[$endpoint] non-2xx ${response.statusCode}: ${response.responseJson}',
          );
        }
        return null;
      }

      final decoded = jsonDecode(response.responseJson);
      if (decoded is! Map<String, dynamic>) {
        if (kDebugMode) {
          debugPrint('AppSettings[$endpoint] decoded not a map: $decoded');
        }
        return null;
      }

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        if (kDebugMode) {
          debugPrint('AppSettings[$endpoint] data not a map: $data');
        }
        return null;
      }

      final value = (data['value'] as String?)?.trim();
      if (value == null || value.isEmpty) {
        if (kDebugMode) debugPrint('AppSettings[$endpoint] value empty');
        return null;
      }

      final uri = Uri.tryParse(value);
      final isNetworkImage =
          uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
      if (!isNetworkImage && kDebugMode) {
        debugPrint('AppSettings[$endpoint] not a network URL: $value');
      }
      return isNetworkImage ? value : null;
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('AppSettings[$endpoint] exception: $e\n$st');
      }
      return null;
    }
  }
}
