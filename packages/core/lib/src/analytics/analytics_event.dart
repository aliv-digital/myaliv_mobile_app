/// Firebase Analytics event name constants.
///
/// All custom event names tracked across the My Aliv app.
/// GA4 event names must be snake_case and ≤ 40 characters.
abstract final class AnalyticsEvent {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = 'login';
  static const String loginFailure = 'login_failure';
  static const String logout = 'logout';

  // ── OTP (shared across login + password-reset flows) ──────────────────────
  static const String otpRequested = 'otp_requested';
  static const String otpVerified = 'otp_verified';
  static const String otpFailed = 'otp_failed';

  // ── Password reset ────────────────────────────────────────────────────────
  static const String passwordResetStarted = 'password_reset_started';
  static const String passwordResetCompleted = 'password_reset_completed';
  static const String passwordResetFailed = 'password_reset_failed';

  // ── Wallet ────────────────────────────────────────────────────────────────
  static const String walletTopUp = 'wallet_top_up';
  static const String walletFunding = 'wallet_funding';

  // ── Payments ──────────────────────────────────────────────────────────────
  static const String billPayment = 'bill_payment';

  // ── Support ───────────────────────────────────────────────────────────────
  static const String supportChatOpened = 'support_chat_opened';

  // ── Self-serve ────────────────────────────────────────────────────────────
  static const String accountDetailsUpdated = 'account_details_updated';
  static const String dataBalanceViewed = 'data_balance_viewed';
  static const String planSummaryViewed = 'plan_summary_viewed';
  static const String invoiceViewed = 'invoice_viewed';
  static const String invoiceDownloaded = 'invoice_downloaded';
  static const String accountLineSwitched = 'account_line_switched';

  // ── Commerce (GA4 standard ecommerce funnel) ──────────────────────────────
  // view_item_list → select_item → begin_checkout → add_payment_info →
  // purchase_attempted → purchase | purchase_failed
  static const String viewItemList = 'view_item_list';
  static const String selectItem = 'select_item';
  static const String beginCheckout = 'begin_checkout';
  static const String addPaymentInfo = 'add_payment_info';
  static const String purchaseAttempted = 'purchase_attempted';
  static const String purchaseFailed = 'purchase_failed';
  static const String selectPromotion = 'select_promotion';
  static const String rewardsBalanceViewed = 'rewards_balance_viewed';
  static const String outboundClick = 'outbound_click';
}
