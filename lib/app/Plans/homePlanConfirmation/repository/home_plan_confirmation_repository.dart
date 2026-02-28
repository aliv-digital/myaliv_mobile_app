import '../models/home_plan_confirmation_models.dart';

class HomePlanConfirmationRepository {
  /// Future: call API, build the same data shape, return it.
  Future<HomePlanConfirmationData> load({
    required HomePlanConfirmationRouteArgs args,
  }) async {
    final List<PurchaseLineItem> items = <PurchaseLineItem>[
      PurchaseLineItem(
        id: 'primary',
        type: PurchaseLineType.primaryPlan,
        label: 'primary plan',
        title: args.primaryPlanName,
        subtitle: args.flow == HomePlanConfirmationEntryFlow.skip
            ? 'begins 01-06-23'
            : 'begins immediately',
        price: args.primaryPlanPrice,
      ),
    ];

    if (args.flow == HomePlanConfirmationEntryFlow.proceed) {
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
      subTotal: items.fold<double>(0, (s, x) => s + x.price),
      vat: 0,
    );

    return HomePlanConfirmationData(
      phoneNumber: args.phoneNumber,
      headerTitle: args.accountHolderName,
      beginsOnDateText: '',
      items: items,
      totals: totals,
    );
  }
}
