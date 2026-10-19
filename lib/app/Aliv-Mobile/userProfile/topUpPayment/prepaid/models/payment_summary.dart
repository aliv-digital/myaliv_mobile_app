import 'package:equatable/equatable.dart';

class PaymentSummary extends Equatable {
  final double total;
  final bool vatInclusive;
  final String? recipientPhone;

  const PaymentSummary({
    required this.total,
    required this.vatInclusive,
    this.recipientPhone,
  });

  @override
  List<Object?> get props => [total, recipientPhone, vatInclusive];
}
