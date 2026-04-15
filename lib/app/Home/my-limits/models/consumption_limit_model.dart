/// Data model for consumption limit
///
/// Represents a single consumption limit item from the API response.
/// Maps API field names to more readable Dart properties.
///
/// API Response format:
/// ```json
/// {
///   "Name": "C_SMS_local_Restriction",
///   "InitialAmount": 2254.99,
///   "UsedAmount": 0.0
/// }
/// ```
class ConsumptionLimitModel {
  final String name;
  final double initialAmount;
  final double usedAmount;

  const ConsumptionLimitModel({
    required this.name,
    required this.initialAmount,
    required this.usedAmount,
  });

  /// Parse from JSON
  factory ConsumptionLimitModel.fromJson(Map<String, dynamic> json) {
    return ConsumptionLimitModel(
      name: json['Name'] as String? ?? '',
      initialAmount: (json['InitialAmount'] as num?)?.toDouble() ?? 0.0,
      usedAmount: (json['UsedAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'InitialAmount': initialAmount,
      'UsedAmount': usedAmount,
    };
  }

  /// Calculate remaining amount
  double get remainingAmount => initialAmount - usedAmount;

  /// Calculate percentage used (0-100)
  int get percentUsed {
    if (initialAmount <= 0) return 0;
    final percent = (usedAmount / initialAmount) * 100;
    return percent.clamp(0, 100).round();
  }

  /// Get display name from API name
  ///
  /// Maps API names to user-friendly display names:
  /// - C_SMS_local_Restriction -> local text
  /// - C_GPRS_Local -> local data
  /// - C_Voice_local_restriction -> local talk mins
  /// - C_IR_restriction -> int'l roaming
  /// - C_IDD_Restriction -> int'l talk mins
  String get displayName {
    switch (name) {
      case 'C_SMS_local_Restriction':
        return 'local text';
      case 'C_GPRS_Local':
        return 'local data';
      case 'C_Voice_local_restriction':
        return 'local talk mins';
      case 'C_IR_restriction':
        return "int'l roaming";
      case 'C_IDD_Restriction':
        return "int'l talk mins";
      default:
        // Convert snake_case to readable format
        return name
            .replaceAll('C_', '')
            .replaceAll('_', ' ')
            .toLowerCase();
    }
  }

  /// Get sort order for consistent display
  ///
  /// Returns order: local text, local data, local talk mins, int'l roaming, int'l talk mins
  int get sortOrder {
    switch (name) {
      case 'C_SMS_local_Restriction':
        return 0;
      case 'C_GPRS_Local':
        return 1;
      case 'C_Voice_local_restriction':
        return 2;
      case 'C_IR_restriction':
        return 3;
      case 'C_IDD_Restriction':
        return 4;
      default:
        return 99;
    }
  }

  @override
  String toString() {
    return 'ConsumptionLimitModel(name: $name, '
        'initial: \$${initialAmount.toStringAsFixed(2)}, '
        'used: \$${usedAmount.toStringAsFixed(2)}, '
        'remaining: \$${remainingAmount.toStringAsFixed(2)}, '
        'percentUsed: $percentUsed%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConsumptionLimitModel &&
        other.name == name &&
        other.initialAmount == initialAmount &&
        other.usedAmount == usedAmount;
  }

  @override
  int get hashCode {
    return Object.hash(name, initialAmount, usedAmount);
  }
}
