import '../models/add_on_model.dart';
import '../repository/home_plan_repository.dart';
import '../models/plan_model.dart';

abstract class HomePlanEvent {}

class HomePlanStarted extends HomePlanEvent {}

class HomePlanTabChanged extends HomePlanEvent {
  final HomePlanTab tab;
  HomePlanTabChanged(this.tab);
}

class HomePlanToggleExpanded extends HomePlanEvent {
  final String planId;
  HomePlanToggleExpanded(this.planId);
}

class HomePlanViewDetailsPressed extends HomePlanEvent {
  final HomePlanModel plan;
  HomePlanViewDetailsPressed(this.plan);
}

class HomePlanPurchaseNowPressed extends HomePlanEvent {
  final HomePlanModel plan;
  HomePlanPurchaseNowPressed(this.plan);
}

class HomePlanToggleAddon extends HomePlanEvent {
  final HomePlanAddOnModel addon;
  HomePlanToggleAddon(this.addon);
}