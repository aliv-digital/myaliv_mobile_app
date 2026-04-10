import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_on_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_ons_primary_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/daily_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/liberty_global_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/monthly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/mifi_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roaming_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roameasy_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/weekly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';

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
  final HomePlanTabUiState postpaidRoamingTabUiState; // NEW for postpaid

  final List<HomePlanModel> plans;
  final Set<String> expandedPlanIds;

  //  AddOns support (new, existing delete kori নাই)
  final List<HomePlanAddOnModel> addOns;
  final Set<String> selectedAddOnIds;

  /// Dedicated API data for Add-ons tab `PrimaryPlans`.
  ///
  /// Repository keeps this list sorted by earliest `StartDate`, so
  /// `addOnsApiPrimaryPlans.first` is the primary plan we want to show first.
  final List<AddOnsPrimaryPlanModel> addOnsApiPrimaryPlans;

  /// Dedicated API data for Daily tab (not bound to UI yet).
  final List<DailyPlanModel> dailyApiPlans;

  /// Dedicated API data for Weekly tab (not bound to UI yet).
  final List<WeeklyPlanModel> weeklyApiPlans;

  /// Dedicated API data for Monthly tab (not bound to UI yet).
  final List<MonthlyPlanModel> monthlyApiPlans;

  /// Dedicated API data for Roaming tab (not bound to UI yet).
  final List<RoamingPlanModel> roamingApiPlans;

  /// Dedicated API data for RoamEasy tab (not bound to UI yet).
  final List<RoamEasyPlanModel> roamEasyApiPlans;

  /// Dedicated API data for MiFi tab (not bound to UI yet).
  final List<MifiPlanModel> mifiApiPlans;

  /// Dedicated API data for Liberty Global tab (not bound to UI yet).
  final List<LibertyGlobalPlanModel> libertyGlobalApiPlans;

  /// Dedicated API data for Postpaid Roaming tab (NEW).
  final List<HomePlansPostPaidPlanModel> postpaidRoamingApiPlans;

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

  /// Time when Monthly API data was last synced successfully.
  final DateTime? monthlyApiLastSyncedAt;

  /// Time when Roaming API data was last synced successfully.
  final DateTime? roamingApiLastSyncedAt;

  /// Time when RoamEasy API data was last synced successfully.
  final DateTime? roamEasyApiLastSyncedAt;

  /// Time when MiFi API data was last synced successfully.
  final DateTime? mifiApiLastSyncedAt;

  /// Time when Liberty Global API data was last synced successfully.
  final DateTime? libertyGlobalApiLastSyncedAt;

  /// Time when Add-ons bundles API data was last synced successfully.
  final DateTime? addOnsApiLastSyncedAt;

  /// Time when Postpaid Roaming API data was last synced successfully (NEW).
  final DateTime? postpaidRoamingApiLastSyncedAt;

  /// One-time toast effect to be handled by UI listener.
  final HomePlanToastMessage? pendingToast;

  /// Monotonic id generator base for toast events.
  final int toastSequence;

  /// Tracks if a purchase modal is currently open to prevent spam-clicking.
  /// Set to true when opening purchase bottom sheet, cleared when it closes.
  final bool isPurchaseModalOpen;

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
    required this.postpaidRoamingTabUiState, // NEW
    required this.plans,
    required this.expandedPlanIds,
    required this.addOns,
    required this.selectedAddOnIds,
    required this.addOnsApiPrimaryPlans,
    required this.dailyApiPlans,
    required this.weeklyApiPlans,
    required this.monthlyApiPlans,
    required this.roamingApiPlans,
    required this.roamEasyApiPlans,
    required this.mifiApiPlans,
    required this.libertyGlobalApiPlans,
    required this.postpaidRoamingApiPlans, // NEW
    required this.apiTabMeta,
    required this.toastSequence,
    required this.isPurchaseModalOpen,
    this.dailyApiLastSyncedAt,
    this.weeklyApiLastSyncedAt,
    this.monthlyApiLastSyncedAt,
    this.roamingApiLastSyncedAt,
    this.roamEasyApiLastSyncedAt,
    this.mifiApiLastSyncedAt,
    this.libertyGlobalApiLastSyncedAt,
    this.addOnsApiLastSyncedAt,
    this.postpaidRoamingApiLastSyncedAt, // NEW
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
      postpaidRoamingTabUiState: HomePlanTabUiState( // NEW
        status: HomePlanStatus.initial,
        errorMessage: null,
      ),
      plans: [],
      expandedPlanIds: {},
      addOns: [],
      selectedAddOnIds: {},
      addOnsApiPrimaryPlans: [],
      dailyApiPlans: [],
      weeklyApiPlans: [],
      monthlyApiPlans: [],
      roamingApiPlans: [],
      roamEasyApiPlans: [],
      mifiApiPlans: [],
      libertyGlobalApiPlans: [],
      postpaidRoamingApiPlans: [], // NEW
      apiTabMeta: {},
      pendingToast: null,
      toastSequence: 0,
      isPurchaseModalOpen: false,
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
    HomePlanTabUiState? postpaidRoamingTabUiState, // NEW
    List<HomePlanModel>? plans,
    Set<String>? expandedPlanIds,

    // ✅ AddOns
    List<HomePlanAddOnModel>? addOns,
    Set<String>? selectedAddOnIds,
    List<AddOnsPrimaryPlanModel>? addOnsApiPrimaryPlans,
    List<DailyPlanModel>? dailyApiPlans,
    List<WeeklyPlanModel>? weeklyApiPlans,
    List<MonthlyPlanModel>? monthlyApiPlans,
    List<RoamingPlanModel>? roamingApiPlans,
    List<RoamEasyPlanModel>? roamEasyApiPlans,
    List<MifiPlanModel>? mifiApiPlans,
    List<LibertyGlobalPlanModel>? libertyGlobalApiPlans,
    List<HomePlansPostPaidPlanModel>? postpaidRoamingApiPlans, // NEW
    Map<HomePlanTab, HomePlanTabApiMeta>? apiTabMeta,
    DateTime? dailyApiLastSyncedAt,
    DateTime? weeklyApiLastSyncedAt,
    DateTime? monthlyApiLastSyncedAt,
    DateTime? roamingApiLastSyncedAt,
    DateTime? roamEasyApiLastSyncedAt,
    DateTime? mifiApiLastSyncedAt,
    DateTime? libertyGlobalApiLastSyncedAt,
    DateTime? addOnsApiLastSyncedAt,
    DateTime? postpaidRoamingApiLastSyncedAt, // NEW
    HomePlanToastMessage? pendingToast,
    int? toastSequence,
    bool? isPurchaseModalOpen,
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
      postpaidRoamingTabUiState: // NEW
          postpaidRoamingTabUiState ?? this.postpaidRoamingTabUiState,
      plans: plans ?? this.plans,
      expandedPlanIds: expandedPlanIds ?? this.expandedPlanIds,
      addOns: addOns ?? this.addOns,
      selectedAddOnIds: selectedAddOnIds ?? this.selectedAddOnIds,
      addOnsApiPrimaryPlans:
          addOnsApiPrimaryPlans ?? this.addOnsApiPrimaryPlans,
      dailyApiPlans: dailyApiPlans ?? this.dailyApiPlans,
      weeklyApiPlans: weeklyApiPlans ?? this.weeklyApiPlans,
      monthlyApiPlans: monthlyApiPlans ?? this.monthlyApiPlans,
      roamingApiPlans: roamingApiPlans ?? this.roamingApiPlans,
      roamEasyApiPlans: roamEasyApiPlans ?? this.roamEasyApiPlans,
      mifiApiPlans: mifiApiPlans ?? this.mifiApiPlans,
      libertyGlobalApiPlans:
          libertyGlobalApiPlans ?? this.libertyGlobalApiPlans,
      postpaidRoamingApiPlans: // NEW
          postpaidRoamingApiPlans ?? this.postpaidRoamingApiPlans,
      apiTabMeta: apiTabMeta ?? this.apiTabMeta,
      dailyApiLastSyncedAt: dailyApiLastSyncedAt ?? this.dailyApiLastSyncedAt,
      weeklyApiLastSyncedAt:
          weeklyApiLastSyncedAt ?? this.weeklyApiLastSyncedAt,
      monthlyApiLastSyncedAt:
          monthlyApiLastSyncedAt ?? this.monthlyApiLastSyncedAt,
      roamingApiLastSyncedAt:
          roamingApiLastSyncedAt ?? this.roamingApiLastSyncedAt,
      roamEasyApiLastSyncedAt:
          roamEasyApiLastSyncedAt ?? this.roamEasyApiLastSyncedAt,
      mifiApiLastSyncedAt: mifiApiLastSyncedAt ?? this.mifiApiLastSyncedAt,
      libertyGlobalApiLastSyncedAt:
          libertyGlobalApiLastSyncedAt ?? this.libertyGlobalApiLastSyncedAt,
      addOnsApiLastSyncedAt:
          addOnsApiLastSyncedAt ?? this.addOnsApiLastSyncedAt,
      postpaidRoamingApiLastSyncedAt: // NEW
          postpaidRoamingApiLastSyncedAt ?? this.postpaidRoamingApiLastSyncedAt,
      pendingToast:
          clearPendingToast ? null : (pendingToast ?? this.pendingToast),
      toastSequence: toastSequence ?? this.toastSequence,
      isPurchaseModalOpen: isPurchaseModalOpen ?? this.isPurchaseModalOpen,
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
      case HomePlanTab.postpaidRoaming: // NEW
        return postpaidRoamingTabUiState;
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

  /// Earliest primary plan prepared for Add-ons tab UI.
  AddOnsPrimaryPlanModel? get earliestAddOnsPrimaryPlan {
    if (addOnsApiPrimaryPlans.isEmpty) return null;
    return addOnsApiPrimaryPlans.first;
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
