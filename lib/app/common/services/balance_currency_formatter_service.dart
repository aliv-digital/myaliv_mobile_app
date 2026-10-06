import 'package:intl/intl.dart';

class BalanceCurrencyFormatterService {
  const BalanceCurrencyFormatterService._();

  static final _fmt = NumberFormat('#,##0.00');

  static String format(num value) {
    final formattedValue = _fmt.format(value.abs());
    return value < 0 ? '\$($formattedValue)' : '\$$formattedValue';
  }

  static String formatNullable(num? value, {String placeholder = '--------'}) {
    if (value == null) return placeholder;
    return format(value);
  }
}
