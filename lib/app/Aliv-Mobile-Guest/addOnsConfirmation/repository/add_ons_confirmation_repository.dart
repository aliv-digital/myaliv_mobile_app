import '../models/add_ons_confirmation_models.dart';

class AddOnsConfirmationRepository {
  /// Builds confirmation data from the real add-ons the user selected
  /// on the catalog add-ons tab. Previously returned a hardcoded
  /// `liberty data 1 / $5.00` mock regardless of selection.
  Future<AddOnsConfirmationData> load({
    required AddOnsConfirmationRouteArgs args,
  }) async {
    final items = args.selectedAddOns
        .map(
          (addOn) => PurchaseLineItem(
            id: addOn.id,
            type: PurchaseLineType.addOn,
            label: 'add-on',
            title: addOn.title,
            // Add-ons always start immediately against the live primary;
            // they cannot be scheduled (see guestAddOnsBodyFor3DS).
            subtitle: 'begins immediately',
            price: addOn.price,
          ),
        )
        .toList(growable: false);

    final totals = PurchaseTotals(
      subTotal: items.fold<double>(0, (s, x) => s + x.price),
      vat: 0,
    );

    return AddOnsConfirmationData(
      phoneNumber: args.phoneNumber,
      headerTitle: 'guest purchase a plan',
      beginsOnDateText: '',
      items: items,
      totals: totals,
    );
  }
}
