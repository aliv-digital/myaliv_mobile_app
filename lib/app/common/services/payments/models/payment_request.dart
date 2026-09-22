/// Describes a 3DS payment that [PaymentIFrameScreen] should initiate.
class PaymentRequest {
  const PaymentRequest({
    required this.url,
    required this.body,
    required this.redirectScheme,
  });

  /// Backend endpoint to POST the payment body to.
  final String url;

  /// Full request body (already built by the caller).
  final Map<String, dynamic> body;

  /// URL scheme the bank page redirects to on completion (e.g. `"myaliv"`).
  final String redirectScheme;
}
