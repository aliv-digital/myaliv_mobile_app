import 'package:equatable/equatable.dart';
import '../models/top_up_breakdown.dart';

enum ConfirmTopUpStatus { initial, loading, ready, applyingPromo, submitting, success, failure }

class ConfirmTopUpPrepaidState extends Equatable {
  final ConfirmTopUpStatus status;

  final String customerName;
  final String customerPhone;
  final double amount;

  final String promoCode;
  final String? appliedPromoCode;

  final TopUpBreakdown breakdown;

  final String? errorMessage;

  const ConfirmTopUpPrepaidState({
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.amount,
    required this.promoCode,
    required this.appliedPromoCode,
    required this.breakdown,
    required this.errorMessage,
  });

  factory ConfirmTopUpPrepaidState.initial() => const ConfirmTopUpPrepaidState(
    status: ConfirmTopUpStatus.initial,
    customerName: '',
    customerPhone: '',
    amount: 0,
    promoCode: '',
    appliedPromoCode: null,
    breakdown: TopUpBreakdown(subTotal: 0, vat: 0, total: 0, vatExclusive: true),
    errorMessage: null,
  );

  bool get isBusy => status == ConfirmTopUpStatus.loading || status == ConfirmTopUpStatus.applyingPromo || status == ConfirmTopUpStatus.submitting;

  ConfirmTopUpPrepaidState copyWith({
    ConfirmTopUpStatus? status,
    String? customerName,
    String? customerPhone,
    double? amount,
    String? promoCode,
    String? appliedPromoCode,
    TopUpBreakdown? breakdown,
    String? errorMessage,
  }) {
    return ConfirmTopUpPrepaidState(
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      amount: amount ?? this.amount,
      promoCode: promoCode ?? this.promoCode,
      appliedPromoCode: appliedPromoCode ?? this.appliedPromoCode,
      breakdown: breakdown ?? this.breakdown,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    customerName,
    customerPhone,
    amount,
    promoCode,
    appliedPromoCode,
    breakdown,
    errorMessage,
  ];
}
