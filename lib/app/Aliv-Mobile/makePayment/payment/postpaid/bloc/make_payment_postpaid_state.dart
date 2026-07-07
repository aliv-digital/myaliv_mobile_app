import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';

import 'make_payment_postpaid_event.dart';

/// `next` and `addCard` are retained for the (legacy) intent-based
/// navigation slots; `paid` is set once the `/Order/payment` call has
/// succeeded and the view should push the receipt route.
enum MpNavTarget { none, next, addCard, paid }

enum MpPaymentMode { card, payWithCard }

/// Lifecycle of the API submit. `ready` is the default idle state (the
/// legacy code had no submit path, so this enum is new).
enum MpPaymentStatus { ready, paying, success, failure }

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
  final MpPaymentStatus status;
  final String? errorMessage;

  /// Last new-card details submitted via [MpPayWithCardConfirmed]. Kept on
  /// state so the receipt side-effect can forward it as `cardToSave` for
  /// the post-payment save-card affordance. Null for saved-card / wallet
  /// payments.
  final NewCardDetails? lastNewCardDetails;

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
    required this.status,
    required this.errorMessage,
    this.lastNewCardDetails,
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
      status: MpPaymentStatus.ready,
      errorMessage: null,
    );
  }

  bool get showCustomAmount => amountOption == MpAmountOption.other;

  bool get hasMethodSelected =>
      paymentMode == MpPaymentMode.payWithCard ||
      (selectedMethodToken != null && selectedMethodToken!.isNotEmpty);

  bool get canPayNow => termsAccepted && hasMethodSelected;

  bool get isBusy => status == MpPaymentStatus.paying;

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
    MpPaymentStatus? status,
    String? errorMessage,
    NewCardDetails? lastNewCardDetails,
    bool clearErrorMessage = false,
    bool clearLastNewCardDetails = false,
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
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      lastNewCardDetails: clearLastNewCardDetails
          ? null
          : (lastNewCardDetails ?? this.lastNewCardDetails),
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
        status,
        errorMessage,
        lastNewCardDetails,
      ];
}
