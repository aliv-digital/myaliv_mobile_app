import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_on_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';

/// Status of plan fetching
enum PlansStatus {
  /// Initial state
  initial,

  /// Loading plans
  loading,

  /// Plans loaded successfully
  success,

  /// Failed to load plans
  failure,
}

/// Toast message for error display
class PlansToastMessage {
  const PlansToastMessage({
    required this.id,
    required this.message,
  });

  final int id;
  final String message;
}

/// State for Plans Cubit
///
/// This state matches HomePlanState field names for UI compatibility.
class PlansState extends Equatable {
  const PlansState({
    this.status = PlansStatus.initial,
    this.selectedTab = HomePlanTab.monthly,
    // Plan data - SAME NAMES as HomePlanState
    this.dailyApiPlans = const [],
    this.weeklyApiPlans = const [],
    this.monthlyApiPlans = const [],
    this.roamingApiPlans = const [],
    this.roamEasyApiPlans = const [],
    this.mifiApiPlans = const [],
    this.libertyGlobalApiPlans = const [],
    this.postpaidRoamingApiPlans = const [],
    // Add-ons - SAME NAMES
    this.addOns = const [],
    this.addOnsApiPrimaryPlans = const [],
    this.selectedAddOnIds = const {},
    // UI state - SAME NAMES
    this.expandedPlanIds = const {},
    this.isPurchaseModalOpen = false,
    // Toast - SAME PATTERN
    this.pendingToast,
    this.toastSequence = 0,
    // Timestamps - SAME NAMES
    this.lastFetchedAt,
    this.addOnsApiLastSyncedAt,
    this.errorMessage,
  });

  final PlansStatus status;
  final HomePlanTab selectedTab;

  // Plan data (SAME field names as HomePlanState)
  final List<BasePlanModel> dailyApiPlans;
  final List<BasePlanModel> weeklyApiPlans;
  final List<BasePlanModel> monthlyApiPlans;
  final List<BasePlanModel> roamingApiPlans;
  final List<BasePlanModel> roamEasyApiPlans;
  final List<BasePlanModel> mifiApiPlans;
  final List<BasePlanModel> libertyGlobalApiPlans;
  final List<HomePlansPostPaidPlanModel> postpaidRoamingApiPlans;

  // Add-ons (SAME field names)
  final List<HomePlanAddOnModel> addOns;
  final List<BasePlanModel> addOnsApiPrimaryPlans;
  final Set<String> selectedAddOnIds;

  // UI state (SAME field names)
  final Set<String> expandedPlanIds;
  final bool isPurchaseModalOpen;

  // Toast (SAME pattern)
  final PlansToastMessage? pendingToast;
  final int toastSequence;

  // Timestamps
  final DateTime? lastFetchedAt;
  final DateTime? addOnsApiLastSyncedAt;
  final String? errorMessage;

  // ═══════════════════════════════════════════════════════════════════
  // GETTERS (SAME as HomePlanState - UI depends on these)
  // ═══════════════════════════════════════════════════════════════════

  /// Status for selected tab (UI uses this)
  PlansStatus get selectedTabStatus => status;

  /// Error message for selected tab (UI uses this)
  String? get selectedTabErrorMessage => errorMessage;

  /// Earliest primary plan for active card (UI uses this)
  BasePlanModel? get earliestAddOnsPrimaryPlan {
    if (addOnsApiPrimaryPlans.isEmpty) return null;
    return addOnsApiPrimaryPlans.first;
  }

  /// Check if any data exists
  bool get hasData =>
      dailyApiPlans.isNotEmpty ||
      weeklyApiPlans.isNotEmpty ||
      monthlyApiPlans.isNotEmpty ||
      roamingApiPlans.isNotEmpty ||
      roamEasyApiPlans.isNotEmpty ||
      mifiApiPlans.isNotEmpty ||
      libertyGlobalApiPlans.isNotEmpty ||
      postpaidRoamingApiPlans.isNotEmpty ||
      addOns.isNotEmpty;

  bool get isLoading => status == PlansStatus.loading;
  bool get isSuccess => status == PlansStatus.success;
  bool get isFailure => status == PlansStatus.failure;
  bool get isInitial => status == PlansStatus.initial;

  // ═══════════════════════════════════════════════════════════════════
  // COPY WITH
  // ═══════════════════════════════════════════════════════════════════

  PlansState copyWith({
    PlansStatus? status,
    HomePlanTab? selectedTab,
    List<BasePlanModel>? dailyApiPlans,
    List<BasePlanModel>? weeklyApiPlans,
    List<BasePlanModel>? monthlyApiPlans,
    List<BasePlanModel>? roamingApiPlans,
    List<BasePlanModel>? roamEasyApiPlans,
    List<BasePlanModel>? mifiApiPlans,
    List<BasePlanModel>? libertyGlobalApiPlans,
    List<HomePlansPostPaidPlanModel>? postpaidRoamingApiPlans,
    List<HomePlanAddOnModel>? addOns,
    List<BasePlanModel>? addOnsApiPrimaryPlans,
    Set<String>? selectedAddOnIds,
    Set<String>? expandedPlanIds,
    bool? isPurchaseModalOpen,
    PlansToastMessage? pendingToast,
    int? toastSequence,
    DateTime? lastFetchedAt,
    DateTime? addOnsApiLastSyncedAt,
    String? errorMessage,
    bool clearPendingToast = false,
  }) {
    return PlansState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      dailyApiPlans: dailyApiPlans ?? this.dailyApiPlans,
      weeklyApiPlans: weeklyApiPlans ?? this.weeklyApiPlans,
      monthlyApiPlans: monthlyApiPlans ?? this.monthlyApiPlans,
      roamingApiPlans: roamingApiPlans ?? this.roamingApiPlans,
      roamEasyApiPlans: roamEasyApiPlans ?? this.roamEasyApiPlans,
      mifiApiPlans: mifiApiPlans ?? this.mifiApiPlans,
      libertyGlobalApiPlans: libertyGlobalApiPlans ?? this.libertyGlobalApiPlans,
      postpaidRoamingApiPlans:
          postpaidRoamingApiPlans ?? this.postpaidRoamingApiPlans,
      addOns: addOns ?? this.addOns,
      addOnsApiPrimaryPlans:
          addOnsApiPrimaryPlans ?? this.addOnsApiPrimaryPlans,
      selectedAddOnIds: selectedAddOnIds ?? this.selectedAddOnIds,
      expandedPlanIds: expandedPlanIds ?? this.expandedPlanIds,
      isPurchaseModalOpen: isPurchaseModalOpen ?? this.isPurchaseModalOpen,
      pendingToast:
          clearPendingToast ? null : (pendingToast ?? this.pendingToast),
      toastSequence: toastSequence ?? this.toastSequence,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      addOnsApiLastSyncedAt:
          addOnsApiLastSyncedAt ?? this.addOnsApiLastSyncedAt,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedTab,
        dailyApiPlans,
        weeklyApiPlans,
        monthlyApiPlans,
        roamingApiPlans,
        roamEasyApiPlans,
        mifiApiPlans,
        libertyGlobalApiPlans,
        postpaidRoamingApiPlans,
        addOns,
        addOnsApiPrimaryPlans,
        selectedAddOnIds,
        expandedPlanIds,
        isPurchaseModalOpen,
        pendingToast,
        toastSequence,
        lastFetchedAt,
        addOnsApiLastSyncedAt,
        errorMessage,
      ];
}
