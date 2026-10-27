/// Canonical Bahamas phone number formatter: `(XXX)-XXX-XXXX`.
///
/// Shared between the login input formatter (as-you-type) and display surfaces
/// like "my profile" so every rendered Bahamas phone looks the same.
class BahamasPhoneFormatter {
  const BahamasPhoneFormatter._();

  /// Formats a stream of already-digits-only input, producing partial output
  /// as the user types: `242` → `(242)`, `2423` → `(242)-3`,
  /// `2423454356` → `(242)-345-4356`. Callers are responsible for capping
  /// length to 10 digits.
  static String formatDigits(String digits) {
    if (digits.isEmpty) return '';
    if (digits.length < 3) return '($digits';
    if (digits.length == 3) return '($digits)';
    if (digits.length <= 6) {
      return '(${digits.substring(0, 3)})-${digits.substring(3)}';
    }
    return '(${digits.substring(0, 3)})-'
        '${digits.substring(3, 6)}-${digits.substring(6)}';
  }

  /// Formats a raw phone string (may contain country code, dashes, parens,
  /// spaces). Returns `(XXX)-XXX-XXXX` when the input resolves to exactly 10
  /// digits (or 11 digits with a leading `1`). Returns the original input
  /// unchanged when it does not match either case, so callers can fall back
  /// gracefully for unexpected formats.
  static String format(String raw) {
    if (raw.isEmpty) return '';
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11 && digits.startsWith('1')) {
      digits = digits.substring(1);
    }
    if (digits.length != 10) return raw;
    return formatDigits(digits);
  }
}
