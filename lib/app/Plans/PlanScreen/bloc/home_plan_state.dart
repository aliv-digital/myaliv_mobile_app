import '../models/plan_model.dart';
import '../models/add_on_model.dart';
import '../models/daily_plan_model.dart';
import '../models/weekly_plan_model.dart';
import '../repository/home_plan_repository.dart';

enum HomePlanStatus { initial, loading, loaded, failure }

/// One-time toast payload for UI listener.
class HomePlanToastMessage {
  const HomePlanToastMessage({
    required this.id,
    required this.tab,
    required this.message,
  });

  /// Unique id used by listenWhen to avoid duplicate toasts.
  final int id;

  /// Which tab produced the message.
  final HomePlanTab tab;

  /// User-friendly message text.
  final String message;
}

/// Small UI-state model for a single tab.
///
/// Why this exists:
/// - Keeps status/error together.
/// - Makes code easier to read than two separate maps.
class HomePlanTabUiState {
  const HomePlanTabUiState({
    required this.status,
    this.errorMessage,
  });

  /// Current lifecycle state for one tab.
  final HomePlanStatus status;

  /// Optional error for one tab.
  final String? errorMessage;

  /// Default state used on first app load.
  factory HomePlanTabUiState.initial() {
    return const HomePlanTabUiState(
      status: HomePlanStatus.initial,
      errorMessage: null,
    );
  }
}

class HomePlanState {
  final HomePlanTab selectedTab;

  /// Explicit UI state per tab.
  ///
  /// This is intentionally verbose so future developers can
  /// understand and debug tab behavior quickly.
  final HomePlanTabUiState dailyTabUiState;
  final HomePlanTabUiState weeklyTabUiState;
  final HomePlanTabUiState monthlyTabUiState;
  final HomePlanTabUiState roamingTabUiState;
  final HomePlanTabUiState roameasyTabUiState;
  final HomePlanTabUiState addOnsTabUiState;
  final HomePlanTabUiState mifiTabUiState;
  final HomePlanTabUiState libertyGlobalTabUiState;

  final List<HomePlanModel> plans;
  final Set<String> expandedPlanIds;

  //  AddOns support (new, existing delete kori নাই)
  final List<HomePlanAddOnModel> addOns;
  final Set<String> selectedAddOnIds;

  /// Dedicated API data for Daily tab (not bound to UI yet).
  final List<DailyPlanModel> dailyApiPlans;

  /// Dedicated API data for Weekly tab (not bound to UI yet).
  final List<WeeklyPlanModel> weeklyApiPlans;

  /// Lightweight API metadata per tab.
  ///
  /// Important:
  /// - This map stores only loading/sync metadata.
  /// - Typed plan lists stay in dedicated fields
  ///   (`dailyApiPlans`, future `weeklyApiPlans`, etc).
  final Map<HomePlanTab, HomePlanTabApiMeta> apiTabMeta;

  /// Time when Daily API data was last synced successfully.
  final DateTime? dailyApiLastSyncedAt;

  /// Time when Weekly API data was last synced successfully.
  final DateTime? weeklyApiLastSyncedAt;

  /// One-time toast effect to be handled by UI listener.
  final HomePlanToastMessage? pendingToast;

  /// Monotonic id generator base for toast events.
  final int toastSequence;

  const HomePlanState({
    required this.selectedTab,
    required this.dailyTabUiState,
    required this.weeklyTabUiState,
    required this.monthlyTabUiState,
    required this.roamingTabUiState,
    required this.roameasyTabUiState,
    required this.addOnsTabUiState,
    required this.mifiTabUiState,
    required this.libertyGlobalTabUiState,
    required this.plans,
    required this.expandedPlanIds,
    required this.addOns,
    required this.selectedAddOnIds,
    required this.dailyApiPlans,
    required this.weeklyApiPlans,
    required this.apiTabMeta,
    required this.toastSequence,
    this.dailyApiLastSyncedAt,
    this.weeklyApiLastSyncedAt,
    this.pendingToast,
  });

  factory HomePlanState.initial() {
    return const HomePlanState(
      selectedTab: HomePlanTab.monthly,
      dailyTabUiState: HomePlanTabUiState(
        status: HomePlanStatus.initial,
        errorMessage: null,
      ),
      weeklyTabUiState: HomePlanTabUiState(
        status: HomePlanStatus.initial,
        errorMessage: null,
      ),
      monthlyTabUiState: HomePlanTabUiState(
        status: HomePlanStatus.initial,
        errorMessage: null,
      ),
      roamingTabUiState: HomePlanTabUiState(
        status: HomePlanStatus.initial,
        errorMessage: null,
      ),
      roameasyTabUiState: HomePlanTabUiState(
        status: HomePlanStatus.initial,
        errorMessage: null,
      ),
      addOnsTabUiState: HomePlanTabUiState(
        status: HomePlanStatus.initial,
        errorMessage: null,
      ),
      mifiTabUiState: HomePlanTabUiState(
        status: HomePlanStatus.initial,
        errorMessage: null,
      ),
      libertyGlobalTabUiState: HomePlanTabUiState(
        status: HomePlanStatus.initial,
        errorMessage: null,
      ),
      plans: [],
      expandedPlanIds: {},
      addOns: [],
      selectedAddOnIds: {},
      dailyApiPlans: [],
      weeklyApiPlans: [],
      apiTabMeta: {},
      pendingToast: null,
      toastSequence: 0,
    );
  }

