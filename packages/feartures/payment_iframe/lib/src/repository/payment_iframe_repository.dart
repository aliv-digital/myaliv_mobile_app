import '../models/order_status_model.dart';
import '../models/payment_request.dart';
import 'payment_iframe_exception.dart';
import 'services/payment_iframe_api_service.dart';

abstract class PaymentIFrameRepository {
  /// Fetch the HTML document for the given [request].
  ///
  /// Throws [PaymentIFrameException] on any error.
  Future<String> fetchPaymentHtml(PaymentRequest request);

  /// Fetch the server-side order status for [orderId].
  ///
  /// Calls `GET [orderVerificationUrl]?orderId=[orderId]`.
  /// Throws [PaymentIFrameException] on any error.
  Future<OrderStatusModel> fetchOrderStatus({
    required String orderVerificationUrl,
    required String orderId,
    required bool requiresAuth,
  });
}

class PaymentIFrameRepositoryImpl implements PaymentIFrameRepository {
  const PaymentIFrameRepositoryImpl({required PaymentIFrameApiService apiService})
      : _apiService = apiService;

  final PaymentIFrameApiService _apiService;

  @override
  Future<String> fetchPaymentHtml(PaymentRequest request) =>
      _apiService.fetchHtml(request);

  @override
  Future<OrderStatusModel> fetchOrderStatus({
    required String orderVerificationUrl,
    required String orderId,
    required bool requiresAuth,
  }) =>
      _apiService.fetchOrderStatus(
        orderVerificationUrl: orderVerificationUrl,
        orderId: orderId,
        requiresAuth: requiresAuth,
      );
}
