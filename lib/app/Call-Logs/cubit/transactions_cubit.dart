import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/repository/transactions_repository.dart';

import 'transactions_state.dart';

/// Cubit for managing transactions data
class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit({required TransactionsRepository repository})
      : _repository = repository,
        super(const TransactionsState());

  final TransactionsRepository _repository;

  /// Fetch transactions for the selected month
  Future<void> fetchTransactions() async {
    if (kDebugMode) {
      debugPrint(
          'TransactionsCubit: Fetching transactions for ${state.currentMonth}');
    }

    emit(state.copyWith(status: TransactionsStatus.loading, errorMessage: null));

    try {
      final transactions = await _repository.fetchTransactions(
        startDate: state.startDate,
        endDate: state.endDate,
      );

      emit(state.copyWith(
        status: TransactionsStatus.success,
        transactions: transactions,
      ));

      if (kDebugMode) {
        debugPrint(
            'TransactionsCubit: Loaded ${transactions.length} transactions');
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      if (kDebugMode) {
        debugPrint('TransactionsCubit: Error - $errorMessage');
      }
      emit(state.copyWith(
        status: TransactionsStatus.failure,
        errorMessage: errorMessage,
      ));
    }
  }

  /// Change selected month and fetch new data
  Future<void> selectMonth(DateTime month) async {
    if (kDebugMode) {
      debugPrint('TransactionsCubit: Selecting month $month');
    }

    emit(state.copyWith(selectedMonth: month));
    await fetchTransactions();
  }

  /// Extract user-friendly error message from exception
  String _extractErrorMessage(Object error) {
    final raw = error.toString();
    const prefix = 'Exception:';
    if (raw.startsWith(prefix)) {
      return raw.substring(prefix.length).trim();
    }
    return raw.isEmpty ? 'Failed to fetch transactions. Please try again.' : raw;
  }
}
