import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../localStorage/localStorage.dart';
import 'api_paths.dart';
import 'app_http_client.dart';

enum TermsAndConditionsAudience { prepaid, postpaid }

/// Loads and caches the HTML used by every Terms & Conditions modal.
///
/// Content is cached separately for prepaid and postpaid users. The first
/// request in a session reads the persisted value, if any, and refreshes it in
/// the background. Without a persisted value it waits for the API. Failures
/// return null so the UI can retain its bundled fallback copy.
class TermsAndConditionsRepository {
  TermsAndConditionsRepository({ApiService? apiService})
      : _apiService = apiService ??
            ApiService(requestTimeout: const Duration(seconds: 12));

  static final TermsAndConditionsRepository shared =
      TermsAndConditionsRepository();

  static const _cacheKeyPrefix = 'terms_and_conditions_html::';

  final ApiService _apiService;
  final Map<TermsAndConditionsAudience, String> _memoryCache = {};
  final Map<TermsAndConditionsAudience, Future<String?>> _inFlight = {};

  Future<String?> load(TermsAndConditionsAudience audience) async {
    final memoryValue = _memoryCache[audience];
    if (memoryValue != null && memoryValue.isNotEmpty) return memoryValue;

    final pendingRequest = _inFlight[audience];
    if (pendingRequest != null) return pendingRequest;

    final request = _loadFirstAvailable(audience);
    _inFlight[audience] = request;

    try {
      return await request;
    } finally {
      _inFlight.remove(audience);
    }
  }

  Future<String?> _loadFirstAvailable(
    TermsAndConditionsAudience audience,
  ) async {
    final cacheKey = '$_cacheKeyPrefix${audience.name}';
    String? persistedValue;
    try {
      persistedValue = await LocalStorage.getStringValue(key: cacheKey);
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          'TermsAndConditionsRepository[$audience] cache read failed: $error',
        );
      }
    }

    if (persistedValue != null && persistedValue.trim().isNotEmpty) {
      final cachedHtml = persistedValue.trim();
      _memoryCache[audience] = cachedHtml;
      unawaited(_refresh(audience, cacheKey));
      return cachedHtml;
    }

    return _refresh(audience, cacheKey);
  }

  Future<String?> _refresh(
    TermsAndConditionsAudience audience,
    String cacheKey,
  ) async {
    try {
      final endpoint = audience == TermsAndConditionsAudience.prepaid
          ? Api.prepaidTermsConditions
          : Api.postPaidTermsConditions;
      final response = await _apiService.get(endpoint);

      if (!ApiService.isSuccessStatusCode(response.statusCode)) return null;

      final decoded = jsonDecode(response.responseJson);
      if (decoded is! Map<String, dynamic> || decoded['success'] != true) {
        return null;
      }

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) return null;

      final html = (data['value'] as String?)?.trim();
      if (html == null || html.isEmpty) return null;

      _memoryCache[audience] = html;
      try {
        await LocalStorage.storeStringValue(key: cacheKey, value: html);
      } catch (error) {
        if (kDebugMode) {
          debugPrint(
            'TermsAndConditionsRepository[$audience] cache write failed: '
            '$error',
          );
        }
      }
      return html;
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          'TermsAndConditionsRepository[$audience] failed: '
          '$error\n$stackTrace',
        );
      }
      return null;
    }
  }
}
