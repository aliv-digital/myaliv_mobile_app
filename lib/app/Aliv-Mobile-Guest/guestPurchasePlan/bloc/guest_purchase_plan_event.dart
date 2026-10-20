import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

import '../models/add_on_model.dart';
import '../models/plan_model.dart';
import '../repository/guest_purchase_plan_repository.dart';

abstract class GuestPurchasePlanEvent {}

class GuestPurchasePlanStarted extends GuestPurchasePlanEvent {}

/// Fired when the user taps a primary plan tile in a catalog tab.
/// Stores the selection on state so the "new active plan will be" red
/// card and the activate-now sheet can render around it.
class GuestPrimaryPlanSelected extends GuestPurchasePlanEvent {
  final BasePlanModel plan;
  GuestPrimaryPlanSelected(this.plan);
}

class GuestPurchasePlanTabChanged extends GuestPurchasePlanEvent {
  final PlanTab tab;
  GuestPurchasePlanTabChanged(this.tab);
}

class GuestPurchasePlanToggleExpanded extends GuestPurchasePlanEvent {
  final String planId;
  GuestPurchasePlanToggleExpanded(this.planId);
}

class GuestPurchasePlanViewDetailsPressed extends GuestPurchasePlanEvent {
  final GuestPlanDisplayModel plan;
  GuestPurchasePlanViewDetailsPressed(this.plan);
}

class GuestPurchasePlanPurchaseNowPressed extends GuestPurchasePlanEvent {
  final GuestPlanDisplayModel plan;
  GuestPurchasePlanPurchaseNowPressed(this.plan);
}

class GuestPurchasePlanToggleAddon extends GuestPurchasePlanEvent {
  final AddOnModel addon;
  GuestPurchasePlanToggleAddon(this.addon);
}
