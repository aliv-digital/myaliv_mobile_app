import 'package:equatable/equatable.dart';

sealed class PlanPurchasePlanAddOnsEvent extends Equatable {
  const PlanPurchasePlanAddOnsEvent();

  @override
  List<Object?> get props => [];
}

final class PlanPurchasePlanAddOnsStarted extends PlanPurchasePlanAddOnsEvent {
  const PlanPurchasePlanAddOnsStarted();
}

final class PlanPurchasePlanAddOnsAutoRenewToggled extends PlanPurchasePlanAddOnsEvent {
  final bool value;
  const PlanPurchasePlanAddOnsAutoRenewToggled(this.value);

  @override
  List<Object?> get props => [value];
}

final class PlanPurchasePlanAddOnsSelectionToggled extends PlanPurchasePlanAddOnsEvent {
  final String addOnId;
  final bool selected;
  const PlanPurchasePlanAddOnsSelectionToggled({
    required this.addOnId,
    required this.selected,
  });

  @override
  List<Object?> get props => [addOnId, selected];
}

final class PlanPurchasePlanAddOnsSkipPressed extends PlanPurchasePlanAddOnsEvent {
  const PlanPurchasePlanAddOnsSkipPressed();
}

final class PlanPurchasePlanAddOnsProceedPressed extends PlanPurchasePlanAddOnsEvent {
  const PlanPurchasePlanAddOnsProceedPressed();
}
