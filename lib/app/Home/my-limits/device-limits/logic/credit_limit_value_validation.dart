final _creditLimitNumberPattern = RegExp(
  r'^(?:[0-9]+(?:\.[0-9]+)?)$',
);

/// Accepts non-fractional decimals only — the integer part must be >= 1.
String? validateCreditLimitValue(String value) {
  final text = value.trim();
  if (!_creditLimitNumberPattern.hasMatch(text)) {
    return 'invalid value';
  }
  final parsed = double.tryParse(text);
  if (parsed == null || !parsed.isFinite || parsed < 1) {
    return 'invalid value';
  }
  return null;
}
