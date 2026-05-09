import 'package:equatable/equatable.dart';
import '../../PlanScreen/models/base_plan_model.dart';

enum HomeRoamingConfirmationPurchaseLineType { primaryPlan, addOn }

class HomeRoamingConfirmationRouteArgs extends Equatable {
  final String phoneNumber;
  final BasePlanModel? selectedPlan;
  final DateTime? beginDate;
  final bool showDateField;

  const HomeRoamingConfirmationRouteArgs({
    required this.phoneNumber,
    required this.showDateField,
    this.selectedPlan,
    this.beginDate,
  });

  HomeRoamingConfirmationRouteArgs copyWith({
    String? phoneNumber,
    BasePlanModel? selectedPlan,
    DateTime? beginDate,
    bool? showDateField,
  }) {
    return HomeRoamingConfirmationRouteArgs(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      beginDate: beginDate ?? this.beginDate,
      showDateField: showDateField ?? this.showDateField,
    );
  }

  @override
  List<Object?> get props => [
        phoneNumber,
        selectedPlan,
        beginDate,
        showDateField,
      ];
}

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

  HomeRoamingConfirmationPurchaseLineItem copyWith({
    String? id,
    HomeRoamingConfirmationPurchaseLineType? type,
    String? label,
    String? title,
    String? subtitle,
    double? price,
  }) {
    return HomeRoamingConfirmationPurchaseLineItem(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      price: price ?? this.price,
    );
  }

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
