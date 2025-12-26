import '../models/add_on_model.dart';
import '../repository/guest_purchase_plan_repository.dart';
import '../models/plan_model.dart';

abstract class GuestPurchasePlanEvent {}

class GuestPurchasePlanStarted extends GuestPurchasePlanEvent {}

class GuestPurchasePlanTabChanged extends GuestPurchasePlanEvent {
  final PlanTab tab;
  GuestPurchasePlanTabChanged(this.tab);
}

class GuestPurchasePlanToggleExpanded extends GuestPurchasePlanEvent {
  final String planId;
  GuestPurchasePlanToggleExpanded(this.planId);
}

class GuestPurchasePlanViewDetailsPressed extends GuestPurchasePlanEvent {
  final PlanModel plan;
  GuestPurchasePlanViewDetailsPressed(this.plan);
}

class GuestPurchasePlanPurchaseNowPressed extends GuestPurchasePlanEvent {
  final PlanModel plan;
  GuestPurchasePlanPurchaseNowPressed(this.plan);
}

class GuestPurchasePlanToggleAddon extends GuestPurchasePlanEvent {
  final AddOnModel addon;
  GuestPurchasePlanToggleAddon(this.addon);
}