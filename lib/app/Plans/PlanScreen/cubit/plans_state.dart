import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_on_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';

/// Optimistically-injected active plan shown immediately after a successful
/// purchase, before the real /bundles refresh returns updated data.
///
/// Intentionally NOT serialised — it is ephemeral and cleared as soon as
/// the next real [PlansStatus.success] emit lands.
typedef OptimisticActivePlan = BasePlanModel;

/// Status of plan fetching
enum PlansStatus {
  /// Initial state
  initial,

  /// Loading plans (no data yet — show skeleton)
  loading,

  /// Plans loaded successfully
  success,

  /// Failed to load plans
  failure,

  /// Cache is showing, silent background refresh in progress
  refreshing,
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
    this.secondaryPlans = const [],
    this.standAlonePlans = const [],
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
    // Optimistic state — not persisted, cleared on next real success
    this.optimisticActivePlan,
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

  /// Secondary plans from bundles API. Counted alongside primary plans for
  /// bucket-usage aggregation (see [activePlansForBucketUsage]).
  final List<BasePlanModel> secondaryPlans;

  /// Stand-alone plans from bundles API (travel20/30/50 etc.).
  /// Used as the source for the "future plan" UI for both prepaid and postpaid.
  final List<BasePlanModel> standAlonePlans;

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

  /// Plans that drive the home screen's "active plan usage remaining" cards.
  ///
  /// Returns the union of primary and secondary plans, deduplicated by
  /// `planId` with first-occurrence wins. Stand-alone plans (roameasy /
  /// travel20) are intentionally excluded — they are surfaced via
  /// [standAlonePlansForBucketUsage] so the calculator can subtract their
  /// contributions from any shared buckets (e.g. roameasy's local 200 MB
  /// "data" allotment should not inflate liberty40's "data" row).
  List<BasePlanModel> get activePlansForBucketUsage {
    final union = <BasePlanModel>[];
    final seenIds = <String>{};

    for (final plan in addOnsApiPrimaryPlans) {
      if (seenIds.add(plan.planId)) union.add(plan);
    }
    for (final plan in secondaryPlans) {
      if (seenIds.add(plan.planId)) union.add(plan);
    }

    return List.unmodifiable(union);
  }

