import 'package:myaliv_mobile_app/app/common/services/balance_currency_formatter_service.dart';

// Product-approved Auto Top-up rules (USD). Local to Auto Top-up so the
// My Number and Send Top-up limits are unaffected.

/// ATOP-002: the threshold must be strictly between these values.
const double autoTopUpThresholdLowerBound = 10;
const double autoTopUpThresholdUpperBound = 100;

/// ATOP-004 / ATOP-005: inclusive limits for a custom top-up amount.
const double autoTopUpMinCustomAmount = 5;
const double autoTopUpMaxCustomAmount = 100;

final String autoTopUpThresholdRangeMessage =
    'amount must be above '
    '${BalanceCurrencyFormatterService.format(autoTopUpThresholdLowerBound)} '
    'and below '
    '${BalanceCurrencyFormatterService.format(autoTopUpThresholdUpperBound)}';

const String autoTopUpNoAmountMessage =
    'choose a top-up amount or enter a custom amount';

final String autoTopUpMinCustomAmountMessage =
    'the minimum top-up amount is '
    '${BalanceCurrencyFormatterService.format(autoTopUpMinCustomAmount)}';

final String autoTopUpMaxCustomAmountMessage =
    'the maximum top-up amount is '
    '${BalanceCurrencyFormatterService.format(autoTopUpMaxCustomAmount)}';

/// ATOP-002. Returns the inline error, or `null` when the threshold is valid.
String? validateAutoTopUpThreshold(double threshold) {
  if (threshold <= autoTopUpThresholdLowerBound ||
      threshold >= autoTopUpThresholdUpperBound) {
    return autoTopUpThresholdRangeMessage;
  }
  return null;
}

/// ATOP-003 / ATOP-004 / ATOP-005, in that order. A custom amount, when
/// entered, takes priority over a preset (existing behaviour); the limits
/// apply to custom amounts only. Returns `null` when the amount is valid.
String? validateAutoTopUpAmount({
  required double? customAmount,
  required int? presetAmount,
}) {
  if (customAmount != null) {
    if (customAmount < autoTopUpMinCustomAmount) {
      return autoTopUpMinCustomAmountMessage;
    }
    if (customAmount > autoTopUpMaxCustomAmount) {
      return autoTopUpMaxCustomAmountMessage;
    }
    return null;
  }
  if (presetAmount == null || presetAmount <= 0) {
    return autoTopUpNoAmountMessage;
  }
  return null;
}
