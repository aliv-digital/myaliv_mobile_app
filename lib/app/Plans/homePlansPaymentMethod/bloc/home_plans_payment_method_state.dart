import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import '../model/home_plans_payment_method_models.dart';

enum HomePlansPaymentMethodStatus {
  initial,
  loading,
  ready,
  submitting,
  success,
  failure,
}

enum HomePlansPaymentMethodNavTarget { none, addCard, wallet, paid, paymentFailed }

/// Which payment radio the user has currently selected.
///
/// `card` means a saved card row in the saved-methods list.
/// `chargeToMyAccount` means the postpaid "charge to my account" row.
/// Both use [HomePlansPaymentMethodState.selectedMethodId] for the selected row.
/// `payWithCard` and `payFromWallet` are the two action rows below the list and
/// have no `selectedMethodId`.
enum HomePlansPaymentMode {
  card,
  chargeToMyAccount,
  payWithCard,
  payFromWallet,
}

class HomePlansPaymentMethodState extends Equatable {
  final HomePlansPaymentMethodStatus status;
  final String? errorMessage;
  final HomePlansSubscriberType subscriberType;
  final String phoneNumber;

  final List<HomePlansSavedPaymentMethod> methods;
  final String? selectedMethodId;
  final HomePlansPaymentMode paymentMode;

  final double amount;
  final String vatNote;
  final List<HomePlansPaymentSelectedItem> selectedItems;
  final bool forceNow;
  final DateTime? selectedBeginDate;

  final HomePlansPaymentMethodNavTarget navTarget;
  final String? walletWarningMessage;
  final int walletWarningRequestId;

  /// Last new-card details submitted via [HomePlansPayWithCardConfirmed].
  /// Forwarded to the receipt as `cardToSave` for the save-card affordance;
  /// null for saved-card / wallet / charge-to-my-account payments.
  final NewCardDetails? lastNewCardDetails;

  const HomePlansPaymentMethodState({
    required this.status,
    required this.errorMessage,
    required this.subscriberType,
    required this.phoneNumber,
    required this.methods,
    required this.selectedMethodId,
    required this.paymentMode,
    required this.amount,
    required this.vatNote,
    required this.selectedItems,
    required this.forceNow,
    required this.selectedBeginDate,
    required this.navTarget,
    required this.walletWarningMessage,
    required this.walletWarningRequestId,
    this.lastNewCardDetails,
  });

  factory HomePlansPaymentMethodState.initial() {
    return const HomePlansPaymentMethodState(
      status: HomePlansPaymentMethodStatus.initial,
      errorMessage: null,
      subscriberType: HomePlansSubscriberType.postpaid,
      phoneNumber: '',
      methods: [],
      selectedMethodId: null,
      paymentMode: HomePlansPaymentMode.card,
      amount: 5.00,
      vatNote: 'no vat applied',
      selectedItems: [],
      forceNow: false,
      selectedBeginDate: null,
      navTarget: HomePlansPaymentMethodNavTarget.none,
      walletWarningMessage: null,
      walletWarningRequestId: 0,
    );
  }

  String get amountText => r'$ ' + amount.toStringAsFixed(2);

  bool get isPrepaidUser {
    return subscriberType == HomePlansSubscriberType.prepaid;
  }

  bool get isPayNowEnabled {
    if (status == HomePlansPaymentMethodStatus.submitting) return false;
    switch (paymentMode) {
      case HomePlansPaymentMode.card:
      case HomePlansPaymentMode.chargeToMyAccount:
        return selectedMethodId != null;
      case HomePlansPaymentMode.payWithCard:
      case HomePlansPaymentMode.payFromWallet:
        return true;
    }
  }

  HomePlansPaymentMethodState copyWith({
    HomePlansPaymentMethodStatus? status,
    String? errorMessage,
    HomePlansSubscriberType? subscriberType,
    String? phoneNumber,
    List<HomePlansSavedPaymentMethod>? methods,
    String? selectedMethodId,
    HomePlansPaymentMode? paymentMode,
    double? amount,
    String? vatNote,
    List<HomePlansPaymentSelectedItem>? selectedItems,
    bool? forceNow,
    DateTime? selectedBeginDate,
    HomePlansPaymentMethodNavTarget? navTarget,
    String? walletWarningMessage,
    int? walletWarningRequestId,
    NewCardDetails? lastNewCardDetails,
    bool clearLastNewCardDetails = false,
  }) {
    return HomePlansPaymentMethodState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      subscriberType: subscriberType ?? this.subscriberType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      methods: methods ?? this.methods,
      selectedMethodId: selectedMethodId ?? this.selectedMethodId,
      paymentMode: paymentMode ?? this.paymentMode,
      amount: amount ?? this.amount,
      vatNote: vatNote ?? this.vatNote,
      selectedItems: selectedItems ?? this.selectedItems,
      forceNow: forceNow ?? this.forceNow,
      selectedBeginDate: selectedBeginDate ?? this.selectedBeginDate,
      navTarget: navTarget ?? this.navTarget,
      walletWarningMessage: walletWarningMessage ?? this.walletWarningMessage,
      walletWarningRequestId:
          walletWarningRequestId ?? this.walletWarningRequestId,
      lastNewCardDetails: clearLastNewCardDetails
          ? null
          : (lastNewCardDetails ?? this.lastNewCardDetails),
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    subscriberType,
    phoneNumber,
    methods,
    selectedMethodId,
    paymentMode,
    amount,
    vatNote,
    selectedItems,
    forceNow,
    selectedBeginDate,
    navTarget,
    walletWarningMessage,
    walletWarningRequestId,
    lastNewCardDetails,
  ];
}
