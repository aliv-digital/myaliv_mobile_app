import '../models/plan_model.dart';
import '../models/add_on_model.dart';
import '../models/daily_plan_model.dart';
import '../repository/home_plan_repository.dart';

enum HomePlanStatus { initial, loading, loaded, failure }

class HomePlanState {
  final HomePlanStatus status;
  final HomePlanTab selectedTab;

  final List<HomePlanModel> plans;
  final Set<String> expandedPlanIds;

  // ✅ AddOns support (new, existing delete kori নাই)
  final List<HomePlanAddOnModel> addOns;
  final Set<String> selectedAddOnIds;

  final String? errorMessage;

  /// Dedicated API data for Daily tab (not bound to UI yet).
  final List<DailyPlanModel> dailyApiPlans;

  /// Lightweight API metadata per tab.
  ///
  /// Important:
  /// - This map stores only loading/sync metadata.
  /// - Typed plan lists stay in dedicated fields
  ///   (`dailyApiPlans`, future `weeklyApiPlans`, etc).
  final Map<HomePlanTab, HomePlanTabApiMeta> apiTabMeta;

  /// Time when Daily API data was last synced successfully.
  final DateTime? dailyApiLastSyncedAt;

  const HomePlanState({
    required this.status,
    required this.selectedTab,
    required this.plans,
    required this.expandedPlanIds,
    required this.addOns,
    required this.selectedAddOnIds,
    this.errorMessage,
    required this.dailyApiPlans,
    required this.apiTabMeta,
    this.dailyApiLastSyncedAt,
  });

  factory HomePlanState.initial() {
    return const HomePlanState(
      status: HomePlanStatus.initial,
      selectedTab: HomePlanTab.monthly,
      plans: [],
      expandedPlanIds: {},
      addOns: [],
      selectedAddOnIds: {},
      dailyApiPlans: [],
      apiTabMeta: {},
    );
  }

  HomePlanState copyWith({
    HomePlanStatus? status,
    HomePlanTab? selectedTab,
    List<HomePlanModel>? plans,
    Set<String>? expandedPlanIds,

    // ✅ AddOns
    List<HomePlanAddOnModel>? addOns,
    Set<String>? selectedAddOnIds,
    String? errorMessage,
    List<DailyPlanModel>? dailyApiPlans,
    Map<HomePlanTab, HomePlanTabApiMeta>? apiTabMeta,
    DateTime? dailyApiLastSyncedAt,
  }) {
    return HomePlanState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      plans: plans ?? this.plans,
      expandedPlanIds: expandedPlanIds ?? this.expandedPlanIds,
      addOns: addOns ?? this.addOns,
      selectedAddOnIds: selectedAddOnIds ?? this.selectedAddOnIds,
      errorMessage: errorMessage,
      dailyApiPlans: dailyApiPlans ?? this.dailyApiPlans,
      apiTabMeta: apiTabMeta ?? this.apiTabMeta,
      dailyApiLastSyncedAt: dailyApiLastSyncedAt ?? this.dailyApiLastSyncedAt,
    );
  }
}

/// Lightweight per-tab API sync metadata.
///
/// Keep this small to avoid memory pressure and generic model casting.
class HomePlanTabApiMeta {
  const HomePlanTabApiMeta({
    required this.isLoaded,
    required this.itemCount,
    required this.lastSyncedAt,
  });

  final bool isLoaded;
  final int itemCount;
  final DateTime? lastSyncedAt;
}
