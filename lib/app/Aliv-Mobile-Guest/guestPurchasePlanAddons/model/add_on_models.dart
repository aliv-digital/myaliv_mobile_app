import 'package:equatable/equatable.dart';

class ActivePlanSummary extends Equatable {
  final String label; // "active plan"
  final String name;  // "liberty70"
  final bool autoRenew;
  final String activeDateLabel; // "active"
  final String activeDate;      // "20/08/24"
  final String expireDateLabel; // "expire"
  final String expireDate;      // "19/09/24"

  const ActivePlanSummary({
    required this.label,
    required this.name,
    required this.autoRenew,
    required this.activeDateLabel,
    required this.activeDate,
    required this.expireDateLabel,
    required this.expireDate,
  });

  ActivePlanSummary copyWith({bool? autoRenew}) {
    return ActivePlanSummary(
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

class AddOnItem extends Equatable {
  final String id;
  final String title;          // "liberty data 1"
  final String subtitleLabel;  // "data balance"
  final String subtitleValue;  // "1gb"
  final double price;          // 5.00
  final String currencySymbol; // "$"

  const AddOnItem({
    required this.id,
    required this.title,
    required this.subtitleLabel,
    required this.subtitleValue,
    required this.price,
    this.currencySymbol = r'$',
  });

  @override
  List<Object?> get props => [id, title, subtitleLabel, subtitleValue, price, currencySymbol];
}

class FairUsePolicy extends Equatable {
  final String title;       // "fair use policy"
  final String description; // text

  const FairUsePolicy({
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [title, description];
}
