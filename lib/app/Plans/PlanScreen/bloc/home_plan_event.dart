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

/// Internal event to sync strict daily API data.
/// UI rendering remains unchanged in current phase.
class HomePlanDailyApiSyncRequested extends HomePlanEvent {
  final bool printRawResponse;

  HomePlanDailyApiSyncRequested({
    this.printRawResponse = false,
  });
}

/// Internal event to sync strict weekly API data.
/// UI rendering remains unchanged in current phase.
class HomePlanWeeklyApiSyncRequested extends HomePlanEvent {
  final bool printRawResponse;

  HomePlanWeeklyApiSyncRequested({
    this.printRawResponse = false,
  });
}

/// Internal event to sync strict monthly API data.
/// UI rendering remains unchanged in current phase.
class HomePlanMonthlyApiSyncRequested extends HomePlanEvent {
  final bool printRawResponse;

  HomePlanMonthlyApiSyncRequested({
    this.printRawResponse = false,
  });
}

/// Internal event to sync strict roaming API data.
/// UI rendering remains unchanged in current phase.
class HomePlanRoamingApiSyncRequested extends HomePlanEvent {
  final bool printRawResponse;

  HomePlanRoamingApiSyncRequested({
    this.printRawResponse = false,
  });
}

/// Internal event to sync strict RoamEasy API data.
/// UI rendering remains unchanged in current phase.
class HomePlanRoamEasyApiSyncRequested extends HomePlanEvent {
  final bool printRawResponse;

  HomePlanRoamEasyApiSyncRequested({
    this.printRawResponse = false,
  });
}

/// Internal event to sync strict MiFi API data.
/// UI rendering remains unchanged in current phase.
class HomePlanMifiApiSyncRequested extends HomePlanEvent {
  final bool printRawResponse;

  HomePlanMifiApiSyncRequested({
    this.printRawResponse = false,
  });
}

/// Internal event to sync strict Liberty Global API data.
/// UI rendering remains unchanged in current phase.
class HomePlanLibertyGlobalApiSyncRequested extends HomePlanEvent {
  final bool printRawResponse;

  HomePlanLibertyGlobalApiSyncRequested({
    this.printRawResponse = false,
  });
}

/// UI one-time side effect consumed event.
///
/// After UI shows a toast, it dispatches this event
/// to clear the pending toast from state.
class HomePlanToastConsumed extends HomePlanEvent {}
