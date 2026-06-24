import 'package:equatable/equatable.dart';

enum PurchaseLineType { primaryPlan, addOn }

enum HomePlanConfirmationEntryFlow { proceed, skip }

class HomePlanConfirmationSelectedAddOn extends Equatable {
  final String id;
  final String title;
  final double price;
  final double vatAmount;
  final String planTypeCode;

  const HomePlanConfirmationSelectedAddOn({
    required this.id,
    required this.title,
    required this.price,
    this.vatAmount = 0,
    this.planTypeCode = 'S',
  });

  @override
  List<Object?> get props => [id, title, price, vatAmount, planTypeCode];
}

class HomePlanConfirmationRouteArgs extends Equatable {
  final String phoneNumber;
  final String accountHolderName;
  final String primaryPlanId;
  final String primaryPlanName;
  final String primaryPlanTypeCode;
  final double primaryPlanPrice;
  final double primaryPlanVatAmount;
  final String futurePlanStartDate;
  final HomePlanConfirmationEntryFlow flow;
  final List<HomePlanConfirmationSelectedAddOn> selectedAddOns;
  final bool forceNow;

  /// When `true`, the primary plan is treated as already-active context:
  /// it is omitted from charged line items and excluded from totals.
  /// Used by the Plans → "ad-ons" tab where only add-ons are being charged.
  final bool isPrimaryPlanActive;

  /// Alternate contact number collected on the MiFi alt-contact screen.
  /// Empty when not collected (non-MiFi flows or already on file).
  final String altContactNumber;

  /// User's opt-in for plan discounts / device offers — captured on the
  /// MiFi alt-contact screen. `false` when not asked.
  final bool marketingOptIn;

  const HomePlanConfirmationRouteArgs({
    required this.phoneNumber,
    required this.accountHolderName,
    required this.primaryPlanName,
    required this.primaryPlanPrice,
    required this.flow,
    this.primaryPlanId = '',
    this.primaryPlanTypeCode = '',
    this.primaryPlanVatAmount = 0,
    this.futurePlanStartDate = '',
    this.selectedAddOns = const <HomePlanConfirmationSelectedAddOn>[],
    this.isPrimaryPlanActive = false,
    this.forceNow = false,
    this.altContactNumber = '',
    this.marketingOptIn = false,
  });

  bool get defaultTermsChecked => flow == HomePlanConfirmationEntryFlow.skip;

  /// `true` when the user tapped "future plan", `false` for "activate now".
  bool get isFuture => !forceNow;

  @override
  List<Object?> get props => [
        phoneNumber,
        accountHolderName,
        primaryPlanId,
        primaryPlanName,
        primaryPlanTypeCode,
        primaryPlanPrice,
        primaryPlanVatAmount,
        futurePlanStartDate,
        flow,
        selectedAddOns,
        isPrimaryPlanActive,
        forceNow,
        altContactNumber,
        marketingOptIn,
      ];
}

class PurchaseLineItem extends Equatable {
  final String id;
  final PurchaseLineType type;
  final String planTypeCode;

  /// e.g. "primary plan" / "add-on"
  final String label;

  /// e.g. "liberty70" / "liberty data 1"
  final String title;

  /// e.g. "begins immediately"
  final String subtitle;

  final double price;
  final double vatAmount;

  double get totalPrice => price + vatAmount;

  const PurchaseLineItem({
    required this.id,
    required this.type,
    required this.planTypeCode,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.price,
    this.vatAmount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        planTypeCode,
        label,
        title,
        subtitle,
        price,
        vatAmount,
      ];
}

class PurchaseTotals extends Equatable {
  final double subTotal;
  final double vat;

  const PurchaseTotals({required this.subTotal, required this.vat});

  double get total => subTotal + vat;

  @override
  List<Object?> get props => [subTotal, vat, total];
}

class HomePlanConfirmationData extends Equatable {
  final String phoneNumber;
  final String headerTitle; // e.g. "guest purchase a plan"
  final String beginsOnDateText; // e.g. "Aug 6th, 2025"
  final List<PurchaseLineItem> items;
  final PurchaseTotals totals;

  const HomePlanConfirmationData({
    required this.phoneNumber,
    required this.headerTitle,
    required this.beginsOnDateText,
    required this.items,
    required this.totals,
  });

  @override
  List<Object?> get props => [
        phoneNumber,
        headerTitle,
        beginsOnDateText,
        items,
        totals,
      ];
}
