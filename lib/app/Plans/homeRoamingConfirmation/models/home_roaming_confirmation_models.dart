import 'package:equatable/equatable.dart';
import '../../PlanScreen/models/base_plan_model.dart';

enum HomeRoamingConfirmationPurchaseLineType { primaryPlan, addOn }

class HomeRoamingConfirmationRouteArgs extends Equatable {
  final String phoneNumber;
  final BasePlanModel? selectedPlan;
  final DateTime? beginDate;
  final bool showDateField;
  final bool forceNow;

  const HomeRoamingConfirmationRouteArgs({
    required this.phoneNumber,
    required this.showDateField,
    this.selectedPlan,
    this.beginDate,
    this.forceNow = false,
  });

  HomeRoamingConfirmationRouteArgs copyWith({
    String? phoneNumber,
    BasePlanModel? selectedPlan,
    DateTime? beginDate,
    bool? showDateField,
    bool? forceNow,
  }) {
    return HomeRoamingConfirmationRouteArgs(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      beginDate: beginDate ?? this.beginDate,
      showDateField: showDateField ?? this.showDateField,
      forceNow: forceNow ?? this.forceNow,
    );
  }

  @override
  List<Object?> get props => [
        phoneNumber,
        selectedPlan,
        beginDate,
        showDateField,
        forceNow,
      ];
}

class HomeRoamingConfirmationPurchaseLineItem extends Equatable {
  final String id;
  final HomeRoamingConfirmationPurchaseLineType type;
  final String planTypeCode;

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
    required this.planTypeCode,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.price,
  });

  HomeRoamingConfirmationPurchaseLineItem copyWith({
    String? id,
    HomeRoamingConfirmationPurchaseLineType? type,
    String? planTypeCode,
    String? label,
    String? title,
    String? subtitle,
    double? price,
  }) {
    return HomeRoamingConfirmationPurchaseLineItem(
      id: id ?? this.id,
      type: type ?? this.type,
      planTypeCode: planTypeCode ?? this.planTypeCode,
      label: label ?? this.label,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      price: price ?? this.price,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        planTypeCode,
        label,
        title,
        subtitle,
        price,
      ];
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
