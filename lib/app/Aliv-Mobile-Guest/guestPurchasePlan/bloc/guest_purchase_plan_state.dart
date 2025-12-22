import '../models/plan_model.dart';
import '../repository/guest_purchase_plan_repository.dart';

enum GuestPurchasePlanStatus { initial, loading, loaded, failure }

class GuestPurchasePlanState {
  final GuestPurchasePlanStatus status;
  final PlanTab selectedTab;

  final List<PlanModel> plans;
  final Set<String> expandedPlanIds;

  final String? errorMessage;

  const GuestPurchasePlanState({
    required this.status,
    required this.selectedTab,
    required this.plans,
    required this.expandedPlanIds,
    this.errorMessage,
  });

  factory GuestPurchasePlanState.initial() {
    return const GuestPurchasePlanState(
      status: GuestPurchasePlanStatus.initial,
      selectedTab: PlanTab.monthly,
      plans: [],
      expandedPlanIds: {},
    );
  }

  GuestPurchasePlanState copyWith({
    GuestPurchasePlanStatus? status,
    PlanTab? selectedTab,
    List<PlanModel>? plans,
    Set<String>? expandedPlanIds,
    String? errorMessage,
  }) {
    return GuestPurchasePlanState(
      status: status ?? this.status,
      selectedTab: selectedTab ?? this.selectedTab,
      plans: plans ?? this.plans,
      expandedPlanIds: expandedPlanIds ?? this.expandedPlanIds,
      errorMessage: errorMessage,
    );
  }
}
