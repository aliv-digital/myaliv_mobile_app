import '../model/home_plans_payment_method_models.dart';

abstract class HomePlansPaymentMethodRepository {
  Future<List<HomePlansSavedPaymentMethod>> fetchPaymentMethods({
    required HomePlansSubscriberType subscriberType,
  });

  Future<void> payNow({required String methodId});
}
