

import '../model/plan_purchase_add_on_models.dart';

class PlanPurchasePlanAddOnsRepository {
  // Future: replace these with API calls
  Future<PlanPurchaseActivePlanSummary> fetchActivePlan() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return const PlanPurchaseActivePlanSummary(
      label: 'active plan',
      name: 'liberty70',
      autoRenew: true,
      activeDateLabel: 'active',
      activeDate: '20/08/24',
      expireDateLabel: 'expire',
      expireDate: '19/09/24',
    );
  }

  Future<PlanPurchaseFairUsePolicy> fetchFairUsePolicy() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return const PlanPurchaseFairUsePolicy(
      title: 'fair use policy',
      description:
      "add-ons can only be added to your active primary plan and expires when it ends. "
          "if you don't want an add-on select skip.",
    );
  }

  Future<List<PlanPurchaseAddOnItem>> fetchAddOns() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      // PlanPurchaseAddOnItem(
      //   id: 'a1',
      //   title: 'liberty data 1',
      //   subtitleLabel: 'data balance',
      //   subtitleValue: '1gb',
      //   price: 5.00,
      // ),
      // PlanPurchaseAddOnItem(
      //   id: 'a2',
      //   title: 'liberty data 2',
      //   subtitleLabel: 'data balance',
      //   subtitleValue: '2gb',
      //   price: 5.00, vatAmount: null,
      // ),
      // PlanPurchaseAddOnItem(
      //   id: 'a3',
      //   title: 'liberty data 3',
      //   subtitleLabel: 'data balance',
      //   subtitleValue: '3gb',
      //   price: 5.00,
      // ),
    ];
  }
}
