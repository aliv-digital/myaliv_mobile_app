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

  // ── Self-serve ────────────────────────────────────────────────────────────
  static const String fieldType = 'field_type';
  static const String status = 'status';
  static const String planType = 'plan_type';

  // ── Commerce ──────────────────────────────────────────────────────────────
  static const String itemListName = 'item_list_name';
  static const String paymentType = 'payment_type';
  static const String promoCodeApplied = 'promo_code_applied';
  static const String promoCode = 'promo_code';
  static const String fundingSource = 'funding_source';
  static const String promotionId = 'promotion_id';
  static const String promotionName = 'promotion_name';
  static const String linkDestination = 'link_destination';
  static const String linkUrl = 'link_url';

  // ── Payment methods (card management) ─────────────────────────────────────
  static const String cardType = 'card_type';
  static const String fieldUpdated = 'field_updated';
  static const String action = 'action';

  // ── Auto-Pay ──────────────────────────────────────────────────────────────
  static const String state = 'state';
  static const String reason = 'reason';
}

/// Fixed vocabulary for `state` on `autopay_toggle`.
abstract final class AnalyticsAutopayState {
  static const String on = 'on';
  static const String off = 'off';
}

/// Fixed vocabulary for `failure_reason` on `autopay_setup_failed`.
abstract final class AnalyticsAutopaySetupFailureReason {
  static const String networkError = 'network_error';
  static const String validationError = 'validation_error';
  static const String apiError = 'api_error';
  static const String otpFailed = 'otp_failed';

  /// Map a raw setup error to a fixed category. Mirrors the pattern on
  /// [AnalyticsPurchaseFailureReason] but with a narrower vocab since
  /// auto-pay setup can't return "declined" / "insufficient_balance".
  static String classify(Object error) {
    if (error is NoInternetException || error is TimeoutException) {
      return networkError;
    }
    if (error is ServerException) return apiError;
    final msg = error.toString().toLowerCase();
    if (msg.contains('invalid') || msg.contains('validation')) {
      return validationError;
    }
    if (error is NetworkException) {
      final code = error.statusCode ?? 0;
      if (code >= 500) return apiError;
      if (code >= 400) return validationError;
    }
    return apiError;
  }
}

/// Fixed vocabulary for `field_type` on `account_details_updated`.
///
/// Describes WHICH account field was edited. The field *value* (new email,
/// new address, …) is never attached to the event — only the category.
abstract final class AnalyticsAccountField {
  static const String name = 'name';
  static const String address = 'address';
  static const String email = 'email';
}

/// Fixed vocabulary for `status` on `account_details_updated`. Lets GA4
/// compute the "started an edit vs. finished saving" funnel without
/// inventing a second event name.
abstract final class AnalyticsAccountUpdateStatus {
  static const String attempted = 'attempted';
  static const String completed = 'completed';
}

/// Fixed vocabulary for `payment_type` on `add_payment_info` and
/// `payment_method` on `purchase` / `purchase_attempted` / `purchase_failed`.
///
/// Debit vs. credit is deliberately NOT split — the backend currently groups
/// both as "card" (Open Q10 pending Finance sign-off + IT change). All card
/// payments map to [creditCard] until then. [rewards] is listed to match the
/// spec vocab but has no in-app payment path yet (rewards balance exists only
/// as a view surface — not a funding source).
///
/// [chargeToAccount] is kept outside the spec's 4-value vocab because
/// postpaid charge-to-account is a legitimate payment path with no spec term.
abstract final class AnalyticsPaymentType {
  static const String wallet = 'wallet';
  static const String creditCard = 'credit_card';
  static const String debitCard = 'debit_card';
  static const String rewards = 'rewards';
  static const String chargeToAccount = 'charge_to_account';
}

/// Fixed vocabulary for `card_type` on card-management events.
///
/// Backend doesn't return brand (visa/mastercard) on the SavedCardModel, and
/// debit vs. credit isn't distinguished (Open Q10). Default to [creditCard]
/// unless a signal is explicitly available; use [unknown] for events like
/// `payment_method_removed` where we don't carry the card through the
/// delete path.
abstract final class AnalyticsCardType {
  static const String creditCard = 'credit_card';
  static const String debitCard = 'debit_card';
  static const String unknown = 'unknown';
}

/// Fixed vocabulary for `field_updated` on `payment_method_updated`.
///
/// Only wire this when an edit flow actually ships — currently the app has
/// no card-edit screen, so the event is deferred.
abstract final class AnalyticsCardField {
  static const String expiryDate = 'expiry_date';
  static const String billingAddress = 'billing_address';
}

/// Fixed vocabulary for `action` on `payment_method_failed`.
abstract final class AnalyticsCardAction {
  static const String add = 'add';
  static const String update = 'update';
  static const String remove = 'remove';
}

/// Fixed vocabulary for `failure_reason` on `payment_method_failed`.
///
/// Narrower than [AnalyticsPurchaseFailureReason] because card-management
/// failures don't include "insufficient_wallet_balance" / "timeout" as
/// typical outcomes — the backend either accepts or rejects.
abstract final class AnalyticsCardFailureReason {
  static const String declined = 'declined';
  static const String validationError = 'validation_error';
  static const String apiError = 'api_error';

  /// Maps a raw error to the card-management failure vocab. Unknown errors
  /// fall to [apiError].
  static String classify(Object error) {
    if (error is NoInternetException || error is TimeoutException) {
      return apiError;
    }
    if (error is ServerException) return apiError;
    final msg = error.toString().toLowerCase();
    if (msg.contains('declin')) return declined;
    if (msg.contains('invalid') || msg.contains('validation')) {
      return validationError;
    }
    if (error is NetworkException) {
      final code = error.statusCode ?? 0;
      if (code >= 500) return apiError;
      if (code >= 400) return validationError;
    }
    return apiError;
  }
}

/// Fixed vocabulary for `failure_reason` on `purchase_failed`.
abstract final class AnalyticsPurchaseFailureReason {
  static const String cardDeclined = 'card_declined';
  static const String insufficientWalletBalance = 'insufficient_wallet_balance';
  static const String timeout = 'timeout';
  static const String validationError = 'validation_error';
  static const String apiError = 'api_error';

  /// Map a raw purchase error to a fixed category. Unknown errors fall to
  /// [apiError] rather than [validationError] so the vocabulary stays
  /// honest — "validation" means we actually detected a client-side-ish
  /// problem (bad body / rejected shape), not "we have no idea".
  static String classify(Object error) {
    if (error is NoInternetException || error is TimeoutException) {
      return timeout;
    }
    if (error is ServerException) return apiError;

    final msg = error.toString().toLowerCase();
    if (msg.contains('declin')) return cardDeclined;
    if (msg.contains('insufficient')) return insufficientWalletBalance;
    if (msg.contains('invalid') || msg.contains('validation')) {
      return validationError;
    }
    if (error is NetworkException) {
      final code = error.statusCode ?? 0;
      if (code >= 500) return apiError;
      if (code >= 400) return validationError;
    }
    return apiError;
  }
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

  /// `"prepaid"` or `"postpaid"` — set after login (from
  /// `AppUiConfigCubit.userType.label`) so every event can be segmented by
  /// billing type without threading `plan_type` through every call site.
  /// Addresses spec Q2 (account-type dimension on in-app events).
  static const String accountType = 'account_type';
}

/// `item_category` values used on the GA4 `purchase` event. Lets reports
/// break ecommerce purchases into bundle vs. add-on without inventing a
/// second event name.
abstract final class AnalyticsItemCategory {
  static const String plan = 'plan';
  static const String addon = 'addon';
}
