/// Firebase Analytics event name constants.
///
/// All custom event names tracked across the My Aliv app.
/// GA4 event names must be snake_case and ≤ 40 characters.
abstract final class AnalyticsEvent {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = 'login';

  // ── Wallet ────────────────────────────────────────────────────────────────
  static const String walletTopUp = 'wallet_top_up';
  static const String walletFunding = 'wallet_funding';

  // ── Plans ─────────────────────────────────────────────────────────────────
  static const String planPurchase = 'plan_purchase';
  static const String addonPurchase = 'addon_purchase';

  // ── Payments ──────────────────────────────────────────────────────────────
  static const String billPayment = 'bill_payment';

  // ── Support ───────────────────────────────────────────────────────────────
  static const String supportChatOpened = 'support_chat_opened';
}
