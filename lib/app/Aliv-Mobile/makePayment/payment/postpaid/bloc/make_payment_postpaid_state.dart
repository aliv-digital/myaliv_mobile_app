import 'package:equatable/equatable.dart';

import '../repository/make_payment_postpaid_repository.dart';
import 'make_payment_postpaid_event.dart';

enum MpNavTarget { none, next }

class MakePaymentPostPaidState extends Equatable {
  final String title;
  final String paymentDueAmount;
  final String bottomAmount;
  final String bottomSubtitle;

  final MpAmountOption amountOption;
  final String customAmount;

  final bool termsAccepted;

  final List<MpPaymentMethod> methods;
  final int selectedMethodIndex;

  final MpNavTarget navTarget;

  const MakePaymentPostPaidState({
    required this.title,
    required this.paymentDueAmount,
    required this.bottomAmount,
    required this.bottomSubtitle,
    required this.amountOption,
    required this.customAmount,
    required this.termsAccepted,
    required this.methods,
    required this.selectedMethodIndex,
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
      methods: [],
      selectedMethodIndex: 0,
      navTarget: MpNavTarget.none,
    );
  }

  bool get showCustomAmount => amountOption == MpAmountOption.other;

  bool get canPayNow => termsAccepted;

  MakePaymentPostPaidState copyWith({
    String? title,
    String? paymentDueAmount,
    String? bottomAmount,
    String? bottomSubtitle,
    MpAmountOption? amountOption,
    String? customAmount,
    bool? termsAccepted,
    List<MpPaymentMethod>? methods,
    int? selectedMethodIndex,
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
      methods: methods ?? this.methods,
      selectedMethodIndex: selectedMethodIndex ?? this.selectedMethodIndex,
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
        methods,
        selectedMethodIndex,
        navTarget,
      ];
}
