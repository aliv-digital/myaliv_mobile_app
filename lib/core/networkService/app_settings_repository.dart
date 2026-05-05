import 'dart:convert';

import 'package:myaliv_mobile_app/core/networkService/app_http_client.dart';

class AppSettingsRepository {
  AppSettingsRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService(requestTimeout: const Duration(seconds: 60));

  final ApiService _apiService;

  Future<String?> fetchUrlValue(String endpoint) async {
    try {
      final response = await _apiService.get(endpoint);
      if (!ApiService.isSuccessStatusCode(response.statusCode)) {
        return null;
      }

      final decoded = jsonDecode(response.responseJson);
      if (decoded is! Map<String, dynamic>) return null;

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) return null;

      final value = (data['value'] as String?)?.trim();
      if (value == null || value.isEmpty) return null;

      final uri = Uri.tryParse(value);
      final isNetworkImage =
          uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
      return isNetworkImage ? value : null;
    } catch (_) {
      return null;
    }
  }
}
