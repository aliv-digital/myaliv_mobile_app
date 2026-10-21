import 'package:equatable/equatable.dart';

enum PurchaseLineType { primaryPlan, addOn }

class RoamingPlanConfirmationRouteArgs extends Equatable {
  final String phoneNumber;
  final String planId;
  final String planName;
  final String planDuration;
  final double planPrice;

  /// Label-only API base price; [planPrice] still drives existing totals.
  final double? planBasePrice;
  final DateTime beginDate;
  final bool showDateField;
  final bool forceNow;

  const RoamingPlanConfirmationRouteArgs({
    required this.phoneNumber,
    required this.planId,
    required this.planName,
    required this.planDuration,
    required this.planPrice,
    this.planBasePrice,
    required this.beginDate,
    required this.showDateField,
    required this.forceNow,
  });

  factory RoamingPlanConfirmationRouteArgs.fromExtra(
    Object? extra, {
    required String fallbackPhoneNumber,
    required bool fallbackShowDateField,
  }) {
    final values = extra is Map ? extra : const <Object?, Object?>{};
    final rawBeginDate = values['beginDate'];
    final parsedBeginDate = rawBeginDate is DateTime
        ? rawBeginDate
        : DateTime.tryParse(rawBeginDate?.toString() ?? '');
    final rawPrice = values['planPrice'];
    final rawBasePrice = values['planBasePrice'];
    final showDateField = values['showDateField'] is bool
        ? values['showDateField'] as bool
        : fallbackShowDateField;

    return RoamingPlanConfirmationRouteArgs(
      phoneNumber: values['phoneNumber']?.toString() ?? fallbackPhoneNumber,
      planId: values['planId']?.toString() ?? 'r1',
      planName: values['planName']?.toString() ?? 'roam20',
      planDuration: values['planDuration']?.toString() ?? '7 days',
      planPrice: rawPrice is num ? rawPrice.toDouble() : 20,
      planBasePrice: rawBasePrice is num ? rawBasePrice.toDouble() : null,
      beginDate: parsedBeginDate ?? DateTime.now(),
      showDateField: showDateField,
      forceNow: values['forceNow'] is bool
          ? values['forceNow'] as bool
          : !showDateField,
    );
  }

  RoamingPlanConfirmationRouteArgs copyWith({DateTime? beginDate}) {
    return RoamingPlanConfirmationRouteArgs(
      phoneNumber: phoneNumber,
      planId: planId,
      planName: planName,
      planDuration: planDuration,
      planPrice: planPrice,
      planBasePrice: planBasePrice,
      beginDate: beginDate ?? this.beginDate,
      showDateField: showDateField,
      forceNow: forceNow,
    );
  }

  @override
  List<Object?> get props => [
    phoneNumber,
    planId,
    planName,
    planDuration,
    planPrice,
    planBasePrice,
    beginDate,
    showDateField,
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

  /// Label-only base price. Never used to calculate totals or payment amounts.
  final double? basePrice;

  const PurchaseLineItem({
    required this.id,
    required this.type,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.price,
    this.basePrice,
  });

  PurchaseLineItem copyWith({String? subtitle}) {
    return PurchaseLineItem(
      id: id,
      type: type,
      label: label,
      title: title,
      subtitle: subtitle ?? this.subtitle,
      price: price,
      basePrice: basePrice,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    label,
    title,
    subtitle,
    price,
    basePrice,
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

class RoamingPlanConfirmationData extends Equatable {
  final String phoneNumber;
  final String headerTitle; // e.g. "guest purchase a plan"
  final String beginsOnDateText; // e.g. "Aug 6th, 2025"
  final List<PurchaseLineItem> items;
  final PurchaseTotals totals;

  const RoamingPlanConfirmationData({
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
