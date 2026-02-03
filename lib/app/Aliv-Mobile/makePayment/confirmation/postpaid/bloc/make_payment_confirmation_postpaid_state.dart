import 'package:equatable/equatable.dart';

enum MakePaymentConfirmationNavTarget { none, next }

class MakePaymentConfirmationPostPaidState extends Equatable {
  final String title;
  final String customerName;
  final String accountNumber;
  final String headerLabel;
  final String amountPill;
  final String subtotal;
  final String vat;
  final String total;
  final String bottomSubtitle;
  final String bottomAmount;

  final String promoCode;
  final bool canApplyPromo;

  final MakePaymentConfirmationNavTarget navTarget;

  const MakePaymentConfirmationPostPaidState({
    required this.title,
    required this.customerName,
    required this.accountNumber,
    required this.headerLabel,
    required this.amountPill,
    required this.subtotal,
    required this.vat,
    required this.total,
    required this.bottomSubtitle,
    required this.bottomAmount,
    required this.promoCode,
    required this.canApplyPromo,
    required this.navTarget,
  });

  factory MakePaymentConfirmationPostPaidState.initial() {
    return const MakePaymentConfirmationPostPaidState(
      title: 'confirmation',
      customerName: '',
      accountNumber: '',
      headerLabel: '',
      amountPill: '',
      subtotal: '',
      vat: '',
      total: '',
      bottomSubtitle: '',
      bottomAmount: '',
      promoCode: '',
      canApplyPromo: false,
      navTarget: MakePaymentConfirmationNavTarget.none,
    );
  }

  MakePaymentConfirmationPostPaidState copyWith({
    String? title,
    String? customerName,
    String? accountNumber,
    String? headerLabel,
    String? amountPill,
    String? subtotal,
    String? vat,
    String? total,
    String? bottomSubtitle,
    String? bottomAmount,
    String? promoCode,
    bool? canApplyPromo,
    MakePaymentConfirmationNavTarget? navTarget,
  }) {
    return MakePaymentConfirmationPostPaidState(
      title: title ?? this.title,
      customerName: customerName ?? this.customerName,
      accountNumber: accountNumber ?? this.accountNumber,
      headerLabel: headerLabel ?? this.headerLabel,
      amountPill: amountPill ?? this.amountPill,
      subtotal: subtotal ?? this.subtotal,
      vat: vat ?? this.vat,
      total: total ?? this.total,
      bottomSubtitle: bottomSubtitle ?? this.bottomSubtitle,
      bottomAmount: bottomAmount ?? this.bottomAmount,
      promoCode: promoCode ?? this.promoCode,
      canApplyPromo: canApplyPromo ?? this.canApplyPromo,
      navTarget: navTarget ?? this.navTarget,
    );
  }

  @override
  List<Object?> get props => [
        title,
        customerName,
        accountNumber,
        headerLabel,
        amountPill,
        subtotal,
        vat,
        total,
        bottomSubtitle,
        bottomAmount,
        promoCode,
        canApplyPromo,
        navTarget,
      ];
}
