import '../../../../core/utils/app_session.dart';
import '../models/guest_purchase_plan_confirmation_models.dart';

class GuestPurchasePlanConfirmationRepository {
  /// Future: call API, build the same data shape, return it.
  Future<GuestPurchasePlanConfirmationData> load({
    required String phoneNumber,
  }) async {
    // Demo seed (তুমি পরে API বসাবে)
    final items = <PurchaseLineItem>[
      const PurchaseLineItem(
        id: 'primary',
        type: PurchaseLineType.primaryPlan,
        label: 'primary plan',
        title: 'liberty70',
        subtitle: 'begins immediately',
        price: 15.00,
      ),
      const PurchaseLineItem(
        id: 'addon1',
        type: PurchaseLineType.addOn,
        label: 'add-on',
        title: 'liberty data 1',
        subtitle: 'begins immediately',
        price: 4.55,
      ),
    ];

    final totals = PurchaseTotals(
      subTotal: items.fold<double>(0, (s, x) => s + x.price),
      vat: 0,
    );

    final itemsAddOns = <PurchaseLineItem>[

      const PurchaseLineItem(
        id: 'addon1',
        type: PurchaseLineType.addOn,
        label: 'add-on',
        title: 'liberty data 1',
        subtitle: 'begins immediately',
        price: 4.55,
      ),
    ];

    final totalsAddOns = PurchaseTotals(
      subTotal: 15.00,//itemsAddOns.fold<double>(0, (s, x) => s + x.price),
      vat: 0,
    );

    return GuestPurchasePlanConfirmationData(
      phoneNumber: '242-801-1616',
      headerTitle:  AppSession.appRoute == 'addOnsPrepaid' ?'Jade Turnquest':'guest purchase a plan',
      items: AppSession.appRoute == 'addOnsPrepaid' ? itemsAddOns : items,
      totals: AppSession.appRoute == 'addOnsPrepaid' ? totalsAddOns : totals,
    );
  }
}
