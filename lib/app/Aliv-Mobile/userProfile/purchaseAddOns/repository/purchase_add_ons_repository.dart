import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_on_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

import '../model/purchase_add_ons_models.dart';

class PurchaseAddOnsRepository {
  const PurchaseAddOnsRepository();

  /// Converts the add-ons data already loaded by PlanScreen into this feature's
  /// local models. This keeps purchaseAddOns from making the same API call again.
  PurchaseAddOnsDataResult fromPlansState(PlansState plansState) {
    final addOns = plansState.addOns.map(_toAddOnItem).toList(growable: false);
    final availableAddOnIds = addOns.map((addOn) => addOn.id).toSet();

    return PurchaseAddOnsDataResult(
      activePrimaryPlan: _toPrimaryPlan(plansState.earliestAddOnsPrimaryPlan),
      addOns: addOns,
      selectedAddOnIds:
          plansState.selectedAddOnIds.where(availableAddOnIds.contains).toSet(),
    );
  }

  PurchaseAddOnsPrimaryPlan? _toPrimaryPlan(BasePlanModel? plan) {
    if (plan == null) return null;

    return PurchaseAddOnsPrimaryPlan(
      id: plan.planId,
      name: plan.planName,
      autoRenew: plan.autoRenew,
      startDateTime: plan.startDateTime,
      endDateTime: plan.endDateTime,
    );
  }

  PurchaseAddOnsItem _toAddOnItem(HomePlanAddOnModel addOn) {
    return PurchaseAddOnsItem(
      id: addOn.id,
      title: addOn.title,
      subtitleLabel: addOn.label,
      subtitleValue: addOn.value,
      price: addOn.price,
      vatAmount: addOn.vatAmount,
    );
  }
}
