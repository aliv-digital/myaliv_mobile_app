import 'package:equatable/equatable.dart';

enum HomeRoamingConfirmationPurchaseLineType { primaryPlan, addOn }

class HomeRoamingConfirmationPurchaseLineItem extends Equatable {
  final String id;
  final HomeRoamingConfirmationPurchaseLineType type;

  /// e.g. "primary plan" / "add-on"
  final String label;

  /// e.g. "liberty70" / "liberty data 1"
  final String title;

  /// e.g. "begins immediately"
  final String subtitle;

  final double price;

  const HomeRoamingConfirmationPurchaseLineItem({
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

class HomeRoamingConfirmationPurchaseTotals extends Equatable {
  final double subTotal;
  final double vat;

  const HomeRoamingConfirmationPurchaseTotals({
    required this.subTotal,
    required this.vat,
  });

  double get total => subTotal + vat;

  @override
  List<Object?> get props => [subTotal, vat, total];
}

class HomeRoamingConfirmationData extends Equatable {
  final String phoneNumber;
  final String headerTitle; // e.g. "purchase a plan"
  final String beginsOnDateText; // e.g. "Aug 6th, 2025"
  final List<HomeRoamingConfirmationPurchaseLineItem> items;
  final HomeRoamingConfirmationPurchaseTotals totals;

  const HomeRoamingConfirmationData({
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
