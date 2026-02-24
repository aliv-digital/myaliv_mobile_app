import '../models/plan_model.dart';
import '../models/add_on_model.dart';
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

  const HomePlanState({
    required this.status,
    required this.selectedTab,
    required this.plans,
    required this.expandedPlanIds,
    required this.addOns,
    required this.selectedAddOnIds,
    this.errorMessage,
  });

  factory HomePlanState.initial() {
    return const HomePlanState(
      status: HomePlanStatus.initial,
      selectedTab: HomePlanTab.monthly,
      plans: [],
      expandedPlanIds: {},
      addOns: [],
      selectedAddOnIds: {},
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
  }) {
    return HomePlanState(
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
