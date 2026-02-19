import '../../../../../Home/home/home_screen.dart';
import '../model/purchase_prepaid_models.dart';

class PurchasePrepaidRepository {
  Future<List<PurchasePrepaidMenuItem>> fetchMenuItems() async {
    // Later: API integration
    if(config.isPrepaid == true){
      return const [
        PurchasePrepaidMenuItem(
          title: 'add/edit credit cards',
          action: PurchasePrepaidAction.addEditCreditCards,
        ),

        PurchasePrepaidMenuItem(
          title: 'top up',
          action: PurchasePrepaidAction.topUp,
        ),
        // PurchasePrepaidMenuItem(
        //   title: 'top up a prepaid number',
        //   action: PurchasePrepaidAction.topUpPrepaidNumber,
        // ),
        PurchasePrepaidMenuItem(
          title: 'buy plans',
          action: PurchasePrepaidAction.buyPlans,
        ),
        PurchasePrepaidMenuItem(
          title: 'future plans',
          action: PurchasePrepaidAction.futurePlans,
        ),
        // PurchasePrepaidMenuItem(
        //   title: 'my limits',
        //   action: PurchasePrepaidAction.myLimits,
        // ),
        PurchasePrepaidMenuItem(
          title: 'auto renew',
          action: PurchasePrepaidAction.autoRenew,
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
          title: 'make payment',
          action: PurchasePrepaidAction.makePayment,
        ),
      ];

    }else{
      return const [
        PurchasePrepaidMenuItem(
          title: 'add/edit credit cards',
          action: PurchasePrepaidAction.addEditCreditCards,
        ),

        PurchasePrepaidMenuItem(
          title: 'top up a prepaid number',
          action: PurchasePrepaidAction.topUpPrepaidNumber,
        ),
        PurchasePrepaidMenuItem(
          title: 'buy plans',
          action: PurchasePrepaidAction.buyPlans,
        ),
        // PurchasePrepaidMenuItem(
        //   title: 'top up',
        //   action: PurchasePrepaidAction.topUp,
        // ),
        PurchasePrepaidMenuItem(
          title: 'future plans',
          action: PurchasePrepaidAction.futurePlans,
        ),
        PurchasePrepaidMenuItem(
          title: 'my limits',
          action: PurchasePrepaidAction.myLimits,
        ),
        // PurchasePrepaidMenuItem(
        //   title: 'auto renew',
        //   action: PurchasePrepaidAction.autoRenew,
        // ),
        PurchasePrepaidMenuItem(
          title: 'review invoices',
          action: PurchasePrepaidAction.reviewInvoices,
        ),
        PurchasePrepaidMenuItem(
          title: 'transaction history',
          action: PurchasePrepaidAction.transactionHistory,
        ),
        PurchasePrepaidMenuItem(
          title: 'make payment',
          action: PurchasePrepaidAction.makePayment,
        ),
      ];

    }
  }
}
