import 'package:equatable/equatable.dart';

class TopUpBreakdown extends Equatable {
  final double subTotal;
  final double vat;
  final double total;
  final bool vatExclusive;

  const TopUpBreakdown({
    required this.subTotal,
    required this.vat,
    required this.total,
    required this.vatExclusive,
  });

  @override
  List<Object?> get props => [subTotal, vat, total, vatExclusive];

  TopUpBreakdown copyWith({
    double? subTotal,
    double? vat,
    double? total,
    bool? vatExclusive,
  }) {
    return TopUpBreakdown(
      subTotal: subTotal ?? this.subTotal,
      vat: vat ?? this.vat,
      total: total ?? this.total,
      vatExclusive: vatExclusive ?? this.vatExclusive,
    );
  }
}
