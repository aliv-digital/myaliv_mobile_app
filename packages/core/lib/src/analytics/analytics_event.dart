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
}
