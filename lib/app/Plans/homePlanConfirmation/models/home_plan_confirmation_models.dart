import 'package:equatable/equatable.dart';

enum PurchaseLineType { primaryPlan, addOn }
enum HomePlanConfirmationEntryFlow { proceed, skip }

class HomePlanConfirmationSelectedAddOn extends Equatable {
  final String id;
  final String title;
  final double price;

  const HomePlanConfirmationSelectedAddOn({
    required this.id,
    required this.title,
    required this.price,
  });

  @override
  List<Object?> get props => [id, title, price];
}

class HomePlanConfirmationRouteArgs extends Equatable {
  final String phoneNumber;
  final String accountHolderName;
  final String primaryPlanName;
  final double primaryPlanPrice;
  final HomePlanConfirmationEntryFlow flow;
  final List<HomePlanConfirmationSelectedAddOn> selectedAddOns;

  const HomePlanConfirmationRouteArgs({
    required this.phoneNumber,
    required this.accountHolderName,
    required this.primaryPlanName,
    required this.primaryPlanPrice,
    required this.flow,
    this.selectedAddOns = const <HomePlanConfirmationSelectedAddOn>[],
  });

  bool get defaultTermsChecked => flow == HomePlanConfirmationEntryFlow.skip;

  @override
  List<Object?> get props => [
        phoneNumber,
        accountHolderName,
        primaryPlanName,
        primaryPlanPrice,
        flow,
        selectedAddOns,
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
