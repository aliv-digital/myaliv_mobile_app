import 'package:equatable/equatable.dart';

import '../model/plan_purchase_plan_add_ons_route_args.dart';

sealed class PlanPurchasePlanAddOnsEvent extends Equatable {
  const PlanPurchasePlanAddOnsEvent();

  @override
  List<Object?> get props => [];
}

final class PlanPurchasePlanAddOnsStarted extends PlanPurchasePlanAddOnsEvent {
  const PlanPurchasePlanAddOnsStarted({this.routeArgs});

  final PlanPurchasePlanAddOnsRouteArgs? routeArgs;

  @override
  List<Object?> get props => [routeArgs];
}

final class PlanPurchasePlanAddOnsAutoRenewToggled
    extends PlanPurchasePlanAddOnsEvent {
  final bool value;
  const PlanPurchasePlanAddOnsAutoRenewToggled(this.value);

  @override
  List<Object?> get props => [value];
}

final class PlanPurchasePlanAddOnsSelectionToggled
    extends PlanPurchasePlanAddOnsEvent {
  final String addOnId;
  final bool selected;
  const PlanPurchasePlanAddOnsSelectionToggled({
    required this.addOnId,
    required this.selected,
  });

  @override
  List<Object?> get props => [addOnId, selected];
}

final class PlanPurchasePlanAddOnsSkipPressed
    extends PlanPurchasePlanAddOnsEvent {
  const PlanPurchasePlanAddOnsSkipPressed();
}

final class PlanPurchasePlanAddOnsProceedPressed
    extends PlanPurchasePlanAddOnsEvent {
  const PlanPurchasePlanAddOnsProceedPressed();
}
