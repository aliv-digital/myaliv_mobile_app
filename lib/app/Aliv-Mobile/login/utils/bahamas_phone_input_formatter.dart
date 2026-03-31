import 'package:flutter/services.dart';

/// Formats Bahamas local numbers as `(242) 345-4356` while the user types.
///
/// This is a presentation-only formatter. The login flow still converts the
/// value back to raw digits before sending it to the backend.
class BahamasPhoneInputFormatter extends TextInputFormatter {
  const BahamasPhoneInputFormatter();

  static const int _maxDigits = 10;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String resolvedDigits = _resolveDigitsForEdit(
      oldValue: oldValue,
      newValue: newValue,
    );
    final String limitedDigits = resolvedDigits.length > _maxDigits
        ? resolvedDigits.substring(0, _maxDigits)
        : resolvedDigits;
    final String formatted = _formatBahamasNumber(limitedDigits);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _resolveDigitsForEdit({
    required TextEditingValue oldValue,
    required TextEditingValue newValue,
  }) {
    final String oldDigits = _digitsOnly(oldValue.text);
    final String newDigits = _digitsOnly(newValue.text);
    final bool isDeleting = newValue.text.length < oldValue.text.length;

    if (!isDeleting ||
        newDigits.length != oldDigits.length ||
        oldDigits.isEmpty) {
      return newDigits;
    }

    // Backspacing over `)` or spaces does not change the raw digit count.
    // In that case, remove the nearest real digit so delete feels natural.
    final int digitsBeforeCursor = _countDigitsBefore(
      newValue.text,
      newValue.selection.extentOffset,
    );
    final int digitIndexToRemove =
        digitsBeforeCursor <= 0 ? 0 : digitsBeforeCursor - 1;

    return _removeDigitAt(oldDigits, digitIndexToRemove);
  }

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  int _countDigitsBefore(String text, int offset) {
    final int safeOffset = offset.clamp(0, text.length);
    return _digitsOnly(text.substring(0, safeOffset)).length;
  }

  String _removeDigitAt(String digits, int index) {
    if (digits.isEmpty) {
      return digits;
    }

    final int safeIndex = index.clamp(0, digits.length - 1);
    return digits.substring(0, safeIndex) + digits.substring(safeIndex + 1);
  }

  String _formatBahamasNumber(String digits) {
    if (digits.isEmpty) {
      return '';
    }

    if (digits.length < 3) {
      return '($digits';
    }

    if (digits.length == 3) {
      return '($digits)';
    }

    if (digits.length <= 6) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3)}';
    }

    return '(${digits.substring(0, 3)}) '
        '${digits.substring(3, 6)}-${digits.substring(6)}';
  }
}
