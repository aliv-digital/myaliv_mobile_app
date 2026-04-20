import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/models/usage_model.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/repository/services/call_logs_api_client.dart';

/// Repository for call logs/usage data.
///
/// Handles data fetching and parsing from API.
class CallLogsRepository {
  CallLogsRepository({CallLogsApiClient? apiClient})
      : _apiClient = apiClient ?? CallLogsApiClient();

  final CallLogsApiClient _apiClient;

  /// Fetches usage/call logs for the given date range.
  ///
  /// Returns a list of [UsageModel] sorted by date descending.
  Future<List<UsageModel>> fetchUsages({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (kDebugMode) {
      debugPrint('CallLogsRepository: Fetching usages');
    }

    final rawJson = await _apiClient.fetchUsages(
      startDate: startDate,
      endDate: endDate,
    );

    final usages = _parseUsages(rawJson);

    if (kDebugMode) {
      debugPrint('CallLogsRepository: Parsed ${usages.length} usage records');
    }

    return usages;
  }

  /// Parses JSON response into list of UsageModel.
  List<UsageModel> _parseUsages(String rawJson) {
    final decoded = jsonDecode(rawJson);

    if (decoded is List) {
      final usages = decoded
          .map((item) => UsageModel.fromJson(item as Map<String, dynamic>))
          .toList();
      // Sort by date descending (newest first)
      usages.sort((a, b) => b.date.compareTo(a.date));
      return usages;
    }

    return [];
  }
}
