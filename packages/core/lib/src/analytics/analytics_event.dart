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
  // `addWalletFunds` is the spec name for a successful prepaid top-up (was
  // internally called `wallet_top_up` before the spec arrived — the GA4
  // event name was migrated to match). `walletFunding` is wallet-to-wallet
  // transfer — a separate concept.
  static const String addWalletFunds = 'add_wallet_funds';
  static const String addWalletFundsStarted = 'add_wallet_funds_started';
  static const String addWalletFundsFailed = 'add_wallet_funds_failed';
  static const String walletBalanceViewed = 'wallet_balance_viewed';
  static const String walletFunding = 'wallet_funding';

  // ── Payment methods (card management) ─────────────────────────────────────
  // GA4's standard `add_payment_info` is reused for "card saved to account"
  // (handled by `logPaymentMethodAdded`, which calls the SDK's native method
  // with payment_type only — no items — to disambiguate from checkout-time
  // payment selection in reports).
  static const String paymentMethodUpdated = 'payment_method_updated';
  static const String paymentMethodRemoved = 'payment_method_removed';
  static const String paymentMethodFailed = 'payment_method_failed';

  // ── Payments ──────────────────────────────────────────────────────────────
  static const String billPayment = 'bill_payment';

  // ── Support ───────────────────────────────────────────────────────────────
  static const String supportChatOpened = 'support_chat_opened';
  static const String supportScreenViewed = 'support_screen_viewed';

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

  // ── Auto-Pay ──────────────────────────────────────────────────────────────
  // Shared across prepaid auto-renew, prepaid auto-topup, and postpaid
  // auto-pay flows. GA4 segments by the `account_type` user property.
  static const String autopayToggle = 'autopay_toggle';
  static const String autopaySetupStarted = 'autopay_setup_started';
  static const String autopaySetupCompleted = 'autopay_setup_completed';
  static const String autopaySetupFailed = 'autopay_setup_failed';
}
