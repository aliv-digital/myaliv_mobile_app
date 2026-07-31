import '../../PlanScreen/models/base_plan_model.dart';

class PlanPurchasePlanAddOnsRouteArgs {
  const PlanPurchasePlanAddOnsRouteArgs({
    required this.selectedApiPlan,
    this.selectedIndex,
    this.forceNow = false,
    this.activePrimaryPlan,
  });

  final BasePlanModel? selectedApiPlan;
  final int? selectedIndex;
  final bool forceNow;

  /// The currently active primary plan on the account, passed from PlansCubit.
  /// Null when the account has no active plan.
  final BasePlanModel? activePrimaryPlan;
}
