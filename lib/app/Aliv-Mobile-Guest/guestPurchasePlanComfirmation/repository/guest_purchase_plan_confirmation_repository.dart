import '../models/guest_purchase_plan_confirmation_models.dart';

class GuestPurchasePlanConfirmationRepository {
  /// Builds confirmation screen data from navigation arguments.
  Future<GuestPurchasePlanConfirmationData> load({
    required GuestPurchasePlanConfirmationRouteArgs args,
  }) async {
    final List<PurchaseLineItem> items = <PurchaseLineItem>[
      PurchaseLineItem(
        id: 'primary',
        type: PurchaseLineType.primaryPlan,
        label: 'primary plan',
        title: args.primaryPlanName,
        subtitle: args.flow == GuestPurchasePlanConfirmationEntryFlow.skip
            ? 'begins 01-06-23'
            : 'begins immediately',
        price: args.primaryPlanPrice,
      ),
    ];

    if (args.flow == GuestPurchasePlanConfirmationEntryFlow.proceed) {
      items.addAll(
        args.selectedAddOns.map(
          (addOn) => PurchaseLineItem(
            id: addOn.id,
            type: PurchaseLineType.addOn,
            label: 'add-on',
            title: addOn.title,
            subtitle: 'begins immediately',
            price: addOn.price,
          ),
        ),
      );
    }

    final totals = PurchaseTotals(
      subTotal: items.fold<double>(0, (sum, item) => sum + item.price),
      vat: 0,
    );

    return GuestPurchasePlanConfirmationData(
      phoneNumber: args.phoneNumber,
      headerTitle: args.accountHolderName,
      items: items,
      totals: totals,
    );
  }
}
