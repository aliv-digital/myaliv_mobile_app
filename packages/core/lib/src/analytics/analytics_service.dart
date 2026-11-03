import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'analytics_event.dart';
import 'analytics_param.dart';

export 'analytics_event.dart';
export 'analytics_param.dart';
// Re-export AnalyticsEventItem so feature code can build ecommerce item
// lists without importing firebase_analytics directly.
export 'package:firebase_analytics/firebase_analytics.dart'
    show AnalyticsEventItem;

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
    await clearUserId();
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

  /// Set the GA4 `user_id` to a SHA-256 hash of [rawUserId]. This is the
  /// Firebase SDK's dedicated identifier — distinct from the per-event
  /// `hashed_user_id` param — and is what powers DAU / MAU / retention
  /// reports in GA4.
  ///
  /// Call once per authenticated session, immediately after [logLogin].
  /// An empty [rawUserId] is a no-op (the SDK call would clear the id).
  Future<void> setUserId(String rawUserId) async {
    if (!_initialized || _analytics == null) return;
    if (rawUserId.isEmpty) return;
    try {
      await _analytics!.setUserId(id: _sha256(rawUserId));
      if (kDebugMode) {
        debugPrint('📊 Analytics setUserId → <sha256 digest>');
      }
    } catch (e) {
      debugPrint('⚠️ AnalyticsService: failed to set user_id — $e');
    }
  }

  /// Clear the GA4 `user_id`. Call on logout alongside [setLoggedOut].
  Future<void> clearUserId() async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.setUserId(id: null);
      if (kDebugMode) debugPrint('📊 Analytics setUserId → null');
    } catch (e) {
      debugPrint('⚠️ AnalyticsService: failed to clear user_id — $e');
    }
  }

  /// Set the `account_type` user property to `"prepaid"` or `"postpaid"`.
  /// Pass the string from `AppUiConfigCubit.userType.label`. Call after
  /// login (and whenever the active line switches, since prepaid/postpaid
  /// can differ per line).
  Future<void> setAccountType(String accountType) async {
    if (!_initialized || _analytics == null) return;
    if (accountType.isEmpty) return;
    try {
      await _analytics!.setUserProperty(
        name: AnalyticsUserProperty.accountType,
        value: accountType,
      );
      if (kDebugMode) {
        debugPrint('📊 Analytics userProperty → account_type=$accountType');
      }
    } catch (e) {
      debugPrint('⚠️ AnalyticsService: failed to set account_type — $e');
    }
  }

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
  Future<void> logPasswordResetFailed({required String failureReason}) => _log(
        AnalyticsEvent.passwordResetFailed,
        params: {AnalyticsParam.failureReason: failureReason},
      );

  // ── Wallet ────────────────────────────────────────────────────────────────

  /// Log a successful prepaid wallet top-up. GA4 event name: `add_wallet_funds`
  /// (per Phase-1 spec; was previously called `wallet_top_up`).
  ///
  /// [amount]        – amount topped up in BSD.
  /// [paymentMethod] – one of [AnalyticsPaymentType] (`credit_card` default
  ///                   since Q10 blocks the debit/credit split).
  Future<void> logAddWalletFunds({
    required double amount,
    required String paymentMethod,
  }) =>
      _log(
        AnalyticsEvent.addWalletFunds,
        params: {
          AnalyticsParam.amount: amount,
          AnalyticsParam.currency: 'BSD',
          AnalyticsParam.paymentMethod: paymentMethod,
        },
      );

  /// Log the user entering the wallet top-up flow — before any payment is
  /// attempted. Combined with [logAddWalletFunds] / [logAddWalletFundsFailed]
  /// this exposes the top-up funnel in reports.
  Future<void> logAddWalletFundsStarted() =>
      _log(AnalyticsEvent.addWalletFundsStarted);

  /// Log a failed wallet top-up. [failureReason] is one of
  /// [AnalyticsPurchaseFailureReason] (same vocab — "card_declined" etc.).
  Future<void> logAddWalletFundsFailed({
    required String failureReason,
    required String paymentMethod,
  }) =>
      _log(
        AnalyticsEvent.addWalletFundsFailed,
        params: {
          AnalyticsParam.failureReason: failureReason,
          AnalyticsParam.paymentMethod: paymentMethod,
        },
      );

  /// Log the user viewing the wallet balance surface. In the current build
  /// the "wallet balance" lives on the top-up entry screen — if product
  /// adds a dedicated Wallet screen later, migrate the fire site.
  Future<void> logWalletBalanceViewed() =>
      _log(AnalyticsEvent.walletBalanceViewed);

  // ── Payment methods (card management) ─────────────────────────────────────
  //
  // These fire from the "add / edit / remove saved card" surfaces — NOT
  // from checkout-time payment selection (that's `logAddPaymentInfo` in
  // the Commerce section, which includes `items[]`).

  /// Log a successful "card saved to account" action. Fires GA4's standard
  /// `add_payment_info` with only `payment_type` — the absence of `items`
  /// disambiguates this from the checkout-time variant in reports.
  Future<void> logPaymentMethodAdded({
    String paymentType = AnalyticsCardType.creditCard,
  }) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logAddPaymentInfo(paymentType: paymentType);
      if (kDebugMode) {
        debugPrint(
            '📊 Analytics → "add_payment_info" [card-save] $paymentType');
      }
    } catch (e) {
      debugPrint(
          '⚠️ AnalyticsService: failed to log card-save add_payment_info — $e');
    }
  }

  /// Log a successful card removal.
  Future<void> logPaymentMethodRemoved({
    String cardType = AnalyticsCardType.unknown,
  }) =>
      _log(
        AnalyticsEvent.paymentMethodRemoved,
        params: {AnalyticsParam.cardType: cardType},
      );

  /// Log a failure during any card-management action. [action] = one of
  /// [AnalyticsCardAction]; [failureReason] = one of
  /// [AnalyticsCardFailureReason].
  Future<void> logPaymentMethodFailed({
    required String action,
    required String failureReason,
    String cardType = AnalyticsCardType.unknown,
  }) =>
      _log(
        AnalyticsEvent.paymentMethodFailed,
        params: {
          AnalyticsParam.action: action,
          AnalyticsParam.cardType: cardType,
          AnalyticsParam.failureReason: failureReason,
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
    String? promoCode,
    String? fundingSource,
    String? planType,
  }) async {
    if (!_initialized || _analytics == null) {
      debugPrint(
          '⚠️ AnalyticsService: not initialized, skipping event "purchase"');
      return;
    }
    try {
      final params = <String, Object>{
        AnalyticsParam.paymentMethod: paymentMethod,
        AnalyticsParam.promoCodeApplied:
            promoCode != null && promoCode.isNotEmpty,
      };
      if (promoCode != null && promoCode.isNotEmpty) {
        params[AnalyticsParam.promoCode] = promoCode;
      }
      if (fundingSource != null && fundingSource.isNotEmpty) {
        params[AnalyticsParam.fundingSource] = fundingSource;
      }
      if (planType != null && planType.isNotEmpty) {
        params[AnalyticsParam.planType] = planType;
      }
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
        parameters: params,
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

  // ── Self-serve ────────────────────────────────────────────────────────────

  /// Log an account-detail edit. [status] = `attempted` is fired when the
  /// user submits; [status] = `completed` is fired after the API succeeds.
  /// The field value (new email, new address, …) is NEVER attached — only
  /// the category in [fieldType].
  Future<void> logAccountDetailsUpdated({
    required String fieldType,
    required String status,
  }) =>
      _log(
        AnalyticsEvent.accountDetailsUpdated,
        params: {
          AnalyticsParam.fieldType: fieldType,
          AnalyticsParam.status: status,
        },
      );

  /// Log the user landing on a surface that shows their remaining data
  /// balance. Fired once per surface entry (not per rebuild), so GA4 can
  /// report unique users + frequency rather than cardinality.
  Future<void> logDataBalanceViewed() => _log(AnalyticsEvent.dataBalanceViewed);

  /// Log the user opening their current-plan / account summary.
  /// [planType] is `prepaid` or `postpaid` (from `UserType.label`).
  Future<void> logPlanSummaryViewed({required String planType}) => _log(
        AnalyticsEvent.planSummaryViewed,
        params: {AnalyticsParam.planType: planType},
      );

  /// Log a successful invoice view (PDF opened). Fires on both cache-hit
  /// and fresh-download paths — tracks views independently of downloads.
  Future<void> logInvoiceViewed() => _log(AnalyticsEvent.invoiceViewed);

  /// Log a completed invoice download — only on fresh download/save, not
  /// on cache hits (the file is already on disk).
  Future<void> logInvoiceDownloaded() => _log(AnalyticsEvent.invoiceDownloaded);

  /// Log the user switching the active account / mobile line via the
  /// phone-number dropdown.
  Future<void> logAccountLineSwitched() =>
      _log(AnalyticsEvent.accountLineSwitched);

  // ── Commerce funnel ───────────────────────────────────────────────────────

  /// Log the user viewing a plan catalogue surface. Uses GA4's native
  /// `view_item_list` so the ecommerce funnel in Monetisation reports is
  /// populated end-to-end.
  Future<void> logViewItemList({
    required String itemListName,
    required List<AnalyticsEventItem> items,
  }) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logViewItemList(
        itemListName: itemListName,
        items: items,
      );
      if (kDebugMode) {
        debugPrint(
            '📊 Analytics → "view_item_list" [$itemListName] ${items.length} items');
      }
    } catch (e) {
      debugPrint('⚠️ AnalyticsService: failed to log "view_item_list" — $e');
    }
  }

  /// Log the user tapping a specific plan in a catalogue surface.
  Future<void> logSelectItem({
    required String itemListName,
    required AnalyticsEventItem item,
  }) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logSelectItem(
        itemListName: itemListName,
        items: [item],
      );
      if (kDebugMode) {
        debugPrint(
            '📊 Analytics → "select_item" [$itemListName] ${item.itemId}');
      }
    } catch (e) {
      debugPrint('⚠️ AnalyticsService: failed to log "select_item" — $e');
    }
  }

  /// Log the user entering the checkout screen for one or more plans.
  Future<void> logBeginCheckout({
    required double value,
    required List<AnalyticsEventItem> items,
  }) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logBeginCheckout(
        currency: 'BSD',
        value: value,
        items: items,
      );
      if (kDebugMode) {
        debugPrint('📊 Analytics → "begin_checkout" $value BSD');
      }
    } catch (e) {
      debugPrint('⚠️ AnalyticsService: failed to log "begin_checkout" — $e');
    }
  }

  /// Log the user committing to a specific payment method, before submit.
  /// [paymentType] is one of [AnalyticsPaymentType].
  Future<void> logAddPaymentInfo({
    required String paymentType,
    required double value,
    required List<AnalyticsEventItem> items,
  }) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logAddPaymentInfo(
        paymentType: paymentType,
        currency: 'BSD',
        value: value,
        items: items,
      );
      if (kDebugMode) {
        debugPrint('📊 Analytics → "add_payment_info" $paymentType');
      }
    } catch (e) {
      debugPrint('⚠️ AnalyticsService: failed to log "add_payment_info" — $e');
    }
  }

  /// Log a payment submission *before* the API result is known. The matching
  /// `purchase` or `purchase_failed` event follows.
  Future<void> logPurchaseAttempted({
    required String paymentMethod,
    required double value,
    required String planType,
  }) =>
      _log(
        AnalyticsEvent.purchaseAttempted,
        params: {
          AnalyticsParam.paymentMethod: paymentMethod,
          AnalyticsParam.amount: value,
          AnalyticsParam.currency: 'BSD',
          AnalyticsParam.planType: planType,
        },
      );

  /// Log a payment failure. [failureReason] must be a fixed value from
  /// [AnalyticsPurchaseFailureReason] — use `classify()` for raw exceptions.
  Future<void> logPurchaseFailed({
    required String failureReason,
    required String paymentMethod,
    required double value,
  }) =>
      _log(
        AnalyticsEvent.purchaseFailed,
        params: {
          AnalyticsParam.failureReason: failureReason,
          AnalyticsParam.paymentMethod: paymentMethod,
          AnalyticsParam.amount: value,
          AnalyticsParam.currency: 'BSD',
        },
      );

  /// Log the user tapping into a specific promotion (e.g. a limited-time
  /// offer on the Home screen). Uses GA4's native `select_promotion`.
  Future<void> logSelectPromotion({
    required String promotionId,
    required String promotionName,
  }) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logSelectPromotion(
        promotionId: promotionId,
        promotionName: promotionName,
      );
      if (kDebugMode) {
        debugPrint(
            '📊 Analytics → "select_promotion" $promotionId / $promotionName');
      }
    } catch (e) {
      debugPrint('⚠️ AnalyticsService: failed to log "select_promotion" — $e');
    }
  }

  /// Log the user viewing their rewards balance. Prepaid-only surface.
  Future<void> logRewardsBalanceViewed() =>
      _log(AnalyticsEvent.rewardsBalanceViewed);

  /// Log the user tapping an in-app link that redirects to an external
  /// web property (e.g. Store Locator → bealiv.com). Activity *after* the
  /// redirect belongs to web analytics on the destination site.
  Future<void> logOutboundClick({
    required String linkDestination,
    required String linkUrl,
  }) =>
      _log(
        AnalyticsEvent.outboundClick,
        params: {
          AnalyticsParam.linkDestination: linkDestination,
          AnalyticsParam.linkUrl: linkUrl,
        },
      );

  // ── Auto-Pay ──────────────────────────────────────────────────────────────
  //
  // Shared across prepaid auto-renew, prepaid auto-topup, and postpaid
  // auto-pay. GA4 segments by the `account_type` user property; no need to
  // thread the flow variant through every call site.

  /// Log the user flipping the Auto-Pay switch ON or OFF. [state] is
  /// [AnalyticsAutopayState.on] / [.off]. [paymentMethod] is optional —
  /// only attach when the flow actually knows it at toggle time (OFF path
  /// usually doesn't; ON is fired after setup completes with the method).
  Future<void> logAutopayToggle({
    required String state,
    String? paymentMethod,
    String? reason,
  }) {
    final params = <String, Object>{AnalyticsParam.state: state};
    if (paymentMethod != null && paymentMethod.isNotEmpty) {
      params[AnalyticsParam.paymentMethod] = paymentMethod;
    }
    if (reason != null && reason.isNotEmpty) {
      params[AnalyticsParam.reason] = reason;
    }
    return _log(AnalyticsEvent.autopayToggle, params: params);
  }

  /// Log entering the Auto-Pay setup flow (screen entry).
  Future<void> logAutopaySetupStarted() =>
      _log(AnalyticsEvent.autopaySetupStarted);

  /// Log successful completion of the multi-step Auto-Pay setup.
  /// [paymentMethod] is one of [AnalyticsPaymentType] (`wallet`, `credit_card`,
  /// or `charge_to_account` for postpaid-invoice).
  Future<void> logAutopaySetupCompleted({required String paymentMethod}) =>
      _log(
        AnalyticsEvent.autopaySetupCompleted,
        params: {AnalyticsParam.paymentMethod: paymentMethod},
      );

  /// Log a terminal failure during Auto-Pay setup. [failureReason] is one
  /// of [AnalyticsAutopaySetupFailureReason] — use `.classify(error)` to
  /// map a raw exception.
  Future<void> logAutopaySetupFailed({required String failureReason}) => _log(
        AnalyticsEvent.autopaySetupFailed,
        params: {AnalyticsParam.failureReason: failureReason},
      );

  // ── Screen view ───────────────────────────────────────────────────────────

  /// Fire GA4's standard `screen_view` manually. Preferred route for modals
  /// / dialogs / sub-sections that aren't full navigation stops — those
  /// aren't captured by GoRouter-attached observers.
  ///
  /// For automatic screen_view across every navigation, attach
  /// `FirebaseAnalyticsObserver` to the router (requires each `GoRoute` to
  /// define `name:` — see §13 in the analytics doc).
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_initialized || _analytics == null) return;
    try {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
      if (kDebugMode) {
        debugPrint('📊 Analytics → "screen_view" $screenName');
      }
    } catch (e) {
      debugPrint('⚠️ AnalyticsService: failed to log "screen_view" — $e');
    }
  }

  /// Log the user landing on the Support/Help screen — BEFORE they pick a
  /// channel (chat / FAQ / store locator / etc.). Measures support demand
  /// independently of the channel breakdown.
  Future<void> logSupportScreenViewed() =>
      _log(AnalyticsEvent.supportScreenViewed);

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
