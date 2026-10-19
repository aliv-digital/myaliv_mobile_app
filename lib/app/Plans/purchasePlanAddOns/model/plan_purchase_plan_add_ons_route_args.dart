import '../../PlanScreen/models/base_plan_model.dart';
import '../../PlanScreen/models/plan_purchase_context.dart';

class PlanPurchasePlanAddOnsRouteArgs {
  const PlanPurchasePlanAddOnsRouteArgs({
    required this.selectedApiPlan,
    this.selectedIndex,
    this.forceNow = false,
    this.activePrimaryPlan,
    this.purchaseContext = PlanPurchaseContext.regular,
  });

  final BasePlanModel? selectedApiPlan;
  final int? selectedIndex;
  final bool forceNow;
  final PlanPurchaseContext purchaseContext;

  /// The currently active primary plan on the account, passed from PlansCubit.
  /// Null when the account has no active plan.
  final BasePlanModel? activePrimaryPlan;
}
