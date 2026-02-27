import '../models/add_ons_confirmation_models.dart';

class AddOnsConfirmationRepository {
  /// Future: call API, build the same data shape, return it.
  Future<AddOnsConfirmationData> load({
    required String phoneNumber,
  }) async {
    // Seeded UI data for the add-ons confirmation mock.
    final items = <PurchaseLineItem>[
      const PurchaseLineItem(
        id: 'addon1',
        type: PurchaseLineType.addOn,
        label: 'add-on',
        title: 'liberty data 1',
        subtitle: 'begins immediately',
        price: 5.00,
      ),
    ];

    final totals = PurchaseTotals(
      subTotal: items.fold<double>(0, (s, x) => s + x.price),
      vat: 0,
    );

    return AddOnsConfirmationData(
      phoneNumber: phoneNumber,
      headerTitle: 'guest purchase a plan',
      beginsOnDateText: '',
      items: items,
      totals: totals,
    );
  }
}