  /// Stand-alone plans used to compute the roaming bucket usage view-model.
  ///
  /// When the bundles API returns the same `planId` more than once (one row
  /// per purchase — e.g. an active travel30 7-day plus a future-dated
  /// repurchase), entries are merged into a single plan spanning the
  /// **earliest start** and **latest end** across the group. The Usage tab's
  /// roaming card then renders one card per `planId`, with the date range
  /// covering all paid purchases. The API-side
  /// `BucketUsageItem.totalInitialAmount` already aggregates allowances
  /// across purchases, so counting the plan once still yields the correct
  /// bucket totals.
  List<BasePlanModel> get standAlonePlansForBucketUsage {
    if (standAlonePlans.isEmpty) return const <BasePlanModel>[];

    final groupsByPlanId = <String, List<BasePlanModel>>{};
    final planIdOrder = <String>[];
    for (final plan in standAlonePlans) {
      if (!groupsByPlanId.containsKey(plan.planId)) {
        planIdOrder.add(plan.planId);
      }
      groupsByPlanId.putIfAbsent(plan.planId, () => []).add(plan);
    }

    final merged = <BasePlanModel>[];
    for (final planId in planIdOrder) {
      final group = groupsByPlanId[planId]!;
      if (group.length == 1) {
        merged.add(group.first);
        continue;
      }

      BasePlanModel earliestStart = group.first;
      BasePlanModel latestEnd = group.first;
      for (final plan in group) {
        final candidateStart = plan.startDateTime;
        final currentStart = earliestStart.startDateTime;
        if (candidateStart != null &&
            (currentStart == null || candidateStart.isBefore(currentStart))) {
          earliestStart = plan;
        }
        final candidateEnd = plan.endDateTime;
        final currentEnd = latestEnd.endDateTime;
        if (candidateEnd != null &&
            (currentEnd == null || candidateEnd.isAfter(currentEnd))) {
          latestEnd = plan;
        }
      }

      merged.add(earliestStart.copyWith(endDate: latestEnd.endDate));
    }

    return List.unmodifiable(merged);
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
  bool get isRefreshing => status == PlansStatus.refreshing;

  // ═══════════════════════════════════════════════════════════════════
  // SERIALIZATION (HydratedCubit persistence)
  // Only data fields are cached — transient UI state is always reset.
  // ═══════════════════════════════════════════════════════════════════

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dailyApiPlans': dailyApiPlans.map((p) => p.toJson()).toList(),
      'weeklyApiPlans': weeklyApiPlans.map((p) => p.toJson()).toList(),
      'monthlyApiPlans': monthlyApiPlans.map((p) => p.toJson()).toList(),
      'roamingApiPlans': roamingApiPlans.map((p) => p.toJson()).toList(),
      'roamEasyApiPlans': roamEasyApiPlans.map((p) => p.toJson()).toList(),
      'mifiApiPlans': mifiApiPlans.map((p) => p.toJson()).toList(),
      'libertyGlobalApiPlans':
          libertyGlobalApiPlans.map((p) => p.toJson()).toList(),
      'postpaidRoamingApiPlans':
          postpaidRoamingApiPlans.map((p) => p.toJson()).toList(),
      'addOns': addOns.map((a) => a.toJson()).toList(),
      'addOnsApiPrimaryPlans':
          addOnsApiPrimaryPlans.map((p) => p.toJson()).toList(),
      'secondaryPlans': secondaryPlans.map((p) => p.toJson()).toList(),
      'standAlonePlans': standAlonePlans.map((p) => p.toJson()).toList(),
      'lastFetchedAt': lastFetchedAt?.toIso8601String(),
      'addOnsApiLastSyncedAt': addOnsApiLastSyncedAt?.toIso8601String(),
    };
  }

  factory PlansState.fromJson(Map<String, dynamic> json) {
    final daily = _parseList(json['dailyApiPlans'], BasePlanModel.fromJson);
    final weekly = _parseList(json['weeklyApiPlans'], BasePlanModel.fromJson);
    final monthly = _parseList(json['monthlyApiPlans'], BasePlanModel.fromJson);
    final roaming = _parseList(json['roamingApiPlans'], BasePlanModel.fromJson);
    final roamEasy =
        _parseList(json['roamEasyApiPlans'], BasePlanModel.fromJson);
    final mifi = _parseList(json['mifiApiPlans'], BasePlanModel.fromJson);
    final libertyGlobal =
        _parseList(json['libertyGlobalApiPlans'], BasePlanModel.fromJson);
    final postpaidRoaming = _parseList(
        json['postpaidRoamingApiPlans'], HomePlansPostPaidPlanModel.fromJson);
    final addOns =
        _parseList(json['addOns'], HomePlanAddOnModel.fromJson);
    final primaryPlans =
        _parseList(json['addOnsApiPrimaryPlans'], BasePlanModel.fromJson);
    final secondary =
        _parseList(json['secondaryPlans'], BasePlanModel.fromJson);
    final standAlone =
        _parseList(json['standAlonePlans'], BasePlanModel.fromJson);

    final hasData = daily.isNotEmpty ||
        weekly.isNotEmpty ||
        monthly.isNotEmpty ||
        roaming.isNotEmpty ||
        roamEasy.isNotEmpty ||
        mifi.isNotEmpty ||
        libertyGlobal.isNotEmpty ||
        postpaidRoaming.isNotEmpty ||
        addOns.isNotEmpty;

    return PlansState(
      status: hasData ? PlansStatus.success : PlansStatus.initial,
      dailyApiPlans: daily,
      weeklyApiPlans: weekly,
      monthlyApiPlans: monthly,
      roamingApiPlans: roaming,
      roamEasyApiPlans: roamEasy,
      mifiApiPlans: mifi,
      libertyGlobalApiPlans: libertyGlobal,
      postpaidRoamingApiPlans: postpaidRoaming,
      addOns: addOns,
      addOnsApiPrimaryPlans: primaryPlans,
      secondaryPlans: secondary,
      standAlonePlans: standAlone,
      lastFetchedAt: json['lastFetchedAt'] != null
          ? DateTime.tryParse(json['lastFetchedAt'] as String)
          : null,
      addOnsApiLastSyncedAt: json['addOnsApiLastSyncedAt'] != null
          ? DateTime.tryParse(json['addOnsApiLastSyncedAt'] as String)
          : null,
    );
  }

  static List<T> _parseList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw is! List) return const [];
    final result = <T>[];
    for (int i = 0; i < raw.length; i++) {
      final item = raw[i];
      if (item is Map<String, dynamic>) {
        result.add(fromJson(item));
      } else {
        assert(false, 'PlansState._parseList: skipped invalid item[$i]: $item');
      }
    }
    return List.unmodifiable(result);
  }

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
    List<BasePlanModel>? secondaryPlans,
    List<BasePlanModel>? standAlonePlans,
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
      secondaryPlans: secondaryPlans ?? this.secondaryPlans,
      standAlonePlans: standAlonePlans ?? this.standAlonePlans,
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
        secondaryPlans,
        standAlonePlans,
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
