import '../network/network_exceptions.dart';

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
  static const String hashedUserId = 'hashed_user_id';
  static const String failureReason = 'failure_reason';
  static const String otpChannel = 'otp_channel';
}

/// Fixed vocabulary for the `method` parameter on `login` / `login_failure`.
///
/// A closed set — never pass raw strings. Reports can't segment reliably if
/// callers invent new values ("Password", "pwd", "pin"…).
abstract final class AnalyticsLoginMethod {
  static const String password = 'password';
  static const String biometric = 'biometric';
  static const String otp = 'otp';
  static const String sso = 'sso';
}

/// Fixed vocabulary for `failure_reason` on `login_failure`.
///
/// Non-sensitive categories only — never include the entered credentials or
/// the raw server error string.
abstract final class AnalyticsLoginFailureReason {
  static const String invalidCredentials = 'invalid_credentials';
  static const String lockedAccount = 'locked_account';
  static const String networkError = 'network_error';
  static const String systemError = 'system_error';

  /// Map a raw login error to a fixed category. [wasIncorrectCode] is the
  /// result the caller already computes via `OtpAttemptFailure.isIncorrectCode`
  /// — that detector lives in app code and knows the backend's structured
  /// shape, so we take it as a hint instead of duck-typing here.
  static String classify(Object error, {bool wasIncorrectCode = false}) {
    if (wasIncorrectCode) return invalidCredentials;
    if (error is NoInternetException || error is TimeoutException) {
      return networkError;
    }
    final msg = error.toString().toLowerCase();
    if (msg.contains('locked') || msg.contains('blocked')) {
      return lockedAccount;
    }
    return systemError;
  }
}

/// Fixed vocabulary for `otp_channel` on the OTP funnel events.
abstract final class AnalyticsOtpChannel {
  static const String sms = 'sms';
  static const String email = 'email';
}

/// Fixed vocabulary for `failure_reason` on `otp_failed`.
///
/// `not_received` is deliberately omitted — the client never has a reliable
/// signal for "SMS never arrived" (that's a user complaint, not an API
/// response). Timeouts are classified as `network_error`.
abstract final class AnalyticsOtpFailureReason {
  static const String expired = 'expired';
  static const String incorrect = 'incorrect';
  static const String networkError = 'network_error';

  /// Returns a fixed category or `null` — null means "don't fire `otp_failed`
  /// for this error" (the vocab is intentionally narrow; unknown errors are
  /// covered by `login_failure` / `password_reset_failed` instead).
  static String? classify(Object error, {bool wasIncorrectCode = false}) {
    if (wasIncorrectCode) return incorrect;
    if (error is NoInternetException || error is TimeoutException) {
      return networkError;
    }
    final msg = error.toString().toLowerCase();
    if (msg.contains('expired')) return expired;
    return null;
  }
}

/// Fixed vocabulary for `failure_reason` on `password_reset_failed`.
abstract final class AnalyticsPasswordResetFailureReason {
  static const String invalidCredentials = 'invalid_credentials';
  static const String otpExpired = 'otp_expired';
  static const String otpIncorrect = 'otp_incorrect';
  static const String networkError = 'network_error';
  static const String systemError = 'system_error';

  static String classify(Object error, {bool wasIncorrectCode = false}) {
    if (wasIncorrectCode) return otpIncorrect;
    if (error is NoInternetException || error is TimeoutException) {
      return networkError;
    }
    final msg = error.toString().toLowerCase();
    if (msg.contains('expired')) return otpExpired;
    if (msg.contains('invalid')) return invalidCredentials;
    return systemError;
  }
}

/// Firebase Analytics *user property* keys.
///
/// User properties persist on the Firebase user profile and apply to every
/// subsequent event (unlike event parameters which live on one event only).
/// GA4 names must be snake_case, ≤ 24 characters; values ≤ 36 characters.
abstract final class AnalyticsUserProperty {
  /// `"true"` while a session is active, `"false"` after logout. Lets GA4
  /// segment any event by authenticated vs. guest without re-adding a
  /// per-event flag.
  static const String loggedIn = 'logged_in';
}

/// `item_category` values used on the GA4 `purchase` event. Lets reports
/// break ecommerce purchases into bundle vs. add-on without inventing a
/// second event name.
abstract final class AnalyticsItemCategory {
  static const String plan = 'plan';
  static const String addon = 'addon';
}
