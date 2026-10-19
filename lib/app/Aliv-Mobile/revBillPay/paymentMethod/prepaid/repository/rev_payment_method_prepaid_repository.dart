import '../model/rev_payment_method_prepaid_models.dart';

abstract class RevPaymentMethodPrepaidRepository {
  Future<List<RevSavedPaymentMethod>> fetchPaymentMethods();
  Future<void> payNow({required String methodId});
}
