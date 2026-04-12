/// Plan type from API
enum PlanType {
  /// Primary plan (P)
  primary('P'),

  /// Add-on plan (A)
  addon('A'),

  /// Special/Subscription plan (S)
  /// Used for bonus data, liberty plans, and other special offers
  special('S');

  const PlanType(this.value);

  /// API value for this plan type
  final String value;

  /// Parse plan type from API string value
  static PlanType? parse(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toUpperCase();
    for (final type in PlanType.values) {
      if (type.value == normalized) return type;
    }
    return null;
  }

  @override
  String toString() => value;
}
