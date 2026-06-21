import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

/// Handles API calls for transactions operations.
///
/// Uses NetworkService which automatically handles Basic Auth from GlobalState.
class TransactionsApiClient {
  TransactionsApiClient({NetworkService? networkService})
      : _networkService = networkService ?? instance<NetworkService>();

  final NetworkService _networkService;

  /// Fetches transactions for the given date range.
  ///
  /// Parameters:
  /// - [startDate]: Start date in ISO 8601 format
  /// - [endDate]: End date in ISO 8601 format
  /// - [accountId]: Device account id (from `id_acc`)
  ///
  /// Returns raw JSON response string on success.
  /// Throws [NetworkException] on errors.
  Future<String> fetchTransactions({
    required DateTime startDate,
    required DateTime endDate,
    required int accountId,
  }) async {
    final startDateStr = startDate.toUtc().toIso8601String();
    final endDateStr = endDate.toUtc().toIso8601String();
    final url =
        '${Api.transactions}?startDate=$startDateStr&endDate=$endDateStr&AccountId=$accountId';

    if (kDebugMode) {
      debugPrint('TransactionsApiClient: Fetching transactions from $url');
    }

    try {
      final response = await _networkService.request<String>(
        url,
        method: HttpMethod.get,
      );

      if (kDebugMode) {
        debugPrint(
            'TransactionsApiClient: Response status=${response.statusCode}');
      }

      if (response.data is String) {
        return response.data!;
      } else {
        return jsonEncode(response.data);
      }
    } on NetworkException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }
}
