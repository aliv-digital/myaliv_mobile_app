import '../model/purchases_models.dart';

class PurchasesRepository {
  Future<List<PurchasesMenuItem>> fetchMenuItems({
    required bool isPrepaid,
  }) async {
    // Later: API integration
    if (isPrepaid) {
      return const [
        PurchasesMenuItem(
          title: 'add/edit credit cards',
          action: PurchasesAction.addEditCreditCards,
        ),
        PurchasesMenuItem(title: 'top-up', action: PurchasesAction.topUp),
        PurchasesMenuItem(title: 'buy plans', action: PurchasesAction.buyPlans),
        PurchasesMenuItem(
          title: 'future plans',
          action: PurchasesAction.futurePlans,
        ),
        PurchasesMenuItem(
          title: 'send top-up',
          action: PurchasesAction.sendTopUp,
        ),
        PurchasesMenuItem(
          title: 'auto top-up',
          action: PurchasesAction.autoTopUp,
        ),
        PurchasesMenuItem(
          title: 'transaction history',
          action: PurchasesAction.transactionHistory,
        ),
        PurchasesMenuItem(
          title: 'auto renew',
          action: PurchasesAction.autoRenew,
        ),
        PurchasesMenuItem(title: 'add-ons', action: PurchasesAction.addOns),
      ];
    } else {
      return const [
        PurchasesMenuItem(title: 'buy plans', action: PurchasesAction.buyPlans),
        PurchasesMenuItem(
          title: 'make payment',
          action: PurchasesAction.makePayment,
        ),
        PurchasesMenuItem(
          title: 'add/edit credit cards',
          action: PurchasesAction.addEditCreditCards,
        ),
        PurchasesMenuItem(
          title: 'future plans',
          action: PurchasesAction.futurePlans,
        ),
        PurchasesMenuItem(title: 'auto pay', action: PurchasesAction.autoPay),
        PurchasesMenuItem(title: 'my limits', action: PurchasesAction.myLimits),
        PurchasesMenuItem(
          title: 'review invoices',
          action: PurchasesAction.reviewInvoices,
        ),
        PurchasesMenuItem(
          title: 'transaction history',
          action: PurchasesAction.transactionHistory,
        ),
        PurchasesMenuItem(
          title: 'top-up a prepaid number',
          action: PurchasesAction.topUpPrepaidNumber,
        ),
      ];
    }
  }
}
