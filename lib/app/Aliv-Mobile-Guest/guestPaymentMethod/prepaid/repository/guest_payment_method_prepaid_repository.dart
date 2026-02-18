import '../model/guest_payment_method_prepaid_models.dart';

abstract class GuestPaymentMethodPrepaidRepository {
  Future<List<GuestSavedPaymentMethod>> fetchPaymentMethods();
  Future<void> payNow({required String methodId});
}
