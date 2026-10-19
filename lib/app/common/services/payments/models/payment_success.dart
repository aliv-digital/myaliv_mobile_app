/// Result returned by [PaymentIFrameScreen] when the 3DS flow completes.
class PaymentSuccess {
  const PaymentSuccess({this.orderId, required this.queryParams});

  /// Order ID extracted from the redirect URL query params.
  final String? orderId;

  /// All query parameters from the bank's redirect-back URL.
  final Map<String, String> queryParams;
}
