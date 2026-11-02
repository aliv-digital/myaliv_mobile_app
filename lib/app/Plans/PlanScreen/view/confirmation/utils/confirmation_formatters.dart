import 'package:myaliv_mobile_app/core/utils/appUtils.dart';

String formatConfirmationCurrency(double value) {
  return AppUtils.formatPrice(value);
}

String formatConfirmationPhone(String phone) {
  if (phone.isEmpty) return '';
  var cleaned = phone.contains('_') ? phone.split('_').first : phone;
  cleaned = cleaned.replaceAll('*dc*', '').replaceAll('*DC*', '').trim();
  final digits = cleaned.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 10) {
    return '(${digits.substring(0, 3)})-${digits.substring(3, 6)}-${digits.substring(6)}';
  }
  if (digits.length == 11 && digits.startsWith('1')) {
    return '(${digits.substring(1, 4)})-${digits.substring(4, 7)}-${digits.substring(7)}';
  }
  return cleaned;
}

String nameFromEmail(String? email) {
  final normalized = email?.trim() ?? '';
  if (normalized.isEmpty || !normalized.contains('@')) {
    return 'User';
  }
  return normalized.split('@').first;
}
