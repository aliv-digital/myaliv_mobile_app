/// Sealed result type returned after the iframe payment flow completes.
sealed class PaymentResult {}

/// Payment completed successfully.
///
/// [orderId] is extracted from the redirect URI's `OrderID` query parameter.
/// [queryParams] carries the full set of query parameters from the redirect
/// URI — callers can extract any extra fields (e.g. `status`, `token`) without
/// the package needing to know about them.
final class PaymentSuccess extends PaymentResult {
  PaymentSuccess({this.orderId, this.queryParams = const {}});

  final String? orderId;
  final Map<String, String> queryParams;
}

/// Payment failed or was declined.
final class PaymentFailure extends PaymentResult {
  PaymentFailure(this.message);

  final String message;
}
