/// Firebase Analytics event parameter key constants.
///
/// All parameter keys used across analytics events.
/// GA4 parameter names must be snake_case and ≤ 40 characters.
abstract final class AnalyticsParam {
  // ── Common ────────────────────────────────────────────────────────────────
  static const String amount = 'amount';
  static const String currency = 'currency';
  static const String paymentMethod = 'payment_method';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String method = 'method';

  // ── Plans ─────────────────────────────────────────────────────────────────
  static const String planId = 'plan_id';
  static const String planName = 'plan_name';

  // ── Add-ons ───────────────────────────────────────────────────────────────
  static const String addonId = 'addon_id';
  static const String addonName = 'addon_name';
}
