import 'package:equatable/equatable.dart';

/// Describes a single payment operation to be executed via the iframe flow.
///
/// The package is endpoint-agnostic — callers supply the full URL and request
/// body so the same widget works for guest top-up, guest billpay, 3DS payment,
/// change bundle, and any future payment type without package changes.
///
/// [redirectScheme] must match the custom URI scheme registered in
/// AndroidManifest.xml / Info.plist (e.g. `"myaliv"`).  The WebView intercepts
/// any navigation whose scheme equals this value and hands the URI back to the
/// Cubit as a payment result.
class PaymentRequest extends Equatable {
  const PaymentRequest({
    required this.endpoint,
    required this.body,
    required this.redirectScheme,
    this.requiresAuth = false,
    this.orderVerificationUrl,
  });

  /// Full API endpoint URL, e.g. `Api.guestTopupUrl`.
  final String endpoint;

  /// POST body sent to [endpoint].
  final Map<String, dynamic> body;

  /// Custom URI scheme that PowerTranz redirects back to after 3DS completes,
  /// e.g. `"myaliv"` → catches `myaliv://topup-callback?OrderID=123&status=success`.
  final String redirectScheme;

  /// Set to `true` for authenticated endpoints (e.g. 3DS top-up for logged-in
  /// users). Defaults to `false` so guest flows skip the Bearer auth header —
  /// the server returns 401 if an unexpected token is sent on a guest route.
  final bool requiresAuth;

  /// When provided and `OrderID` is present in the redirect URI, the cubit
  /// calls `GET $orderVerificationUrl?orderId={id}` and checks the response's
  /// `OrderStatus` field (`"Completed"` = success) instead of trusting the
  /// redirect URI's `status` query parameter.
  ///
  /// Omit (or leave `null`) to fall back to the redirect URI's `status` param.
  final String? orderVerificationUrl;

  @override
  List<Object?> get props => [endpoint, body, redirectScheme, requiresAuth, orderVerificationUrl];
}
