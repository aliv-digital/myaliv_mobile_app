import 'package:equatable/equatable.dart';
import '../../PlanScreen/models/plan_purchase_context.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/plan_purchase_bonus.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/plan_purchase_promo_code.dart';
import 'package:myaliv_mobile_app/core/utils/appUtils.dart';
import '../model/home_plans_payment_method_models.dart';

enum HomePlansPaymentMethodStatus {
  initial,
  loading,
  ready,
  submitting,
  success,
  failure,
}

enum HomePlansPaymentMethodNavTarget {
  none,
  addCard,
  wallet,
  paid,
  paymentFailed,
}

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
  final List<PlanPurchasePromoCode> promoCodes;
  final List<PlanPurchaseBonus> bonuses;
  final bool forceNow;
  final PlanPurchaseContext purchaseContext;

  /// Suppresses cancellation feedback once 3DS confirms payment, including
  /// while the existing analytics continuation is pending.
  final bool hasConfirmed3DSPayment;
  final DateTime? selectedBeginDate;

  final HomePlansPaymentMethodNavTarget navTarget;
  final String? walletWarningMessage;
  final int walletWarningRequestId;

  /// Last new-card details submitted via [HomePlansPayWithCardConfirmed].
  /// Forwarded to the receipt as `cardToSave` for the save-card affordance;
  /// null for saved-card / wallet / charge-to-my-account payments.
  final NewCardDetails? lastNewCardDetails;

  /// Order ID from the 3DS callback URL. Set after a successful 3DS payment
  /// so the receipt can offer the save-card affordance via /CreditCard/savenew.
  final String? orderId;

  /// Confirmed funding source, independent of later payment-radio changes.
  final bool walletPaymentSucceeded;

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
    required this.promoCodes,
    required this.bonuses,
    required this.forceNow,
    required this.selectedBeginDate,
    required this.navTarget,
    required this.walletWarningMessage,
    required this.walletWarningRequestId,
    this.lastNewCardDetails,
    this.orderId,
    this.purchaseContext = PlanPurchaseContext.regular,
    this.hasConfirmed3DSPayment = false,
    this.walletPaymentSucceeded = false,
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
      vatNote: 'no VAT applied',
      selectedItems: [],
      promoCodes: [],
      bonuses: [],
      forceNow: false,
      selectedBeginDate: null,
      navTarget: HomePlansPaymentMethodNavTarget.none,
      walletWarningMessage: null,
      walletWarningRequestId: 0,
    );
  }

  String get amountText => AppUtils.formatPrice(amount);

  String? get replacementPrimaryPlanTitle {
    if (purchaseContext !=
            PlanPurchaseContext.prepaidImmediatePrimaryReplacement ||
        !isPrepaidUser ||
        !forceNow) {
      return null;
    }
    for (final item in selectedItems) {
      if (item.planType == HomePlansPaymentPlanType.primary &&
          item.title.trim().isNotEmpty) {
        return item.title;
      }
    }
    return null;
  }

  bool get isPrepaidUser {
    return subscriberType == HomePlansSubscriberType.prepaid;
  }

  bool hasInsufficientWalletBalance(double walletBalance) {
    return isPrepaidUser &&
        paymentMode == HomePlansPaymentMode.payFromWallet &&
        walletBalance < amount;
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
    List<PlanPurchasePromoCode>? promoCodes,
    List<PlanPurchaseBonus>? bonuses,
    bool? forceNow,
    PlanPurchaseContext? purchaseContext,
    bool? hasConfirmed3DSPayment,
    DateTime? selectedBeginDate,
    HomePlansPaymentMethodNavTarget? navTarget,
    String? walletWarningMessage,
    int? walletWarningRequestId,
    NewCardDetails? lastNewCardDetails,
    bool clearLastNewCardDetails = false,
    String? orderId,
    bool clearOrderId = false,
    bool? walletPaymentSucceeded,
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
      promoCodes: promoCodes ?? this.promoCodes,
      bonuses: bonuses ?? this.bonuses,
      forceNow: forceNow ?? this.forceNow,
      purchaseContext: purchaseContext ?? this.purchaseContext,
      hasConfirmed3DSPayment:
          hasConfirmed3DSPayment ?? this.hasConfirmed3DSPayment,
      selectedBeginDate: selectedBeginDate ?? this.selectedBeginDate,
      navTarget: navTarget ?? this.navTarget,
      walletWarningMessage: walletWarningMessage ?? this.walletWarningMessage,
      walletWarningRequestId:
          walletWarningRequestId ?? this.walletWarningRequestId,
      lastNewCardDetails: clearLastNewCardDetails
          ? null
          : (lastNewCardDetails ?? this.lastNewCardDetails),
      orderId: clearOrderId ? null : (orderId ?? this.orderId),
      walletPaymentSucceeded:
          walletPaymentSucceeded ?? this.walletPaymentSucceeded,
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
    promoCodes,
    bonuses,
    forceNow,
    purchaseContext,
    hasConfirmed3DSPayment,
    selectedBeginDate,
    navTarget,
    walletWarningMessage,
    walletWarningRequestId,
    lastNewCardDetails,
    orderId,
    walletPaymentSucceeded,
  ];
}
