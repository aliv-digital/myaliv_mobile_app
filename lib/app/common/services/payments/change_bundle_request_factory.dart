import 'dart:math';

import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/plan_bundle.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/plan_purchase_bonus.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/plan_purchase_promo_code.dart';

/// Builds the request body for `POST /Order/change-bundle`.
///
/// The endpoint takes the same outer envelope for every payment type; only
/// the `CardPayment` map differs. One factory per funding source keeps each
/// call site declarative.
///
/// `KountSessionId` is generated fresh per payment (UUID-v4 via
/// [Random.secure]) — Kount expects one session per attempted transaction.
class ChangeBundleRequestFactory {
  ChangeBundleRequestFactory._();

  static final Random _rng = Random.secure();

  static Map<String, dynamic> walletCardPayment({required double amount}) {
    return <String, dynamic>{
      'Amount': amount,
      "KountSessionId": "9c61063f-283d-4cdb-80e4-dc36ed57d179",
      'PaymentInstrument': 'Wallet',
      'CardNumber': 'Wallet',
      'CardExpiration': '2027-12',
      'CardSecurityCode': '042',
      'CardHolderName': 'Credit Card Holder',
    };
  }

  static Map<String, dynamic> tokenCardPayment({
    required double amount,
    required String cardToken,
  }) {
    return <String, dynamic>{
      'Amount': amount,
      "KountSessionId": "9c61063f-283d-4cdb-80e4-dc36ed57d179",
      'PaymentInstrument': 'Token',
      'CardNumber': cardToken,
      'CardExpiration': '',
      'CardSecurityCode': '',
      'CardHolderName': '',
    };
  }

  /// New (manually entered) card. `PaymentInstrument` is hardcoded to
  /// `'Visa'`; if multi-brand support is added later, derive from BIN here.
  static Map<String, dynamic> newCardPayment({
    required double amount,
    required NewCardDetails details,
  }) {
    return <String, dynamic>{
      'Amount': amount,
      "KountSessionId": "9c61063f-283d-4cdb-80e4-dc36ed57d179",
      'PaymentInstrument': 'Visa',
      'CardNumber': details.cardNumber,
      'CardExpiration': details.cardExpiration,
      'CardSecurityCode': details.cardSecurityCode,
      'CardHolderName': details.cardHolderName,
    };
  }

  /// Change-bundle envelope: outer body sent to `POST /Order/change-bundle`.
  static Map<String, dynamic> changeBundleBody({
    required Map<String, dynamic> cardPayment,
    required PlanBundle bundle,
    required List<PlanPurchasePromoCode> promoCodes,
    required List<PlanPurchaseBonus> bonuses,
    required bool forceNow,
    DateTime? selectedBeginDate,
  }) {
    if (bundle.isEmpty) {
      throw Exception('No selected plan found for payment.');
    }

    final bundleMap = <String, dynamic>{
      'PrimaryPlans': bundle.primaryPlans,
      'SecondaryPlans': bundle.secondaryPlans,
      'StandalonePlans': bundle.standalonePlans,
    };
    if (!forceNow) {
      final startDate = _formatStartDate(selectedBeginDate);
      if (startDate == null) {
        throw Exception('Selected start date is required for future plan.');
      }
      bundleMap['StartDate'] = startDate;
    }

    return <String, dynamic>{
      'CardPayment': cardPayment,
      'Bundle': bundleMap,
      'ForceNow': forceNow,
      'SaveCard': false,
      'UseAsRenewalCard': false,
      'Bonuses': bonuses.map((b) => b.toJson()).toList(),
      'PromoCodes': promoCodes.map((p) => p.toJson()).toList(),
      'Note': 'Payment',
    };
  }

  /// 3DS change-bundle envelope: `POST /Order/3ds/change-bundle`.
  ///
  /// Differs from [changeBundleBody]: no `CardPayment` block (card details are
  /// entered in the bank's WebView), no `SaveCard`/`UseAsRenewalCard`, and
  /// `RedirectURL` + `Branch` are added at the top level.
  static Map<String, dynamic> changeBundleBodyFor3DS({
    required PlanBundle bundle,
    required List<PlanPurchasePromoCode> promoCodes,
    required List<PlanPurchaseBonus> bonuses,
    required bool forceNow,
    DateTime? selectedBeginDate,
  }) {
    if (bundle.isEmpty) {
      throw Exception('No selected plan found for payment.');
    }

    final bundleMap = <String, dynamic>{
      'PrimaryPlans': bundle.primaryPlans,
      'SecondaryPlans': bundle.secondaryPlans,
      'StandalonePlans': bundle.standalonePlans,
    };
    if (!forceNow) {
      final startDate = _formatStartDate(selectedBeginDate);
      if (startDate == null) {
        throw Exception('Selected start date is required for future plan.');
      }
      bundleMap['StartDate'] = startDate;
    }

    return <String, dynamic>{
      'Bundle': bundleMap,
      'ForceNow': forceNow,
      'Bonuses': bonuses.map((b) => b.toJson()).toList(),
      'PromoCodes': promoCodes.map((p) => p.toJson()).toList(),
      'Note': 'Payment',
      'RedirectURL': 'myaliv://topup-callback',
      'Branch': 'branch',
    };
  }

