/// Billing frequency for plans
enum PlanFrequency {
  /// Daily plan (D)
  daily('D'),

  /// Weekly plan (W)
  weekly('W'),

  /// Monthly plan (M)
  monthly('M');

  const PlanFrequency(this.value);

  /// API value for this frequency
  final String value;

  /// Parse frequency from API string value
  static PlanFrequency? parse(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toUpperCase();
    for (final freq in PlanFrequency.values) {
      if (freq.value == normalized) return freq;
    }
    return null;
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case PlanFrequency.daily:
        return 'Daily';
      case PlanFrequency.weekly:
        return 'Weekly';
      case PlanFrequency.monthly:
        return 'Monthly';
    }
  }

  @override
  String toString() => value;
}
