import '../models/roaming_plan_confirmation_models.dart';

class RoamingPlanConfirmationRepository {
  /// Future: call API, build the same data shape, return it.
  Future<RoamingPlanConfirmationData> load({
    required String phoneNumber,
  }) async {
    // Demo seed (তুমি পরে API বসাবে)
    final items = <PurchaseLineItem>[
      const PurchaseLineItem(
        id: 'standalone',
        type: PurchaseLineType.primaryPlan,
        label: 'standalone',
        title: 'roam20 - 7 days',
        subtitle: 'begins immediately',
        price: 20.00,
      ),
    ];

    final totals = PurchaseTotals(
      subTotal: items.fold<double>(0, (s, x) => s + x.price),
      vat: 0,
    );

    return RoamingPlanConfirmationData(
      phoneNumber: phoneNumber,
      headerTitle: 'guest purchase a plan',
      beginsOnDateText: 'Aug 6th, 2025',
      items: items,
      totals: totals,
    );
  }
}
