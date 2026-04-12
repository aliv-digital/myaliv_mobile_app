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
