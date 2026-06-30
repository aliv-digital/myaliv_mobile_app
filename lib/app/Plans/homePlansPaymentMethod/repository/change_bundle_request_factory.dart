import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';

/// Builds request payloads for `POST /Order/change-bundle`.
///
/// The endpoint accepts different `CardPayment` blocks depending on the
/// funding source (wallet, saved-card token, etc.). Everything outside
/// `CardPayment` is identical, so the body shape is built once and only
/// the `CardPayment` map varies per caller.
class ChangeBundleRequestFactory {
  ChangeBundleRequestFactory._();

  // TODO: replace with a per-payment id from a Kount SDK.
  static const String _kountSessionId = '9c61063f-283d-4cdb-80e4-dc36ed57d179';

  static Map<String, dynamic> walletCardPayment({required double amount}) {
    return <String, dynamic>{
      'Amount': amount,
      'KountSessionId': _kountSessionId,
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
      'KountSessionId': _kountSessionId,
      'PaymentInstrument': 'Token',
      'CardNumber': cardToken,
      'CardExpiration': '',
      'CardSecurityCode': '',
      'CardHolderName': '',
    };
  }

  static Map<String, dynamic> body({
    required Map<String, dynamic> cardPayment,
    required List<HomePlansPaymentSelectedItem> selectedItems,
    required bool forceNow,
    DateTime? selectedBeginDate,
  }) {
    final bundle = _buildBundle(selectedItems);

    if (!forceNow) {
      final startDate = _formatStartDate(selectedBeginDate);
      if (startDate == null) {
        throw Exception('Selected start date is required for future plan.');
      }
      bundle['StartDate'] = startDate;
    }

    return <String, dynamic>{
      'CardPayment': cardPayment,
      'Bundle': bundle,
      'ForceNow': forceNow,
      'SaveCard': false,
      'UseAsRenewalCard': false,
      'Bonuses': const <Map<String, dynamic>>[],
      'PromoCodes': const <Map<String, dynamic>>[],
      'Note': 'Payment',
    };
  }

  static Map<String, dynamic> _buildBundle(
    List<HomePlansPaymentSelectedItem> items,
  ) {
    final primary = <int>[];
    final secondary = <int>[];
    final standalone = <int>[];

    for (final item in items) {
      final planId = int.tryParse(item.id.trim());
      if (planId == null) {
        throw Exception('Invalid plan id for ${item.title}.');
      }
      switch (item.planType) {
        case HomePlansPaymentPlanType.primary:
          primary.add(planId);
          break;
        case HomePlansPaymentPlanType.secondary:
          secondary.add(planId);
          break;
        case HomePlansPaymentPlanType.standalone:
          standalone.add(planId);
          break;
      }
    }

    if (primary.isEmpty && secondary.isEmpty && standalone.isEmpty) {
      throw Exception('No selected plan found for payment.');
    }

    return <String, dynamic>{
      'PrimaryPlans': primary,
      'SecondaryPlans': secondary,
      'StandalonePlans': standalone,
    };
  }

  static String? _formatStartDate(DateTime? date) {
    if (date == null) return null;
    String two(int v) => v.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-'
        '${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}';
  }
}
