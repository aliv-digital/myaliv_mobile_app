import 'package:equatable/equatable.dart';

enum TopUpPrepaidLoadStatus { initial, loading, ready, failure }
enum TopUpPrepaidSubmitStatus { idle, loading, success, failure }

class TopUpPrepaidState extends Equatable {
  final TopUpPrepaidLoadStatus loadStatus;
  final TopUpPrepaidSubmitStatus submitStatus;

  final int selectedTabIndex; // 0=my number, 1=auto, 2=send
  final double balance;
  final String amountText;

  final String? errorMessage;

  /// 24h rolling top-up allowance remaining. `null` means we couldn't verify
  /// (endpoint failed or hasn't returned yet) → treat as Case D.
  final double? limitLeft;
  final DateTime? earliestTopUpDateLocal;
  final bool limitFetchFailed;

  const TopUpPrepaidState({
    required this.loadStatus,
    required this.submitStatus,
    required this.selectedTabIndex,
    required this.balance,
    required this.amountText,
    required this.errorMessage,
    required this.limitLeft,
    required this.earliestTopUpDateLocal,
    required this.limitFetchFailed,
  });

  factory TopUpPrepaidState.initial() => const TopUpPrepaidState(
    loadStatus: TopUpPrepaidLoadStatus.initial,
    submitStatus: TopUpPrepaidSubmitStatus.idle,
    selectedTabIndex: 0,
    balance: 0.0,
    amountText: '',
    errorMessage: null,
    limitLeft: null,
    earliestTopUpDateLocal: null,
    limitFetchFailed: false,
  );

  double get amountValue {
    final cleaned = amountText.trim().replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  bool get canSubmit => amountValue > 0 && submitStatus != TopUpPrepaidSubmitStatus.loading;

  TopUpPrepaidState copyWith({
    TopUpPrepaidLoadStatus? loadStatus,
    TopUpPrepaidSubmitStatus? submitStatus,
    int? selectedTabIndex,
    double? balance,
    String? amountText,
    String? errorMessage,
    double? limitLeft,
    DateTime? earliestTopUpDateLocal,
    bool? limitFetchFailed,
    bool clearError = false,
  }) {
    return TopUpPrepaidState(
      loadStatus: loadStatus ?? this.loadStatus,
      submitStatus: submitStatus ?? this.submitStatus,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      balance: balance ?? this.balance,
      amountText: amountText ?? this.amountText,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      limitLeft: limitLeft ?? this.limitLeft,
      earliestTopUpDateLocal: earliestTopUpDateLocal ?? this.earliestTopUpDateLocal,
      limitFetchFailed: limitFetchFailed ?? this.limitFetchFailed,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    submitStatus,
    selectedTabIndex,
    balance,
    amountText,
    errorMessage,
    limitLeft,
    earliestTopUpDateLocal,
    limitFetchFailed,
  ];
}
