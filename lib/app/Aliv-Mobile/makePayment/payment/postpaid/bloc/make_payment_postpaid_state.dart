import 'package:equatable/equatable.dart';

import 'make_payment_postpaid_event.dart';

enum MpNavTarget { none, next, addCard }

enum MpPaymentMode { card, payWithCard }

class MakePaymentPostPaidState extends Equatable {
  final String title;
  final String paymentDueAmount;
  final String bottomAmount;
  final String bottomSubtitle;

  final MpAmountOption amountOption;
  final String customAmount;

  final bool termsAccepted;

  final MpPaymentMode paymentMode;
  final String? selectedMethodToken;

  final MpNavTarget navTarget;

  const MakePaymentPostPaidState({
    required this.title,
    required this.paymentDueAmount,
    required this.bottomAmount,
    required this.bottomSubtitle,
    required this.amountOption,
    required this.customAmount,
    required this.termsAccepted,
    required this.paymentMode,
    required this.selectedMethodToken,
    required this.navTarget,
  });

  factory MakePaymentPostPaidState.initial() {
    return const MakePaymentPostPaidState(
      title: 'payment',
      paymentDueAmount: r'$ 0.00',
      bottomAmount: r'$ 0.00',
      bottomSubtitle: '',
      amountOption: MpAmountOption.current,
      customAmount: '',
      termsAccepted: false,
      paymentMode: MpPaymentMode.card,
      selectedMethodToken: null,
      navTarget: MpNavTarget.none,
    );
  }

  bool get showCustomAmount => amountOption == MpAmountOption.other;

  bool get hasMethodSelected =>
      paymentMode == MpPaymentMode.payWithCard ||
      (selectedMethodToken != null && selectedMethodToken!.isNotEmpty);

  bool get canPayNow => termsAccepted && hasMethodSelected;

  MakePaymentPostPaidState copyWith({
    String? title,
    String? paymentDueAmount,
    String? bottomAmount,
    String? bottomSubtitle,
    MpAmountOption? amountOption,
    String? customAmount,
    bool? termsAccepted,
    MpPaymentMode? paymentMode,
    String? selectedMethodToken,
    MpNavTarget? navTarget,
  }) {
    return MakePaymentPostPaidState(
      title: title ?? this.title,
      paymentDueAmount: paymentDueAmount ?? this.paymentDueAmount,
      bottomAmount: bottomAmount ?? this.bottomAmount,
      bottomSubtitle: bottomSubtitle ?? this.bottomSubtitle,
      amountOption: amountOption ?? this.amountOption,
      customAmount: customAmount ?? this.customAmount,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      paymentMode: paymentMode ?? this.paymentMode,
      selectedMethodToken: selectedMethodToken ?? this.selectedMethodToken,
      navTarget: navTarget ?? this.navTarget,
    );
  }

  @override
  List<Object?> get props => [
        title,
        paymentDueAmount,
        bottomAmount,
        bottomSubtitle,
        amountOption,
        customAmount,
        termsAccepted,
        paymentMode,
        selectedMethodToken,
        navTarget,
      ];
}
