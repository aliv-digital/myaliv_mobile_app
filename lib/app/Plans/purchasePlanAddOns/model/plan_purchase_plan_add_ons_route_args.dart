import '../../PlanScreen/models/base_plan_model.dart';

class PlanPurchasePlanAddOnsRouteArgs {
  const PlanPurchasePlanAddOnsRouteArgs({
    required this.selectedApiPlan,
    this.selectedIndex,
  });

  final BasePlanModel selectedApiPlan;
  final int? selectedIndex;
}
