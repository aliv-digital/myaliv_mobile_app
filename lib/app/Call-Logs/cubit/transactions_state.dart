import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/models/transaction_model.dart';

/// Status of transactions operations
enum TransactionsStatus { initial, loading, success, failure }

/// State for transactions management
class TransactionsState extends Equatable {
  const TransactionsState({
    this.status = TransactionsStatus.initial,
    this.transactions = const [],
    this.selectedMonth,
    this.errorMessage,
  });

  final TransactionsStatus status;
  final List<TransactionModel> transactions;
  final DateTime? selectedMonth;
  final String? errorMessage;

  /// Check if data is available
  bool get hasData => transactions.isNotEmpty;

  /// Check if loading
  bool get isLoading => status == TransactionsStatus.loading;

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

  TransactionsState copyWith({
    TransactionsStatus? status,
    List<TransactionModel>? transactions,
    DateTime? selectedMonth,
    String? errorMessage,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transactions, selectedMonth, errorMessage];
}
