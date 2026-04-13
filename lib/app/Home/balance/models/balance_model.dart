/// Data model for user balances
///
/// Represents wallet balance (top-up) and bonus balance (rewards)
/// from the API response.
class BalanceModel {
  final double walletBalance; // Top-up balance
  final double bonusBalance; // Total reward balance
  final List<BonusDetail> bonusDetails; // Individual bonus items
  final DateTime fetchedAt;

  const BalanceModel({
    required this.walletBalance,
    required this.bonusBalance,
    required this.bonusDetails,
    required this.fetchedAt,
  });

  /// Create copy with updated fields
  BalanceModel copyWith({
    double? walletBalance,
    double? bonusBalance,
    List<BonusDetail>? bonusDetails,
    DateTime? fetchedAt,
  }) {
    return BalanceModel(
      walletBalance: walletBalance ?? this.walletBalance,
      bonusBalance: bonusBalance ?? this.bonusBalance,
      bonusDetails: bonusDetails ?? this.bonusDetails,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  String toString() {
    return 'BalanceModel(wallet: \$${walletBalance.toStringAsFixed(2)}, '
        'bonus: \$${bonusBalance.toStringAsFixed(2)}, '
        'bonusItems: ${bonusDetails.length}, '
        'fetchedAt: $fetchedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BalanceModel &&
        other.walletBalance == walletBalance &&
        other.bonusBalance == bonusBalance &&
        _listEquals(other.bonusDetails, bonusDetails) &&
        other.fetchedAt == fetchedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      walletBalance,
      bonusBalance,
      Object.hashAll(bonusDetails),
      fetchedAt,
    );
  }

  /// Helper to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Individual bonus/reward detail
class BonusDetail {
  final int balanceNameId;
  final String balanceAmount;
  final String balanceType;
  final String displayName;
  final String description;
  final int daysToExpiration;
  final bool isActive;

  const BonusDetail({
    required this.balanceNameId,
    required this.balanceAmount,
    required this.balanceType,
    required this.displayName,
    required this.description,
    required this.daysToExpiration,
    required this.isActive,
  });

  /// Parse from JSON
  factory BonusDetail.fromJson(Map<String, dynamic> json) {
    return BonusDetail(
      balanceNameId: json['BalanceNameID'] as int? ?? 0,
      balanceAmount: json['BalanceAmount'] as String? ?? '0',
      balanceType: json['BalanceType'] as String? ?? '',
      displayName: json['BalanceDisplayName'] as String? ?? '',
      description: json['BalanceDescription'] as String? ?? '',
      daysToExpiration: json['DaysToExpiration'] as int? ?? 0,
      isActive: json['IsActive'] as bool? ?? false,
    );
  }

  /// Check if bonus has value
  bool get hasValue {
    final amount = double.tryParse(balanceAmount) ?? 0.0;
    return amount > 0;
  }

  @override
  String toString() {
    return 'BonusDetail(id: $balanceNameId, name: "$displayName", '
        'amount: \$$balanceAmount, expires: ${daysToExpiration}d)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BonusDetail &&
        other.balanceNameId == balanceNameId &&
        other.balanceAmount == balanceAmount &&
        other.balanceType == balanceType &&
        other.displayName == displayName &&
        other.description == description &&
        other.daysToExpiration == daysToExpiration &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return Object.hash(
      balanceNameId,
      balanceAmount,
      balanceType,
      displayName,
      description,
      daysToExpiration,
      isActive,
    );
  }
}
