import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

/// Handles API calls for call logs/usage operations.
///
/// Uses NetworkService which automatically handles Bearer authentication.
class CallLogsApiClient {
  CallLogsApiClient({NetworkService? networkService})
    : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  /// Fetches usage/call logs for the given date range.
  ///
  /// Parameters:
  /// - [deviceAccountId]: DeviceID from the Account/devices response
  /// - [startDate]: Selected start date, sent as yyyy-MM-ddTHH:mm:ss
  /// - [endDate]: Selected end date, sent as yyyy-MM-ddTHH:mm:ss
  ///
  /// Returns raw JSON response string on success.
  /// Throws [NetworkException] on errors.
  Future<String> fetchUsages({
    required int deviceAccountId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (deviceAccountId <= 0) {
      throw Exception('Device account ID unavailable. Please try again.');
    }

    final dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
    final startDateStr = dateFormat.format(startDate);
    final endDateStr = dateFormat.format(endDate);
    final url =
        '${Api.usages}?AccountId=$deviceAccountId&startDate=$startDateStr&endDate=$endDateStr';

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
