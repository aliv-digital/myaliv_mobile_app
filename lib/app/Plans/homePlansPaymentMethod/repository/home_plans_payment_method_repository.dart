import '../model/home_plans_payment_method_models.dart';

abstract class HomePlansPaymentMethodRepository {
  Future<List<HomePlansSavedPaymentMethod>> fetchPaymentMethods({
    required HomePlansSubscriberType subscriberType,
  });

  Future<void> payNow({required String methodId});

  Future<dynamic> payFromWallet({
    required double amount,
    required List<HomePlansPaymentSelectedItem> selectedItems,
    required bool forceNow,
    DateTime? selectedBeginDate,
  });
}
