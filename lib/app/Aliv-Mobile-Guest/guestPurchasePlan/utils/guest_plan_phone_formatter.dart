class GuestPlanPhoneFormatter {
  const GuestPlanPhoneFormatter._();

  /// Formats a phone number for display in Guest Purchase Plan confirmation
  /// and receipt screens.
  ///
  /// Expected Bahamas format: `(242)-XXX-XXXX`.
  ///
  /// Rules:
  /// - 10-digit Bahamas numbers (e.g. `2428011616`) -> `(242)-801-1616`
  /// - 11-digit Bahamas numbers with NANP prefix (e.g. `12428011616`) -> `(242)-801-1616`
  /// - Already formatted numbers (e.g. `(242)-801-1616`) -> `(242)-801-1616` (idempotent)
  /// - 7-digit local numbers (e.g. `8011616`) -> `(242)-801-1616` ONLY when
  ///   the country context is confirmed to be Bahamas (+1 242) via [isBahamas],
  ///   [countryCode] == 'BS', or [dialCode].
  /// - If Bahamas country context is not confirmed, 7-digit numbers are NOT
  ///   assumed to belong to Bahamas and are returned trimmed without inventing digits.
  /// - Null or empty inputs return an empty string `''`.
  /// - Malformed or unsupported numbers are returned trimmed without inventing digits.
  static String format(
    String? rawPhone, {
    bool isBahamas = false,
    String? countryCode,
    String? dialCode,
  }) {
    if (rawPhone == null) return '';
    final trimmed = rawPhone.trim();
    if (trimmed.isEmpty) return '';

    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');

    final bool isConfirmedBahamas =
        isBahamas ||
        (countryCode != null && countryCode.trim().toUpperCase() == 'BS') ||
        (dialCode != null && _isBahamasDialCode(dialCode));

    // 10 digits starting with 242
    if (digits.length == 10 && digits.startsWith('242')) {
      return '(${digits.substring(0, 3)})-'
          '${digits.substring(3, 6)}-'
          '${digits.substring(6)}';
    }

    // 11 digits starting with 1242
    if (digits.length == 11 && digits.startsWith('1242')) {
      return '(${digits.substring(1, 4)})-'
          '${digits.substring(4, 7)}-'
          '${digits.substring(7)}';
    }

    // 7 digits (only format to (242)-XXX-XXXX if confirmed Bahamas)
    if (digits.length == 7) {
      if (isConfirmedBahamas) {
        return '(242)-${digits.substring(0, 3)}-${digits.substring(3)}';
      }
      return trimmed;
    }

    // Malformed, unsupported, or non-Bahamas number: return trimmed as-is
    return trimmed;
  }

  static bool _isBahamasDialCode(String dialCode) {
    final d = dialCode.replaceAll(RegExp(r'[^0-9]'), '');
    return d == '242' || d == '1242';
  }
}
