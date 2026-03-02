import '../models/home_roaming_confirmation_models.dart';

class HomeRoamingConfirmationRepository {
  /// Future: call API, build the same data shape, return it.
  Future<HomeRoamingConfirmationData> load({
    required String phoneNumber,
  }) async {
    // Demo seed (তুমি পরে API বসাবে)
    final items = <HomeRoamingConfirmationPurchaseLineItem>[
      const HomeRoamingConfirmationPurchaseLineItem(
        id: 'standalone',
        type: HomeRoamingConfirmationPurchaseLineType.primaryPlan,
        label: 'standalone',
        title: 'roam20 - 7 days',
        subtitle: 'begins immediately 06-08-25',
        price: 20.00,
      ),
    ];

    final totals = HomeRoamingConfirmationPurchaseTotals(
      subTotal: items.fold<double>(0, (s, x) => s + x.price),
      vat: 0,
    );

    return HomeRoamingConfirmationData(
      phoneNumber: phoneNumber,
      headerTitle: 'purchase a plan',
      beginsOnDateText: 'Aug 6th, 2025',
      items: items,
      totals: totals,
    );
  }
}