  HomePlanState copyWith({
    HomePlanTab? selectedTab,
    HomePlanTabUiState? dailyTabUiState,
    HomePlanTabUiState? weeklyTabUiState,
    HomePlanTabUiState? monthlyTabUiState,
    HomePlanTabUiState? roamingTabUiState,
    HomePlanTabUiState? roameasyTabUiState,
    HomePlanTabUiState? addOnsTabUiState,
    HomePlanTabUiState? mifiTabUiState,
    HomePlanTabUiState? libertyGlobalTabUiState,
    List<HomePlanModel>? plans,
    Set<String>? expandedPlanIds,

    // ✅ AddOns
    List<HomePlanAddOnModel>? addOns,
    Set<String>? selectedAddOnIds,
    List<DailyPlanModel>? dailyApiPlans,
    List<WeeklyPlanModel>? weeklyApiPlans,
    Map<HomePlanTab, HomePlanTabApiMeta>? apiTabMeta,
    DateTime? dailyApiLastSyncedAt,
    DateTime? weeklyApiLastSyncedAt,
    HomePlanToastMessage? pendingToast,
    int? toastSequence,
    bool clearPendingToast = false,
  }) {
    return HomePlanState(
      selectedTab: selectedTab ?? this.selectedTab,
      dailyTabUiState: dailyTabUiState ?? this.dailyTabUiState,
      weeklyTabUiState: weeklyTabUiState ?? this.weeklyTabUiState,
      monthlyTabUiState: monthlyTabUiState ?? this.monthlyTabUiState,
      roamingTabUiState: roamingTabUiState ?? this.roamingTabUiState,
      roameasyTabUiState: roameasyTabUiState ?? this.roameasyTabUiState,
      addOnsTabUiState: addOnsTabUiState ?? this.addOnsTabUiState,
      mifiTabUiState: mifiTabUiState ?? this.mifiTabUiState,
      libertyGlobalTabUiState:
          libertyGlobalTabUiState ?? this.libertyGlobalTabUiState,
      plans: plans ?? this.plans,
      expandedPlanIds: expandedPlanIds ?? this.expandedPlanIds,
      addOns: addOns ?? this.addOns,
      selectedAddOnIds: selectedAddOnIds ?? this.selectedAddOnIds,
      dailyApiPlans: dailyApiPlans ?? this.dailyApiPlans,
      weeklyApiPlans: weeklyApiPlans ?? this.weeklyApiPlans,
      apiTabMeta: apiTabMeta ?? this.apiTabMeta,
      dailyApiLastSyncedAt: dailyApiLastSyncedAt ?? this.dailyApiLastSyncedAt,
      weeklyApiLastSyncedAt: weeklyApiLastSyncedAt ?? this.weeklyApiLastSyncedAt,
      pendingToast:
          clearPendingToast ? null : (pendingToast ?? this.pendingToast),
      toastSequence: toastSequence ?? this.toastSequence,
    );
  }

  /// Returns full UI state for a specific tab.
  HomePlanTabUiState uiStateFor(HomePlanTab tab) {
    switch (tab) {
      case HomePlanTab.daily:
        return dailyTabUiState;
      case HomePlanTab.weekly:
        return weeklyTabUiState;
      case HomePlanTab.monthly:
        return monthlyTabUiState;
      case HomePlanTab.roaming:
        return roamingTabUiState;
      case HomePlanTab.roameasy:
        return roameasyTabUiState;
      case HomePlanTab.addOns:
        return addOnsTabUiState;
      case HomePlanTab.mifi:
        return mifiTabUiState;
      case HomePlanTab.libertyGlobal:
        return libertyGlobalTabUiState;
    }
  }

  /// Status resolver for one tab.
  HomePlanStatus statusFor(HomePlanTab tab) {
    return uiStateFor(tab).status;
  }

  /// Error resolver for one tab.
  String? errorFor(HomePlanTab tab) {
    return uiStateFor(tab).errorMessage;
  }

  /// Convenience getter used by selected-tab UI widgets.
  HomePlanStatus get selectedTabStatus => statusFor(selectedTab);

  /// Convenience getter used by selected-tab error widgets.
  String? get selectedTabErrorMessage => errorFor(selectedTab);
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
