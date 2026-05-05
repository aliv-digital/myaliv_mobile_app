import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/core/localStorage/localStorage.dart';
import 'package:myaliv_mobile_app/core/networkService/app_http_client.dart';

class AppSettingsRepository {
  AppSettingsRepository({ApiService? apiService})
      : _apiService = apiService ??
            ApiService(requestTimeout: const Duration(seconds: 20));

  final ApiService _apiService;

  static const _cacheKeyPrefix = 'app_settings_url::';

  /// Cache-first: returns the previously persisted URL immediately if present,
  /// and refreshes the cache in the background so the next launch is current.
  /// First-ever call falls through to the network and persists on success.
  Future<String?> fetchUrlValue(String endpoint) async {
    final cacheKey = '$_cacheKeyPrefix$endpoint';

    final cached = await LocalStorage.getStringValue(key: cacheKey);
    if (cached != null && cached.isNotEmpty) {
      unawaited(_refreshAndStore(endpoint, cacheKey));
      return cached;
    }

    return _refreshAndStore(endpoint, cacheKey);
  }

  Future<String?> _refreshAndStore(String endpoint, String cacheKey) async {
    final value = await _fetch(endpoint);
    if (value != null) {
      await LocalStorage.storeStringValue(key: cacheKey, value: value);
    }
    return value;
  }

  Future<String?> _fetch(String endpoint) async {
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
      if (decoded is! Map<String, dynamic>) return null;

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) return null;

      final value = (data['value'] as String?)?.trim();
      if (value == null || value.isEmpty) return null;

      final uri = Uri.tryParse(value);
      final isNetworkImage =
          uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
      return isNetworkImage ? value : null;
    } catch (e) {
      if (kDebugMode) debugPrint('AppSettings[$endpoint] exception: $e');
      return null;
    }
  }
}
