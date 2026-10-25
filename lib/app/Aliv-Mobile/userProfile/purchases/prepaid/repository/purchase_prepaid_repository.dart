import '../model/purchase_prepaid_models.dart';

class PurchasePrepaidRepository {
  Future<List<PurchasePrepaidMenuItem>> fetchMenuItems({
    required bool isPrepaid,
  }) async {
    // Later: API integration
    if (isPrepaid) {
      return const [
        PurchasePrepaidMenuItem(
          title: 'add/edit credit cards',
          action: PurchasePrepaidAction.addEditCreditCards,
        ),
        PurchasePrepaidMenuItem(
          title: 'top-up',
          action: PurchasePrepaidAction.topUp,
        ),
        PurchasePrepaidMenuItem(
          title: 'buy plans',
          action: PurchasePrepaidAction.buyPlans,
        ),
        PurchasePrepaidMenuItem(
          title: 'future plans',
          action: PurchasePrepaidAction.futurePlans,
        ),
        PurchasePrepaidMenuItem(
          title: 'send top-up',
          action: PurchasePrepaidAction.sendTopUp,
        ),
        PurchasePrepaidMenuItem(
          title: 'auto top-up',
          action: PurchasePrepaidAction.autoTopUp,
        ),
        PurchasePrepaidMenuItem(
          title: 'transaction history',
          action: PurchasePrepaidAction.transactionHistory,
        ),
        PurchasePrepaidMenuItem(
          title: 'auto renew',
          action: PurchasePrepaidAction.autoRenew,
        ),
        PurchasePrepaidMenuItem(
          title: 'add-ons',
          action: PurchasePrepaidAction.addOns,
        ),
      ];
    } else {
      return const [
        PurchasePrepaidMenuItem(
          title: 'buy plans',
          action: PurchasePrepaidAction.buyPlans,
        ),
        PurchasePrepaidMenuItem(
          title: 'make payment',
          action: PurchasePrepaidAction.makePayment,
        ),
        PurchasePrepaidMenuItem(
          title: 'add/edit credit cards',
          action: PurchasePrepaidAction.addEditCreditCards,
        ),
        PurchasePrepaidMenuItem(
          title: 'future plans',
          action: PurchasePrepaidAction.futurePlans,
        ),
        PurchasePrepaidMenuItem(
          title: 'my limits',
          action: PurchasePrepaidAction.myLimits,
        ),
        PurchasePrepaidMenuItem(
          title: 'review invoices',
          action: PurchasePrepaidAction.reviewInvoices,
        ),
        PurchasePrepaidMenuItem(
          title: 'transaction history',
          action: PurchasePrepaidAction.transactionHistory,
        ),
        PurchasePrepaidMenuItem(
          title: 'top-up a prepaid number',
          action: PurchasePrepaidAction.topUpPrepaidNumber,
        ),
      ];
    }
  }
}
