String formatConfirmationCurrency(double value) {
  return '\$ ${value.toStringAsFixed(2)}';
}

String formatConfirmationPhone(String phone) {
  if (phone.isEmpty) return '';
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 10) {
    return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
  }
  if (digits.length == 11 && digits.startsWith('1')) {
    return '${digits.substring(1, 4)}-${digits.substring(4, 7)}-${digits.substring(7)}';
  }
  return phone;
}

String nameFromEmail(String? email) {
  final normalized = email?.trim() ?? '';
  if (normalized.isEmpty || !normalized.contains('@')) {
    return 'User';
  }
  return normalized.split('@').first;
}
