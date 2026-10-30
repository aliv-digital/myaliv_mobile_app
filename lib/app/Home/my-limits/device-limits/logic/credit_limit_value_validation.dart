final _creditLimitNumberPattern = RegExp(
  r'^[+-]?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)$',
);

/// Validates numeric notation only; credit-limit ranges stay unchanged.
String? validateCreditLimitValue(String value) {
  final text = value.trim();
  if (!_creditLimitNumberPattern.hasMatch(text) ||
      double.tryParse(text)?.isFinite != true) {
    return 'invalid value';
  }
  return null;
}
