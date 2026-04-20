import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/models/usage_model.dart';

/// Status of call logs operations
enum CallLogsStatus { initial, loading, success, failure }

/// State for call logs/usage management
class CallLogsState extends Equatable {
  const CallLogsState({
    this.status = CallLogsStatus.initial,
    this.usages = const [],
    this.selectedMonth,
    this.errorMessage,
  });

  final CallLogsStatus status;
  final List<UsageModel> usages;
  final DateTime? selectedMonth;
  final String? errorMessage;

  /// Check if data is available
  bool get hasData => usages.isNotEmpty;

  /// Check if loading
  bool get isLoading => status == CallLogsStatus.loading;

  /// Get the selected month or default to current month
  DateTime get currentMonth => selectedMonth ?? DateTime.now();

  /// Get start date of selected month (first day, 00:00:00)
  DateTime get startDate {
    final month = currentMonth;
    return DateTime(month.year, month.month, 1);
  }

  /// Get end date of selected month (last day, 23:59:59)
  DateTime get endDate {
    final month = currentMonth;
    return DateTime(month.year, month.month + 1, 0, 23, 59, 59);
  }

  /// Available months for selection (last 12 months)
  List<DateTime> get availableMonths {
    final now = DateTime.now();
    return List.generate(12, (i) => DateTime(now.year, now.month - i, 1));
  }

  CallLogsState copyWith({
    CallLogsStatus? status,
    List<UsageModel>? usages,
    DateTime? selectedMonth,
    String? errorMessage,
  }) {
    return CallLogsState(
      status: status ?? this.status,
      usages: usages ?? this.usages,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, usages, selectedMonth, errorMessage];
}
