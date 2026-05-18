class BalanceCurrencyFormatterService {
  const BalanceCurrencyFormatterService._();

  static String format(num value) {
    final formattedValue = value.abs().toStringAsFixed(2);
    return value < 0 ? '\$($formattedValue)' : '\$$formattedValue';
  }

  static String formatNullable(
    num? value, {
    String placeholder = '--------',
  }) {
    if (value == null) return placeholder;
    return format(value);
  }
}
