import 'package:flutter/services.dart';

/// Strips non-digits and inserts a space every 4 chars, e.g.
/// `4012000000020006` → `4012 0000 0000 0006`. Caps at 19 digits.
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'\D'), '');
    final digits = raw.length > 19 ? raw.substring(0, 19) : raw;
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Strips non-digits and formats as `MM/YY` while typing.
class ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(RegExp(r'\D'), '');
    final digits = raw.length > 4 ? raw.substring(0, 4) : raw;
    String text = digits;
    if (digits.length >= 3) {
      text = '${digits.substring(0, 2)}/${digits.substring(2)}';
    } else if (digits.length == 2) {
      text = '$digits/';
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class CardValidators {
  CardValidators._();

  /// Returns digits-only PAN if it is 13–19 digits long, else null.
  static String? cardNumber(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) return null;
    return digits;
  }

  /// Accepts `MM/YY` or `MMYY`. Returns `"YYYY-MM"` for the current century
  /// if month is 1-12 and the date is the current month or later, else null.
  static String? expiryToApi(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 4) return null;
    final mm = int.tryParse(digits.substring(0, 2));
    final yy = int.tryParse(digits.substring(2));
    if (mm == null || yy == null || mm < 1 || mm > 12) return null;

    final fullYear = 2000 + yy;
    final now = DateTime.now();
    final endOfMonth = DateTime(fullYear, mm + 1, 0);
    if (endOfMonth.isBefore(DateTime(now.year, now.month, 1))) return null;

    return '$fullYear-${mm.toString().padLeft(2, '0')}';
  }

  /// Returns the code if 3 or 4 digits, else null.
  static String? cvv(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 3 || digits.length > 4) return null;
    return digits;
  }

  /// Returns the trimmed name if non-empty, else null.
  static String? holderName(String input) {
    final trimmed = input.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
