import '../models/plan_model.dart';
import '../models/add_on_model.dart';
import '../repository/guest_purchase_plan_repository.dart';

enum GuestPurchasePlanStatus { initial, loading, loaded, failure }

class GuestPurchasePlanState {
  final GuestPurchasePlanStatus status;
  final PlanTab selectedTab;

  final List<PlanModel> plans;
  final Set<String> expandedPlanIds;

  // ✅ AddOns support (new, existing delete kori নাই)
  final List<AddOnModel> addOns;
  final Set<String> selectedAddOnIds;

  final String? errorMessage;

  const GuestPurchasePlanState({
    required this.status,
    required this.selectedTab,
    required this.plans,
    required this.expandedPlanIds,
    required this.addOns,
    required this.selectedAddOnIds,
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
    List<PlanModel>? plans,
    Set<String>? expandedPlanIds,

    // ✅ AddOns
    List<AddOnModel>? addOns,
    Set<String>? selectedAddOnIds,

    String? errorMessage,
  }) {
    return GuestPurchasePlanState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      plans: plans ?? this.plans,
      expandedPlanIds: expandedPlanIds ?? this.expandedPlanIds,

      addOns: addOns ?? this.addOns,
      selectedAddOnIds: selectedAddOnIds ?? this.selectedAddOnIds,

      errorMessage: errorMessage,
    );
  }
}