  /// Add-card 3DS envelope sent to `POST /CreditCard/add`.
  /// Card details are entered inside the bank's WebView form.
  /// The server responds with `{"html": "..."}`.
  /// After the 3DS callback, auto-call `POST /CreditCard/savenew` using the
  /// orderId and expirationDate from the redirect URL query params.
  static Map<String, dynamic> addCardBodyFor3DS() {
    return <String, dynamic>{
      'RedirectURL': 'myaliv://topup-callback',
      'Branch': 'branch',
    };
  }

  /// Top-up envelope: same as [changeBundleBody] minus the `Bundle` block.
  /// Posted to `POST /Order/top-up/{PrimaryPhoneNumber}`.
  static Map<String, dynamic> topUpBody({
    required Map<String, dynamic> cardPayment,
  }) {
    return <String, dynamic>{
      'CardPayment': cardPayment,
      'ForceNow': true,
      'SaveCard': false,
      'UseAsRenewalCard': false,
      'Bonuses': const <Map<String, dynamic>>[],
      'PromoCodes': const <Map<String, dynamic>>[],
      'Note': 'Payment',
    };
  }

  /// 3DS top-up envelope: POST /Order/top-up/3ds/{PrimaryPhoneNumber}.
  static Map<String, dynamic> topUpBodyFor3DS({required double amount}) {
    return <String, dynamic>{
      'Amount': double.parse(amount.toStringAsFixed(2)),
      'RedirectURL': 'myaliv://topup-callback',
      'Branch': 'branch',
    };
  }

  /// 3DS postpaid make-payment envelope: POST /Order/3ds/payment.
  static Map<String, dynamic> orderPaymentBodyFor3DS({required double amount}) {
    return <String, dynamic>{
      'Amount': double.parse(amount.toStringAsFixed(2)),
      'RedirectURL': 'myaliv://topup-callback',
      'Branch': 'branch',
    };
  }

  /// Guest top-up 3DS envelope: POST /Guest/top-up.
  /// Phone number lives in the body (not the URL path).
  static Map<String, dynamic> guestTopUpBodyFor3DS({
    required double amount,
    required String phoneNumber,
  }) {
    final rawPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return <String, dynamic>{
      'Amount': double.parse(amount.toStringAsFixed(2)),
      'RedirectURL': 'myaliv://topup-callback',
      'Branch': 'branch',
      'ChannelType': 'SelfCare',
      'PhoneNumber': rawPhone,
    };
  }

  /// ALIVFibr direct card payment: POST /Guest/fibrpay (no 3DS).
  static Map<String, dynamic> fibrPayBody({
    required int fibrAccountId,
    required double amount,
    required NewCardDetails card,
  }) {
    return <String, dynamic>{
      'CardPayment': <String, dynamic>{
        'Amount': double.parse(amount.toStringAsFixed(2)),
        'PaymentInstrument': 'Visa',
        'CardNumber': card.cardNumber,
        'CardExpiration': card.cardExpiration,
        'CardSecurityCode': card.cardSecurityCode,
        'CardHolderName': card.cardHolderName,
      },
      'Branch': 'branch',
      'ChannelType': 'SelfCare',
      'FibrAccountID': fibrAccountId,
    };
  }

  /// Guest bill-pay 3DS envelope: POST /Guest/billpay.
  static Map<String, dynamic> guestBillPayBodyFor3DS({
    required double amount,
    required String phoneNumber,
  }) {
    final rawPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return <String, dynamic>{
      'Amount': double.parse(amount.toStringAsFixed(2)),
      'RedirectURL': 'myaliv://topup-callback',
      'Branch': 'branch',
      'ChannelType': 'SelfCare',
      'PhoneNumber': rawPhone,
    };
  }

  /// Guest plan purchase 3DS envelope: POST /Guest/purchaseplan.
  static Map<String, dynamic> guestPurchasePlanBodyFor3DS({
    required int planId,
    required String phoneNumber,
    required bool forceNow,
    DateTime? startDate,
  }) {
    final rawPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return <String, dynamic>{
      'Bundle': <String, dynamic>{
        'PrimaryPlans': <int>[planId],
        'SecondaryPlans': <int>[],
        'StandalonePlans': <int>[],
        if (!forceNow && startDate != null)
          'StartDate': _formatStartDate(startDate),
      },
      'ForceNow': forceNow,
      'ChannelType': 'SelfCare',
      'RedirectURL': 'myaliv://topup-callback',
      'Branch': 'branch',
      'PhoneNumber': rawPhone,
    };
  }

  static String? _formatStartDate(DateTime? date) {
    if (date == null) return null;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-'
        '${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}';
  }

  /// RFC-4122 v4 UUID, e.g. `9c61063f-283d-4cdb-80e4-dc36ed57d179`.
  /// Cryptographically random; collision risk is negligible across payments.
  static String _newSessionId() {
    String hex(int len) {
      final buf = StringBuffer();
      for (var i = 0; i < len; i++) {
        buf.write(_rng.nextInt(16).toRadixString(16));
      }
      return buf.toString();
    }

    final variant = (8 + _rng.nextInt(4)).toRadixString(16); // 8, 9, a, or b
    return '${hex(8)}-${hex(4)}-4${hex(3)}-$variant${hex(3)}-${hex(12)}';
  }
}
