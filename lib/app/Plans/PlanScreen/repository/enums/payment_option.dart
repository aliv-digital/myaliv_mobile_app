/// Payment option for plans
enum PaymentOption {
  /// Prepaid/Prepay
  prepay('prepay'),

  /// Postpaid/Postpay
  postpay('postpay');

  const PaymentOption(this.value);

  /// API value for this payment option
  final String value;

  /// Parse payment option from API string value
  static PaymentOption? parse(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return null;

    // Accept common API variants: "PostPay", "PostPaid", "post-pay", etc.
    final alphaOnly = normalized.replaceAll(RegExp(r'[^a-z]'), '');
    if (alphaOnly.startsWith('post')) return PaymentOption.postpay;
    if (alphaOnly.startsWith('pre')) return PaymentOption.prepay;

    for (final option in PaymentOption.values) {
      if (option.value == normalized) return option;
    }
    return null;
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case PaymentOption.prepay:
        return 'Prepaid';
      case PaymentOption.postpay:
        return 'Postpaid';
    }
  }

  @override
  String toString() => value;
}
