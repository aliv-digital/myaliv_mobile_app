import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'api_paths.dart';
import 'app_http_client.dart';

enum TermsAndConditionsAudience { prepaid, postpaid }

/// Fetches the HTML used by every Terms & Conditions modal directly from the
/// API. Failures return null so the UI can retain its bundled fallback copy.
class TermsAndConditionsRepository {
  TermsAndConditionsRepository({ApiService? apiService})
      : _apiService = apiService ??
            ApiService(requestTimeout: const Duration(seconds: 12));

  static final TermsAndConditionsRepository shared =
      TermsAndConditionsRepository();

  final ApiService _apiService;

  Future<String?> load(TermsAndConditionsAudience audience) async {
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
