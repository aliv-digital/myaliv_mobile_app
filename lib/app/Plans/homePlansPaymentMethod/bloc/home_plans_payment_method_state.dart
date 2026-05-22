import 'package:equatable/equatable.dart';
import '../model/home_plans_payment_method_models.dart';

enum HomePlansPaymentMethodStatus {
  initial,
  loading,
  ready,
  submitting,
  success,
  failure,
}

enum HomePlansPaymentMethodNavTarget { none, addCard, wallet, paid }

/// Which payment radio the user has currently selected.
///
/// `card` means a row in the saved-methods list (saved card or charge-to-my-account)
/// — the chosen one is identified by [HomePlansPaymentMethodState.selectedMethodId].
/// `payWithCard` and `payFromWallet` are the two action rows below the list and
/// have no `selectedMethodId`.
enum HomePlansPaymentMode { card, payWithCard, payFromWallet }

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

  final HomePlansPaymentMethodNavTarget navTarget;
  final String? walletWarningMessage;
  final int walletWarningRequestId;

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
    required this.navTarget,
    required this.walletWarningMessage,
    required this.walletWarningRequestId,
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
    HomePlansPaymentMethodNavTarget? navTarget,
    String? walletWarningMessage,
    int? walletWarningRequestId,
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
      navTarget: navTarget ?? this.navTarget,
      walletWarningMessage: walletWarningMessage ?? this.walletWarningMessage,
      walletWarningRequestId:
          walletWarningRequestId ?? this.walletWarningRequestId,
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
        navTarget,
        walletWarningMessage,
        walletWarningRequestId,
      ];
}
