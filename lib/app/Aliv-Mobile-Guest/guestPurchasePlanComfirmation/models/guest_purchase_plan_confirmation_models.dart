import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/models/plan_model.dart';

enum PurchaseLineType { primaryPlan, addOn }

enum GuestPurchasePlanConfirmationEntryFlow { proceed, skip }

class GuestPurchasePlanConfirmationSelectedAddOn extends Equatable {
  final String id;
  final String title;
  final double price;
  final double vatAmount;

  const GuestPurchasePlanConfirmationSelectedAddOn({
    required this.id,
    required this.title,
    required this.price,
    this.vatAmount = 0,
  });

  @override
  List<Object?> get props => [id, title, price, vatAmount];
}

class GuestPurchasePlanConfirmationRouteArgs extends Equatable {
  final String phoneNumber;
  final String accountHolderName;
  final String primaryPlanName;
  final double primaryPlanPrice;

  /// Label-only API base price; [primaryPlanPrice] retains total semantics.
  final double? primaryPlanBasePrice;
  final double primaryPlanVatAmount;
  final String futurePlanStartDate;
  final GuestPurchasePlanConfirmationEntryFlow flow;
  final List<GuestPurchasePlanConfirmationSelectedAddOn> selectedAddOns;
  final bool forceNow;
  final GuestPlanDisplayModel? selectedPlan;

  const GuestPurchasePlanConfirmationRouteArgs({
    required this.phoneNumber,
    required this.accountHolderName,
    required this.primaryPlanName,
    required this.primaryPlanPrice,
    required this.flow,
    this.primaryPlanBasePrice,
    this.primaryPlanVatAmount = 0,
    this.futurePlanStartDate = '',
    this.selectedAddOns = const <GuestPurchasePlanConfirmationSelectedAddOn>[],
    this.forceNow = true,
    this.selectedPlan,
  });

  bool get defaultTermsChecked =>
      flow == GuestPurchasePlanConfirmationEntryFlow.skip;

  /// `true` when the plan should activate immediately and `false` when it was
  /// explicitly scheduled as a future plan.
  bool get isFuture => !forceNow;

  @override
  List<Object?> get props => [
    phoneNumber,
    accountHolderName,
    primaryPlanName,
    primaryPlanPrice,
    primaryPlanBasePrice,
    primaryPlanVatAmount,
    futurePlanStartDate,
    flow,
    selectedAddOns,
    forceNow,
    selectedPlan,
  ];
}

class PurchaseLineItem extends Equatable {
  final String id;
  final PurchaseLineType type;

  /// e.g. "primary plan" / "add-on"
  final String label;

  /// e.g. "liberty70" / "liberty data 1"
  final String title;

  /// e.g. "begins immediately"
  final String subtitle;

  /// Base amount before VAT. [vatAmount] carries the VAT portion so the
  /// confirmation ticket can show `sub total` + `vat` + `total` the same way
  /// as the authenticated flow (`home_plan_confirmation_models.dart`).
  final double price;

  /// Label-only base price. Kept for backward compatibility with
  /// `PurchaseItemRow` which still prefers it for the per-item row.
  final double? basePrice;

  final double vatAmount;

  double get totalPrice => price + vatAmount;

  const PurchaseLineItem({
    required this.id,
    required this.type,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.price,
    this.basePrice,
    this.vatAmount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    label,
    title,
    subtitle,
    price,
    basePrice,
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

class GuestPurchasePlanConfirmationData extends Equatable {
  final String phoneNumber;
  final String headerTitle; // e.g. "guest purchase a plan"
  final List<PurchaseLineItem> items;
  final PurchaseTotals totals;

  const GuestPurchasePlanConfirmationData({
    required this.phoneNumber,
    required this.headerTitle,
    required this.items,
    required this.totals,
  });

  @override
  List<Object?> get props => [phoneNumber, headerTitle, items, totals];
}
