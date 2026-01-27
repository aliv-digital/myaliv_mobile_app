import 'package:equatable/equatable.dart';

class PaymentSummary extends Equatable {
  final double total;
  final bool vatInclusive;

  const PaymentSummary({
    required this.total,
    required this.vatInclusive,
  });

  @override
  List<Object?> get props => [total, vatInclusive];
}
