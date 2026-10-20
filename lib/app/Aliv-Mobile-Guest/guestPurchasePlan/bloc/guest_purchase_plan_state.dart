import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

import '../models/add_on_model.dart';
import '../models/plan_model.dart';
import '../repository/guest_purchase_plan_repository.dart';

enum GuestPurchasePlanStatus { initial, loading, loaded, failure }

class GuestPurchasePlanState {
  final GuestPurchasePlanStatus status;
  final PlanTab selectedTab;

  final List<GuestPlanDisplayModel> plans;
  final Set<String> expandedPlanIds;

  // ✅ AddOns support (new, existing delete kori নাই)
  final List<AddOnModel> addOns;
  final Set<String> selectedAddOnIds;

  // Bundles from /Guest/existingplans — same field names as prepaid
  // PlansState so the getters below are a direct copy.
  final List<BasePlanModel> addOnsApiPrimaryPlans;
  final List<BasePlanModel> secondaryPlans;
  final List<BasePlanModel> standAlonePlans;

  /// The primary plan the user tapped in a catalog tab — drives the red
  /// "new active plan will be" card and the activate-now sheet copy.
  final BasePlanModel? selectedPrimaryPlan;

  /// True while the parallel /Guest/existingplans request is in flight,
  /// so the add-ons tab can hold off on rendering the "no active plan"
  /// fallback before the data arrives.
  final bool isLoadingBundles;

  final String? errorMessage;

  const GuestPurchasePlanState({
    required this.status,
    required this.selectedTab,
    required this.plans,
    required this.expandedPlanIds,
    required this.addOns,
    required this.selectedAddOnIds,
    this.addOnsApiPrimaryPlans = const [],
    this.secondaryPlans = const [],
    this.standAlonePlans = const [],
    this.selectedPrimaryPlan,
    this.isLoadingBundles = false,
    this.errorMessage,
  });

  factory GuestPurchasePlanState.initial() {
    return const GuestPurchasePlanState(
      status: GuestPurchasePlanStatus.initial,
      selectedTab: PlanTab.monthly,
      plans: [],
      expandedPlanIds: {},
      addOns: [],
      selectedAddOnIds: {},
    );
  }

  GuestPurchasePlanState copyWith({
    GuestPurchasePlanStatus? status,
    PlanTab? selectedTab,
    List<GuestPlanDisplayModel>? plans,
    Set<String>? expandedPlanIds,

    // ✅ AddOns
    List<AddOnModel>? addOns,
    Set<String>? selectedAddOnIds,

    // Bundles
    List<BasePlanModel>? addOnsApiPrimaryPlans,
    List<BasePlanModel>? secondaryPlans,
    List<BasePlanModel>? standAlonePlans,
    BasePlanModel? selectedPrimaryPlan,
    bool clearSelectedPrimaryPlan = false,
    bool? isLoadingBundles,

    String? errorMessage,
  }) {
    return GuestPurchasePlanState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      plans: plans ?? this.plans,
      expandedPlanIds: expandedPlanIds ?? this.expandedPlanIds,
      addOns: addOns ?? this.addOns,
      selectedAddOnIds: selectedAddOnIds ?? this.selectedAddOnIds,
      addOnsApiPrimaryPlans:
          addOnsApiPrimaryPlans ?? this.addOnsApiPrimaryPlans,
      secondaryPlans: secondaryPlans ?? this.secondaryPlans,
      standAlonePlans: standAlonePlans ?? this.standAlonePlans,
      selectedPrimaryPlan: clearSelectedPrimaryPlan
          ? null
          : (selectedPrimaryPlan ?? this.selectedPrimaryPlan),
      isLoadingBundles: isLoadingBundles ?? this.isLoadingBundles,
      errorMessage: errorMessage,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Getters mirroring prepaid PlansState (same names + semantics)
  // ═══════════════════════════════════════════════════════════════════

  /// The plan shown on the active-plan card. Guest has no optimistic
  /// post-purchase state, so this just returns the first entry from the
  /// live /Guest/existingplans response.
  BasePlanModel? get earliestAddOnsPrimaryPlan =>
      addOnsApiPrimaryPlans.isEmpty ? null : addOnsApiPrimaryPlans.first;

  /// Mirrors prepaid [PlansState.effectivePrimaryPlans] — guest has no
  /// optimistic plan so this is just the raw list.
  List<BasePlanModel> get effectivePrimaryPlans => addOnsApiPrimaryPlans;

  /// Latest end-date across every known primary plan. Used by the
  /// future-plan branch (Row 4) of the activate-now sheet to compute
  /// the chained start date for a new primary.
  DateTime? get latestPrimaryPlanEndDate {
    final ends = effectivePrimaryPlans
        .map((p) => p.endDateTime)
        .whereType<DateTime>()
        .toList(growable: false);
    if (ends.isEmpty) return null;
    return ends.reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// Latest end-date across every purchased plan — primary, secondary,
  /// AND stand-alone. Used by Row 5 ("already queued, schedule only")
  /// so the next primary waits until every current purchase (including
  /// standalones like travel30) has ended. Mirrors prepaid
  /// [PlansState.latestPurchasedPlanEndDate].
  DateTime? get latestPurchasedPlanEndDate {
    DateTime? latest;
    final allPlans = <BasePlanModel>[
      ...effectivePrimaryPlans,
      ...standAlonePlans,
      ...secondaryPlans,
    ];
    for (final plan in allPlans) {
      final end = plan.endDateTime;
      if (end != null && (latest == null || end.isAfter(latest))) {
        latest = end;
      }
    }
    return latest;
  }

  /// Primary-only counterpart of hasFuturePlans: standalone plans never
  /// decide how another primary purchase is offered.
  bool get hasFuturePrimaryPlans {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return effectivePrimaryPlans.any((plan) {
      final start = plan.startDateTime;
      if (start == null) return false;
      return DateTime(start.year, start.month, start.day).isAfter(today);
    });
  }

  /// Future primary plans do not represent a current plan being replaced.
  bool get hasActivePrimaryPlan {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return effectivePrimaryPlans.any((plan) {
      final start = plan.startDateTime;
      if (start != null &&
          DateTime(start.year, start.month, start.day).isAfter(today)) {
        return false;
      }
      final end = plan.endDateTime;
      return end == null || end.isAfter(now);
    });
  }

  /// Purchase sheet row 4: replace the active primary now or schedule it.
  bool get hasActivePrimaryWithoutFuturePrimaryPlans =>
      hasActivePrimaryPlan && !hasFuturePrimaryPlans;

  /// Purchase sheet row 5: a primary is already queued, so a new primary
  /// can only be scheduled. Standalone plans do not affect this.
  bool get hasActivePrimaryWithFuturePrimaryPlans =>
      hasActivePrimaryPlan && hasFuturePrimaryPlans;
}
