import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/plan_purchase_promo_code.dart';

import '../model/home_plans_payment_method_models.dart';

abstract class HomePlansPaymentMethodRepository {
  Future<List<HomePlansSavedPaymentMethod>> fetchPaymentMethods({
    required HomePlansSubscriberType subscriberType,
  });

  Future<void> payNow({required String methodId});

  Future<bool> payFromWallet({
    required double amount,
    required List<HomePlansPaymentSelectedItem> selectedItems,
    required List<PlanPurchasePromoCode> promoCodes,
    required bool forceNow,
    DateTime? selectedBeginDate,
  });

  Future<bool> chargeToAccount({
    required double amount,
    required List<HomePlansPaymentSelectedItem> selectedItems,
    required List<PlanPurchasePromoCode> promoCodes,
    required bool forceNow,
    DateTime? selectedBeginDate,
  });

  Future<bool> payWithSavedCard({
    required double amount,
    required String cardToken,
    required List<HomePlansPaymentSelectedItem> selectedItems,
    required List<PlanPurchasePromoCode> promoCodes,
    required bool forceNow,
    DateTime? selectedBeginDate,
  });

  Future<bool> payWithCardDetails({
    required double amount,
    required NewCardDetails details,
    required List<HomePlansPaymentSelectedItem> selectedItems,
    required List<PlanPurchasePromoCode> promoCodes,
    required bool forceNow,
    DateTime? selectedBeginDate,
  });
}
