import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/repository/transactions_repository.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';

import 'transactions_state.dart';

/// Cubit for managing transactions data
class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit({
    required TransactionsRepository repository,
    required DeviceLimitsCubit deviceLimitsCubit,
  })  : _repository = repository,
        _deviceLimitsCubit = deviceLimitsCubit,
        super(const TransactionsState());

  final TransactionsRepository _repository;
  final DeviceLimitsCubit _deviceLimitsCubit;

  /// Fetch transactions for the selected month
  Future<void> fetchTransactions() async {
    if (kDebugMode) {
      debugPrint(
          'TransactionsCubit: Fetching transactions for ${state.currentMonth}');
    }

    final deviceId = _deviceLimitsCubit.state.deviceLimits?.deviceId ?? 0;
    if (deviceId <= 0) {
      emit(state.copyWith(
        status: TransactionsStatus.failure,
        errorMessage: 'Device ID unavailable. Please try again.',
      ));
      return;
    }

    emit(state.copyWith(status: TransactionsStatus.loading, errorMessage: null));

    try {
      final transactions = await _repository.fetchTransactions(
        startDate: state.startDate,
        endDate: state.endDate,
        accountId: deviceId,
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
