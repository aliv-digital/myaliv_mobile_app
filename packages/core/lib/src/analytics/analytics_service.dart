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
/// await analytics.logLogin();
///
/// // Plans
/// await analytics.logPlanPurchase(
///   planId: '18933',
///   planName: 'Travel 30',
///   amount: 30.00,
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

  /// Log a successful OTP login.
  Future<void> logLogin() => _log(
        AnalyticsEvent.login,
        params: {AnalyticsParam.method: 'otp'},
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

  // ── Plans ─────────────────────────────────────────────────────────────────

  /// Log a successful plan (bundle) purchase.
  ///
  /// [planId]        – server-side plan ID (e.g. "18933").
  /// [planName]      – human-readable plan name (e.g. "Travel 30").
  /// [amount]        – plan price in BSD.
  /// [paymentMethod] – e.g. "saved_card", "new_card", "wallet".
  Future<void> logPlanPurchase({
    required String planId,
    required String planName,
    required double amount,
    required String paymentMethod,
  }) =>
      _log(
        AnalyticsEvent.planPurchase,
        params: {
          AnalyticsParam.planId: planId,
          AnalyticsParam.planName: planName,
          AnalyticsParam.amount: amount,
          AnalyticsParam.currency: 'BSD',
          AnalyticsParam.paymentMethod: paymentMethod,
        },
      );

  /// Log a successful add-on purchase.
  ///
  /// [addonId]       – server-side add-on ID.
  /// [addonName]     – human-readable add-on name.
  /// [amount]        – add-on price in BSD.
  /// [paymentMethod] – e.g. "saved_card", "new_card", "wallet".
  Future<void> logAddonPurchase({
    required String addonId,
    required String addonName,
    required double amount,
    required String paymentMethod,
  }) =>
      _log(
        AnalyticsEvent.addonPurchase,
        params: {
          AnalyticsParam.addonId: addonId,
          AnalyticsParam.addonName: addonName,
          AnalyticsParam.amount: amount,
          AnalyticsParam.currency: 'BSD',
          AnalyticsParam.paymentMethod: paymentMethod,
        },
      );

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
  Future<void> logSupportChatOpened() =>
      _log(AnalyticsEvent.supportChatOpened);

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
}
