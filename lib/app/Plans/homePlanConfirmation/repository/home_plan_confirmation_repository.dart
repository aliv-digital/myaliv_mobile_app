import '../models/home_plan_confirmation_models.dart';

class HomePlanConfirmationRepository {
  /// Future: call API, build the same data shape, return it.
  Future<HomePlanConfirmationData> load({
    required HomePlanConfirmationRouteArgs args,
  }) async {
    final List<PurchaseLineItem> items = <PurchaseLineItem>[];

    // Skip the primary plan line entirely when it's already active —
    // the user is only being charged for the selected add-ons.
    if (!args.isPrimaryPlanActive) {
      items.add(
        PurchaseLineItem(
          id: 'primary',
          type: PurchaseLineType.primaryPlan,
          // The label comes from the API plan type, not a hardcoded
          // "primary plan" string. This matches purchase_confirmation_screen.
          label: _primaryPlanTypeLabel(args.primaryPlanTypeCode),
          title: args.primaryPlanName,
          subtitle: args.flow == HomePlanConfirmationEntryFlow.skip
              ? 'begins 01-06-23'
              : 'begins immediately',
          price: args.primaryPlanPrice,
        ),
      );
    }

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

    final double primaryVat =
        args.isPrimaryPlanActive ? 0 : args.primaryPlanVatAmount;
    final double addOnsVat = args.selectedAddOns.fold<double>(
      0,
      (sum, addOn) => sum + addOn.vatAmount,
    );

    final totals = PurchaseTotals(
      subTotal: items.fold<double>(0, (s, x) => s + x.price),
      vat: primaryVat + addOnsVat,
    );

    return HomePlanConfirmationData(
      phoneNumber: args.phoneNumber,
      headerTitle: args.accountHolderName,
      beginsOnDateText: '',
      items: items,
      totals: totals,
    );
  }

  String _primaryPlanTypeLabel(String planTypeCode) {
    switch (planTypeCode.trim().toUpperCase()) {
      case 'A':
        return 'standalone';
      case 'S':
        return 'secondary plan';
      case 'P':
        return 'primary plan';
      default:
        return 'plan';
    }
  }
}
