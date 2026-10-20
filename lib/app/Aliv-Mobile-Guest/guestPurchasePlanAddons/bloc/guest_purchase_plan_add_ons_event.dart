import 'package:equatable/equatable.dart';

import '../../guestPurchasePlan/models/plan_model.dart';

sealed class GuestPurchasePlanAddOnsEvent extends Equatable {
  const GuestPurchasePlanAddOnsEvent();

  @override
  List<Object?> get props => [];
}

final class GuestPurchasePlanAddOnsStarted
    extends GuestPurchasePlanAddOnsEvent {
  const GuestPurchasePlanAddOnsStarted({this.routeArgs});

  /// When provided, the bloc builds the ActivePlanSummary + add-ons tiles
  /// from the real catalog + /Guest/existingplans data instead of the
  /// legacy hardcoded mock. Nullable so tests and legacy entry points
  /// still work.
  final GuestPurchasePlanAddOnsRouteArgs? routeArgs;

  @override
  List<Object?> get props => [routeArgs];
}

final class GuestPurchasePlanAddOnsAutoRenewToggled
    extends GuestPurchasePlanAddOnsEvent {
  final bool value;
  const GuestPurchasePlanAddOnsAutoRenewToggled(this.value);

  @override
  List<Object?> get props => [value];
}

final class GuestPurchasePlanAddOnsSelectionToggled
    extends GuestPurchasePlanAddOnsEvent {
  final String addOnId;
  final bool selected;
  const GuestPurchasePlanAddOnsSelectionToggled({
    required this.addOnId,
    required this.selected,
  });

  @override
  List<Object?> get props => [addOnId, selected];
}

final class GuestPurchasePlanAddOnsSkipPressed
    extends GuestPurchasePlanAddOnsEvent {
  const GuestPurchasePlanAddOnsSkipPressed();
}

final class GuestPurchasePlanAddOnsProceedPressed
    extends GuestPurchasePlanAddOnsEvent {
  const GuestPurchasePlanAddOnsProceedPressed();
}
