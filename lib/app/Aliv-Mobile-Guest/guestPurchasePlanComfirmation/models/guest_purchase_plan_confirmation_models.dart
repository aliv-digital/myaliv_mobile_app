import 'package:equatable/equatable.dart';

enum PurchaseLineType { primaryPlan, addOn }

enum GuestPurchasePlanConfirmationEntryFlow { proceed, skip }

class GuestPurchasePlanConfirmationSelectedAddOn extends Equatable {
  final String id;
  final String title;
  final double price;

  const GuestPurchasePlanConfirmationSelectedAddOn({
    required this.id,
    required this.title,
    required this.price,
  });

  @override
  List<Object?> get props => [id, title, price];
}

class GuestPurchasePlanConfirmationRouteArgs extends Equatable {
  final String phoneNumber;
  final String accountHolderName;
  final String primaryPlanName;
  final double primaryPlanPrice;
  final String futurePlanStartDate;
  final GuestPurchasePlanConfirmationEntryFlow flow;
  final List<GuestPurchasePlanConfirmationSelectedAddOn> selectedAddOns;
  final bool forceNow;

  const GuestPurchasePlanConfirmationRouteArgs({
    required this.phoneNumber,
    required this.accountHolderName,
    required this.primaryPlanName,
    required this.primaryPlanPrice,
    required this.flow,
    this.futurePlanStartDate = '',
    this.selectedAddOns = const <GuestPurchasePlanConfirmationSelectedAddOn>[],
    this.forceNow = true,
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
        futurePlanStartDate,
        flow,
        selectedAddOns,
        forceNow,
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

  final double price;

  const PurchaseLineItem({
    required this.id,
    required this.type,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.price,
  });

  @override
  List<Object?> get props => [id, type, label, title, subtitle, price];
}

class PurchaseTotals extends Equatable {
  final double subTotal;
  final double vat;

  const PurchaseTotals({
    required this.subTotal,
    required this.vat,
  });

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
