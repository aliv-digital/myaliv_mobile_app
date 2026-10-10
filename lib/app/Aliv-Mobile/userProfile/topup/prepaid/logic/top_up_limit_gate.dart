import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/common/services/balance_currency_formatter_service.dart';
import 'package:myaliv_mobile_app/core/utils/appUtils.dart';

/// Result of a top-up / send-top-up pre-flight check. `null` message = pass.
class TopUpGateResult {
  final String? errorMessage;

  /// Case B (TOP-003) is shown inline on the amount field; others are toasts.
  final bool isPerTransactionLimit;

  const TopUpGateResult(
    this.errorMessage, {
    this.isPerTransactionLimit = false,
  });

  static const TopUpGateResult pass = TopUpGateResult(null);

  bool get blocked => errorMessage != null;
}

const _supportPhone = '1-242-300-2548';

const _caseAMessage =
    'your top up limit is not set on your account. to process this payment, please contact support at $_supportPhone';

const _caseDMessage =
    'please try again in a few minutes. if this continues, contact support at $_supportPhone';

// TOP-003: the limit stays the account's `topUpPerTransLimit`.
String _caseBMessage(double perTxLimit) =>
    'the maximum top-up amount is ${BalanceCurrencyFormatterService.format(perTxLimit)}';

String _caseCMessage(double dailyLimit) =>
    'your daily top up limit is ${AppUtils.formatPrice(dailyLimit)}. please try a smaller amount to complete your transaction.';

/// My Number tab gate. Applies A/B/C/D per the vendor spec, using the
/// account-level top-up fields (NOT the transfer money fields).
///
/// - A: EITHER `topUpPerTransLimit` OR `topUp24HourLimit` is null/0 —
///   the vendor spec says "Limit not set (NULL or $0.00)" without naming
///   which limit, so both must be configured to skip Case A. Otherwise
///   Case C would render "$0.00" as the daily ceiling.
/// - B: amount > `topUpPerTransLimit`
/// - C: amount > `topUp24HourLimitLeft` (message shows the ceiling)
/// - D: any required data missing / endpoint failed
TopUpGateResult evaluateMyNumberTopUpGate({
  required double amount,
  required AccountInfoModel? account,
  required double? limitLeft,
  required bool limitFetchFailed,
}) {
  if (account == null || limitFetchFailed || limitLeft == null) {
    return const TopUpGateResult(_caseDMessage);
  }

  final perTx = account.topUpPerTransLimit;
  final dailyCap = account.topUp24HourLimit;

  if (perTx <= 0 || dailyCap <= 0) {
    return const TopUpGateResult(_caseAMessage);
  }
  if (amount > perTx) {
    return TopUpGateResult(_caseBMessage(perTx), isPerTransactionLimit: true);
  }
  if (amount > limitLeft) return TopUpGateResult(_caseCMessage(dailyCap));

  return TopUpGateResult.pass;
}
