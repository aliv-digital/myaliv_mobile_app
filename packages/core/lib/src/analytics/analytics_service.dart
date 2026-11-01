import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'analytics_event.dart';
import 'analytics_param.dart';

export 'analytics_event.dart';
export 'analytics_param.dart';

/// Centralised Firebase Analytics service for the My Aliv app.
///
/// All custom GA4 events are surfaced as typed methods here, keeping
/// event names and parameter keys out of feature BLoCs/Cubits.
///
/// Usage (after DI is initialised):
/// ```dart
/// final analytics = instance<AnalyticsService>();
///
/// // Auth
/// await analytics.logLogin(userId: apiPhoneNumber);
/// await analytics.setLoggedIn();
///
/// // Plans / add-ons (both fire GA4's standard `purchase` event)
/// await analytics.logPurchase(
///   itemId: '18933',
///   itemName: 'Travel 30',
///   itemCategory: AnalyticsItemCategory.plan,
///   amount: 30.00,
///   paymentMethod: 'saved_card',
/// );
/// ```
///
/// ⚠️ Firebase.initializeApp() must be called in main() before
///    CoreInjection.initInjection() registers this service.
class AnalyticsService {
  FirebaseAnalytics? _analytics;
  bool _initialized = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Initialise the Firebase Analytics instance.
  ///
  /// Silently no-ops if Firebase is not yet configured (i.e. the
  /// google-services.json / GoogleService-Info.plist files are absent).
  /// All subsequent log calls will be silent no-ops in that case.
  Future<void> init() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      _initialized = true;
      debugPrint('✅ AnalyticsService initialized');
    } catch (e) {
      debugPrint('⚠️ AnalyticsService: Firebase not available — $e');
    }
  }

  bool get isInitialized => _initialized;

  // ── Auth ──────────────────────────────────────────────────────────────────

  /// Log a successful login.
  ///
  /// [userId] – stable per-user identifier (phone number / account id). It is
  /// hashed with SHA-256 before being sent, so GA4 only ever sees the hash;
  /// an empty [userId] skips the `hashed_user_id` param but still logs the
  /// event.
  /// [method] – one of [AnalyticsLoginMethod]. Defaults to `otp` since OTP
  /// is currently the only wired fire site; biometric / password paths will
  /// override this when they're instrumented.
  Future<void> logLogin({
    required String userId,
    String method = AnalyticsLoginMethod.otp,
  }) {
    final params = <String, Object>{AnalyticsParam.method: method};
    if (userId.isNotEmpty) {
      params[AnalyticsParam.hashedUserId] = _sha256(userId);
    }
    return _log(AnalyticsEvent.login, params: params);
  }

  /// Log a failed login attempt that reached the server (incorrect code,
  /// locked account, 5xx, …). Do NOT fire for client-side validation
  /// (empty / incomplete code, offline guard) — those never hit auth.
  ///
  /// [method]        – one of [AnalyticsLoginMethod].
  /// [failureReason] – one of [AnalyticsLoginFailureReason]; use
  ///                   `AnalyticsLoginFailureReason.classify(error, …)` to map
  ///                   a raw exception to the fixed vocab.
  Future<void> logLoginFailure({
    required String method,
    required String failureReason,
  }) =>
      _log(
        AnalyticsEvent.loginFailure,
        params: {
          AnalyticsParam.method: method,
          AnalyticsParam.failureReason: failureReason,
        },
      );

  /// Log an explicit user-initiated logout. Also flips the `logged_in` user
  /// property to `"false"` for subsequent events.
  ///
  /// Fire only from the menu / settings logout action — NOT from session
  /// timeout or hard-logout triggered by refresh-token failure (those are
  /// involuntary and should be tracked separately if at all).
  Future<void> logLogout() async {
    await _log(AnalyticsEvent.logout);
    await setLoggedOut();
  }

  /// Mark the current Firebase user as authenticated.
  ///
  /// Sets the `logged_in` user property to `"true"` so every subsequent event
  /// in this GA4 session is tagged as authenticated. Call this after
  /// [logLogin] (and after successful silent re-auth / biometric unlock).
  Future<void> setLoggedIn() => _setLoggedIn(true);

  /// Mark the current Firebase user as logged out. Flips `logged_in` to
  /// `"false"` for all subsequent events in this session.
  Future<void> setLoggedOut() => _setLoggedIn(false);

  // ── OTP funnel ────────────────────────────────────────────────────────────
  //
  // Shared across login + password-reset flows. GA4 reports can split the
  // funnel by the preceding event (`login` vs `password_reset_started`) if
  // channel-level breakdown isn't enough.

  /// Log an OTP code being requested (initial send or user-triggered resend).
  Future<void> logOtpRequested({
    String otpChannel = AnalyticsOtpChannel.sms,
  }) =>
      _log(
        AnalyticsEvent.otpRequested,
        params: {AnalyticsParam.otpChannel: otpChannel},
      );

  /// Log a successful OTP verification. The matching `login` or
  /// `password_reset_completed` event will fire separately immediately after.
  Future<void> logOtpVerified({
    String otpChannel = AnalyticsOtpChannel.sms,
  }) =>
      _log(
        AnalyticsEvent.otpVerified,
        params: {AnalyticsParam.otpChannel: otpChannel},
      );

  /// Log an OTP verification failure. [failureReason] must come from
  /// [AnalyticsOtpFailureReason] — if `classify()` returns `null`, don't
  /// call this (the error will be covered by `login_failure` /
  /// `password_reset_failed`).
  Future<void> logOtpFailed({
    required String failureReason,
    String otpChannel = AnalyticsOtpChannel.sms,
  }) =>
      _log(
        AnalyticsEvent.otpFailed,
        params: {
          AnalyticsParam.otpChannel: otpChannel,
          AnalyticsParam.failureReason: failureReason,
        },
      );

  // ── Password reset ────────────────────────────────────────────────────────

  /// Log the user entering the password-reset flow (first API call after
  /// phone/email entry).
  Future<void> logPasswordResetStarted() =>
      _log(AnalyticsEvent.passwordResetStarted);

  /// Log successful save of the new password.
  Future<void> logPasswordResetCompleted() =>
      _log(AnalyticsEvent.passwordResetCompleted);

  /// Log a terminal failure at any step of the password-reset flow.
  Future<void> logPasswordResetFailed({required String failureReason}) =>
      _log(
        AnalyticsEvent.passwordResetFailed,
        params: {AnalyticsParam.failureReason: failureReason},
      );

  // ── Wallet ────────────────────────────────────────────────────────────────

  /// Log a successful prepaid wallet top-up.
  ///
  /// [amount]        – amount topped up in BSD.
  /// [paymentMethod] – e.g. "saved_card", "new_card", "wallet".
  Future<void> logWalletTopUp({
    required double amount,
    required String paymentMethod,
  }) =>
      _log(
        AnalyticsEvent.walletTopUp,
        params: {
          AnalyticsParam.amount: amount,
          AnalyticsParam.currency: 'BSD',
          AnalyticsParam.paymentMethod: paymentMethod,
        },
      );

  /// Log a successful wallet-to-wallet transfer / funding.
  ///
  /// [amount]        – amount transferred in BSD.
  /// [paymentMethod] – e.g. "wallet".
  Future<void> logWalletFunding({
    required double amount,
    required String paymentMethod,
  }) =>
      _log(
        AnalyticsEvent.walletFunding,
        params: {
          AnalyticsParam.amount: amount,
          AnalyticsParam.currency: 'BSD',
          AnalyticsParam.paymentMethod: paymentMethod,
        },
      );

  // ── Plans & Add-ons ───────────────────────────────────────────────────────

  /// Log a successful plan or add-on purchase.
  ///
  /// Fires GA4's standard `purchase` ecommerce event so the sale shows up in
  /// Monetisation → Ecommerce purchases. [itemCategory] (`plan` or `addon`)
  /// is the only thing that distinguishes a bundle from an add-on in reports.
  ///
  /// [itemId]        – server-side ID (e.g. "18933").
  /// [itemName]      – human-readable name (e.g. "Travel 30").
  /// [itemCategory]  – `AnalyticsItemCategory.plan` or `.addon`.
  /// [amount]        – price in BSD.
  /// [paymentMethod] – e.g. "saved_card", "new_card", "wallet".
  /// [transactionId] – server-side order id. Omit when not available (e.g.
  ///                   `pay_now` on a saved payment method returns no order).
  ///                   GA4 uses this to deduplicate repeat events.
  Future<void> logPurchase({
    required String itemId,
    required String itemName,
    required String itemCategory,
    required double amount,
    required String paymentMethod,
    String? transactionId,
  }) async {
    if (!_initialized || _analytics == null) {
      debugPrint(
          '⚠️ AnalyticsService: not initialized, skipping event "purchase"');
      return;
    }
    try {
      await _analytics!.logPurchase(
        currency: 'BSD',
        value: amount,
        transactionId: transactionId,
        items: [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
            itemCategory: itemCategory,
            price: amount,
            quantity: 1,
          ),
        ],
        parameters: {AnalyticsParam.paymentMethod: paymentMethod},
      );
      if (kDebugMode) {
        final txn = transactionId == null ? '' : ' txn=$transactionId';
        debugPrint(
            '📊 Analytics → "purchase" [$itemCategory] $itemId @ $amount BSD via $paymentMethod$txn');
      }
    } catch (e) {
      debugPrint('⚠️ AnalyticsService: failed to log "purchase" — $e');
    }
  }

  // ── Payments ──────────────────────────────────────────────────────────────

  /// Log a successful bill payment.
  ///
  /// [amount]        – amount paid in BSD.
  /// [paymentMethod] – e.g. "saved_card", "new_card".
  Future<void> logBillPayment({
    required double amount,
    required String paymentMethod,
  }) =>
      _log(
        AnalyticsEvent.billPayment,
        params: {
          AnalyticsParam.amount: amount,
          AnalyticsParam.currency: 'BSD',
          AnalyticsParam.paymentMethod: paymentMethod,
        },
      );

  // ── Support ───────────────────────────────────────────────────────────────

  /// Log when the user navigates to the support chatbot.
  Future<void> logSupportChatOpened() => _log(AnalyticsEvent.supportChatOpened);

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _log(
    String eventName, {
    Map<String, Object>? params,
  }) async {
    if (!_initialized || _analytics == null) {
      debugPrint(
          '⚠️ AnalyticsService: not initialized, skipping event "$eventName"');
      return;
    }
    try {
      await _analytics!.logEvent(name: eventName, parameters: params);
      if (kDebugMode) {
        debugPrint('📊 Analytics → "$eventName" $params');
      }
    } catch (e) {
      debugPrint('⚠️ AnalyticsService: failed to log "$eventName" — $e');
    }
  }

  Future<void> _setLoggedIn(bool loggedIn) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.setUserProperty(
        name: AnalyticsUserProperty.loggedIn,
        value: loggedIn ? 'true' : 'false',
      );
      if (kDebugMode) {
        debugPrint('📊 Analytics userProperty → logged_in=$loggedIn');
      }
    } catch (e) {
      debugPrint('⚠️ AnalyticsService: failed to set logged_in — $e');
    }
  }

  static String _sha256(String input) =>
      sha256.convert(utf8.encode(input)).toString();
}
