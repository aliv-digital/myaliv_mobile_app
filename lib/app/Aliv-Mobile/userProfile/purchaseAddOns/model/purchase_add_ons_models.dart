import 'package:equatable/equatable.dart';

class PurchaseAddOnsDataResult extends Equatable {
  final PurchaseAddOnsPrimaryPlan? activePrimaryPlan;
  final List<PurchaseAddOnsItem> addOns;
  final Set<String> selectedAddOnIds;

  const PurchaseAddOnsDataResult({
    required this.activePrimaryPlan,
    required this.addOns,
    required this.selectedAddOnIds,
  });

  const PurchaseAddOnsDataResult.empty()
      : activePrimaryPlan = null,
        addOns = const <PurchaseAddOnsItem>[],
        selectedAddOnIds = const <String>{};

  @override
  List<Object?> get props => [activePrimaryPlan, addOns, selectedAddOnIds];
}

class PurchaseAddOnsPrimaryPlan extends Equatable {
  final String id;
  final String name;
  final bool autoRenew;
  final DateTime? startDateTime;
  final DateTime? endDateTime;

  const PurchaseAddOnsPrimaryPlan({
    required this.id,
    required this.name,
    required this.autoRenew,
    required this.startDateTime,
    required this.endDateTime,
  });

  PurchaseAddOnsPrimaryPlan copyWith({bool? autoRenew}) {
    return PurchaseAddOnsPrimaryPlan(
      id: id,
      name: name,
      autoRenew: autoRenew ?? this.autoRenew,
      startDateTime: startDateTime,
      endDateTime: endDateTime,
    );
  }

  @override
  List<Object?> get props => [id, name, autoRenew, startDateTime, endDateTime];
}

class PurchaseAddOnsActivePlanSummary extends Equatable {
  final String label;
  final String name;
  final bool autoRenew;
  final String activeDateLabel;
  final String activeDate;
  final String expireDateLabel;
  final String expireDate;

  const PurchaseAddOnsActivePlanSummary({
    required this.label,
    required this.name,
    required this.autoRenew,
    required this.activeDateLabel,
    required this.activeDate,
    required this.expireDateLabel,
    required this.expireDate,
  });

  PurchaseAddOnsActivePlanSummary copyWith({bool? autoRenew}) {
    return PurchaseAddOnsActivePlanSummary(
      label: label,
      name: name,
      autoRenew: autoRenew ?? this.autoRenew,
      activeDateLabel: activeDateLabel,
      activeDate: activeDate,
      expireDateLabel: expireDateLabel,
      expireDate: expireDate,
    );
  }

  @override
  List<Object?> get props => [
        label,
        name,
        autoRenew,
        activeDateLabel,
        activeDate,
        expireDateLabel,
        expireDate,
      ];
}

class PurchaseAddOnsItem extends Equatable {
  final String id;
  final String title;
  final String subtitleLabel;
  final String subtitleValue;
  final double price;
  final double vatAmount;
  final String currencySymbol;

  const PurchaseAddOnsItem({
    required this.id,
    required this.title,
    required this.subtitleLabel,
    required this.subtitleValue,
    required this.price,
    required this.vatAmount,
    this.currencySymbol = r'$',
  });

  double get totalPrice => price + vatAmount;

  @override
  List<Object?> get props => [
        id,
        title,
        subtitleLabel,
        subtitleValue,
        price,
        vatAmount,
        currencySymbol,
      ];
}

class PurchaseAddOnsFairUsePolicy extends Equatable {
  final String title;
  final String description;

  const PurchaseAddOnsFairUsePolicy({
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [title, description];
}
