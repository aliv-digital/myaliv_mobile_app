/// Payment iFrame package — reusable HTML-based 3DS payment gateway.
///
/// Public API:
/// - [PaymentIFrameScreen]      — drop-in screen widget
/// - [PaymentRequest]           — describes the payment (endpoint, body, scheme)
/// - [PaymentSuccess]           — result type on success (carries OrderID)
/// - [PaymentFailure]           — result type on failure (carries error message)
/// - [setupPaymentIFrameInjection] — DI registration (call once at app start)
library;

export 'src/models/payment_request.dart';
export 'src/models/payment_result.dart';
export 'src/payment_iframe_injection.dart';
export 'src/view/payment_iframe_screen.dart';
