import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/models/transaction_model.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/repository/services/transactions_api_client.dart';

/// Repository for transactions data.
///
/// Handles data fetching and parsing from API.
class TransactionsRepository {
  TransactionsRepository({TransactionsApiClient? apiClient})
      : _apiClient = apiClient ?? TransactionsApiClient();

  final TransactionsApiClient _apiClient;

  /// Fetches transactions for the given date range.
  ///
  /// Returns a list of [TransactionModel] sorted by date descending.
  Future<List<TransactionModel>> fetchTransactions({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (kDebugMode) {
      debugPrint('TransactionsRepository: Fetching transactions');
    }

    final rawJson = await _apiClient.fetchTransactions(
      startDate: startDate,
      endDate: endDate,
    );

    final transactions = _parseTransactions(rawJson);

    if (kDebugMode) {
      debugPrint(
          'TransactionsRepository: Parsed ${transactions.length} transactions');
    }

    return transactions;
  }

  /// Parses JSON response into list of TransactionModel.
  List<TransactionModel> _parseTransactions(String rawJson) {
    final decoded = jsonDecode(rawJson);

    if (decoded is List) {
      final transactions = decoded
          .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
          .toList();
      // Sort by date descending (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));
      return transactions;
    }

    return [];
  }
}
