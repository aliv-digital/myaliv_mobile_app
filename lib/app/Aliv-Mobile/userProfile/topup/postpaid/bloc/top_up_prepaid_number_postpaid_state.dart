import 'package:equatable/equatable.dart';

enum TopUpPrepaidNumberPostPaidLoadStatus { initial, loading, ready, failure }
enum TopUpPrepaidNumberPostPaidApplyStatus { idle, loading, success, failure }

class TopUpPrepaidNumberPostPaidState extends Equatable {
  final TopUpPrepaidNumberPostPaidLoadStatus loadStatus;

  final String number;
  final String confirmNumber;
  final String amountText;

  final TopUpPrepaidNumberPostPaidApplyStatus applyStatus;
  final String? errorMessage;

  const TopUpPrepaidNumberPostPaidState({
    required this.loadStatus,
    required this.number,
    required this.confirmNumber,
    required this.amountText,
    required this.applyStatus,
    required this.errorMessage,
  });

  factory TopUpPrepaidNumberPostPaidState.initial() => const TopUpPrepaidNumberPostPaidState(
    loadStatus: TopUpPrepaidNumberPostPaidLoadStatus.initial,
    number: '',
    confirmNumber: '',
    amountText: '0.00',
    applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.idle,
    errorMessage: null,
  );

  double get amountValue {
    final cleaned = amountText.trim().replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  bool get numbersMatch =>
      number.trim().isNotEmpty &&
          confirmNumber.trim().isNotEmpty &&
          number.trim() == confirmNumber.trim();

  bool get canApply =>
      loadStatus == TopUpPrepaidNumberPostPaidLoadStatus.ready &&
          applyStatus != TopUpPrepaidNumberPostPaidApplyStatus.loading &&
          numbersMatch &&
          amountValue > 0;

  TopUpPrepaidNumberPostPaidState copyWith({
    TopUpPrepaidNumberPostPaidLoadStatus? loadStatus,
    String? number,
    String? confirmNumber,
    String? amountText,
    TopUpPrepaidNumberPostPaidApplyStatus? applyStatus,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TopUpPrepaidNumberPostPaidState(
      loadStatus: loadStatus ?? this.loadStatus,
      number: number ?? this.number,
      confirmNumber: confirmNumber ?? this.confirmNumber,
      amountText: amountText ?? this.amountText,
      applyStatus: applyStatus ?? this.applyStatus,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    number,
    confirmNumber,
    amountText,
    applyStatus,
    errorMessage,
  ];
}
