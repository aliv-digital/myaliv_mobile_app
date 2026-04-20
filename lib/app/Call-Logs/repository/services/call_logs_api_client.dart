import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

/// Handles API calls for call logs/usage operations.
///
/// Uses NetworkService which automatically handles Basic Auth from GlobalState.
class CallLogsApiClient {
  CallLogsApiClient({NetworkService? networkService})
      : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  /// Fetches usage/call logs for the given date range.
  ///
  /// Parameters:
  /// - [startDate]: Start date in ISO 8601 format
  /// - [endDate]: End date in ISO 8601 format
  ///
  /// Returns raw JSON response string on success.
  /// Throws [NetworkException] on errors.
  Future<String> fetchUsages({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startDateStr = startDate.toUtc().toIso8601String();
    final endDateStr = endDate.toUtc().toIso8601String();
    final url = '${Api.usages}?startDate=$startDateStr&endDate=$endDateStr';

    if (kDebugMode) {
      debugPrint('CallLogsApiClient: Fetching usages from $url');
    }

    try {
      final response = await _networkService.request<String>(
        url,
        method: HttpMethod.get,
      );

      if (kDebugMode) {
        debugPrint('CallLogsApiClient: Response status=${response.statusCode}');
      }

      if (response.data is String) {
        return response.data!;
      } else {
        return jsonEncode(response.data);
      }
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to fetch call logs: $e');
    }
  }
}
