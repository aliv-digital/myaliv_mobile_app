import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/repository/call_logs_repository.dart';

import 'call_logs_state.dart';

/// Cubit for managing call logs/usage data
class CallLogsCubit extends Cubit<CallLogsState> {
  CallLogsCubit({required CallLogsRepository repository})
      : _repository = repository,
        super(const CallLogsState());

  final CallLogsRepository _repository;

  /// Fetch usages for the selected month
  Future<void> fetchUsages() async {
    if (kDebugMode) {
      debugPrint('CallLogsCubit: Fetching usages for ${state.currentMonth}');
    }

    emit(state.copyWith(status: CallLogsStatus.loading, errorMessage: null));

    try {
      final usages = await _repository.fetchUsages(
        startDate: state.startDate,
        endDate: state.endDate,
      );

      emit(state.copyWith(status: CallLogsStatus.success, usages: usages));

      if (kDebugMode) {
        debugPrint('CallLogsCubit: Loaded ${usages.length} usage records');
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      if (kDebugMode) {
        debugPrint('CallLogsCubit: Error - $errorMessage');
      }
      emit(state.copyWith(
        status: CallLogsStatus.failure,
        errorMessage: errorMessage,
      ));
    }
  }

  /// Change selected month and fetch new data
  Future<void> selectMonth(DateTime month) async {
    if (kDebugMode) {
      debugPrint('CallLogsCubit: Selecting month $month');
    }

    emit(state.copyWith(selectedMonth: month));
    await fetchUsages();
  }

  /// Extract user-friendly error message from exception
  String _extractErrorMessage(Object error) {
    final raw = error.toString();
    const prefix = 'Exception:';
    if (raw.startsWith(prefix)) {
      return raw.substring(prefix.length).trim();
    }
    return raw.isEmpty ? 'Failed to fetch call logs. Please try again.' : raw;
  }
}
