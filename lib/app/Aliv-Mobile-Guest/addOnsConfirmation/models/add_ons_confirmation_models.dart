import 'package:equatable/equatable.dart';

enum PurchaseLineType { primaryPlan, addOn }

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

  const PurchaseTotals({required this.subTotal, required this.vat});

  double get total => subTotal + vat;

  @override
  List<Object?> get props => [subTotal, vat, total];
}

class AddOnsConfirmationData extends Equatable {
  final String phoneNumber;
  final String headerTitle; // e.g. "guest purchase a plan"
  final String beginsOnDateText; // e.g. "Aug 6th, 2025"
  final List<PurchaseLineItem> items;
  final PurchaseTotals totals;

  const AddOnsConfirmationData({
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

/// One add-on tile the user selected on the catalog add-ons tab.
class AddOnsConfirmationSelectedAddOn extends Equatable {
  const AddOnsConfirmationSelectedAddOn({
    required this.id,
    required this.title,
    required this.price,
  });

  /// Catalog `BasePlanModel.planId` — the numeric id the backend expects
  /// in `Bundle.SecondaryPlans` on `POST /Guest/purchaseplan`.
  final String id;
  final String title;
  final double price;

  @override
  List<Object?> get props => [id, title, price];
}

/// Navigation args for `AppRoutes.addOnsConfirmation`.
///
/// Pattern mirrors `GuestPurchasePlanConfirmationRouteArgs` so the two
/// confirmation screens look / behave the same.
class AddOnsConfirmationRouteArgs extends Equatable {
  const AddOnsConfirmationRouteArgs({
    required this.phoneNumber,
    required this.selectedAddOns,
  });

  final String phoneNumber;
  final List<AddOnsConfirmationSelectedAddOn> selectedAddOns;

  @override
  List<Object?> get props => [phoneNumber, selectedAddOns];
}
