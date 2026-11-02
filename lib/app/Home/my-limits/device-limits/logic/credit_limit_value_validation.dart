final _creditLimitNumberPattern = RegExp(r'^[0-9]+$');

/// Accepts whole numbers only — decimals and signs are rejected.
String? validateCreditLimitValue(String value) {
  final text = value.trim();
  if (!_creditLimitNumberPattern.hasMatch(text)) {
    return 'invalid value';
  }
  final parsed = int.tryParse(text);
  if (parsed == null || parsed < 1) {
    return 'invalid value';
  }
  return null;
}
