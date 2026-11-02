class PhoneNumberFormatterService {
  const PhoneNumberFormatterService._();

  static String format(String phoneNumber) {
    final trimmed = phoneNumber.trim();
    var cleaned = trimmed.contains('_') ? trimmed.split('_').first : trimmed;
    cleaned = cleaned.replaceAll('*dc*', '').replaceAll('*DC*', '').trim();
    final digits = cleaned.replaceAll(RegExp(r'\D'), '');

    if (digits.length == 10) {
      return '(${digits.substring(0, 3)})-'
          '${digits.substring(3, 6)}-'
          '${digits.substring(6)}';
    }

    if (digits.length == 11 && digits.startsWith('1')) {
      return '(${digits.substring(1, 4)})-'
          '${digits.substring(4, 7)}-'
          '${digits.substring(7)}';
    }

    return cleaned;
  }
}
