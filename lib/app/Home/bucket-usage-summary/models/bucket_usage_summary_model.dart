/// Root model for the bucket usage summary API response.
///
/// The API returns a list at the root, so this wrapper keeps the full list
/// together with the fetch time for debugging and cache decisions.
class BucketUsageSummaryModel {
  final List<BucketUsageItem> items;
  final DateTime fetchedAt;

  const BucketUsageSummaryModel({required this.items, required this.fetchedAt});

  bool get hasItems => items.isNotEmpty;

  int get itemCount => items.length;

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'fetchedAt': fetchedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'BucketUsageSummaryModel(items: ${items.length}, fetchedAt: $fetchedAt)';
  }
}

/// One bucket from the usage summary response.
class BucketUsageItem {
  final String freeUnitTypeName;
  final double totalInitialAmount;
  final double totalUnusedAmount;
  final double totalAmountUsed;
  final List<BucketUsageDetail> nestedDetails;
  final String unitType;
  final String sortOrder;

  const BucketUsageItem({
    required this.freeUnitTypeName,
    required this.totalInitialAmount,
    required this.totalUnusedAmount,
    required this.totalAmountUsed,
    required this.nestedDetails,
    required this.unitType,
    required this.sortOrder,
  });

  factory BucketUsageItem.fromJson(Map<String, dynamic> json) {
    final details = <BucketUsageDetail>[];
    final rawDetails = json['NestedDetail'];

    if (rawDetails is List) {
      for (final rawDetail in rawDetails) {
        if (rawDetail is Map) {
          details.add(
            BucketUsageDetail.fromJson(Map<String, dynamic>.from(rawDetail)),
          );
        }
      }
    }

    return BucketUsageItem(
      freeUnitTypeName: _asString(json['FreeUnitTypeName']),
      totalInitialAmount: _asDouble(json['TotalInitialAmount']),
      totalUnusedAmount: _asDouble(json['TotalUnusedAmount']),
      totalAmountUsed: _asDouble(json['TotalAmountUsed']),
      nestedDetails: details,
      unitType: _asString(json['UnitType']),
      sortOrder: _asString(json['SortOrder']),
    );
  }

  bool get hasUsage => totalAmountUsed > 0;

  double get usagePercent {
    if (totalInitialAmount <= 0) {
      return 0;
    }
    return (totalAmountUsed / totalInitialAmount) * 100;
  }

  double get unusedPercent {
    if (totalInitialAmount <= 0) {
      return 0;
    }
    return (totalUnusedAmount / totalInitialAmount) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'FreeUnitTypeName': freeUnitTypeName,
      'TotalInitialAmount': totalInitialAmount,
      'TotalUnusedAmount': totalUnusedAmount,
      'TotalAmountUsed': totalAmountUsed,
      'NestedDetail': nestedDetails.map((detail) => detail.toJson()).toList(),
      'UnitType': unitType,
      'SortOrder': sortOrder,
    };
  }

  @override
  String toString() {
    return 'BucketUsageItem(name: $freeUnitTypeName, unit: $unitType, '
        'initial: $totalInitialAmount, unused: $totalUnusedAmount, '
        'used: $totalAmountUsed, details: ${nestedDetails.length})';
  }
}

/// A nested usage entry inside a bucket.
class BucketUsageDetail {
  final String expireTime;
  final DateTime? expireDateTime;
  final double currentAmount;
  final String instanceId;
  final String purchaseSeq;
  final String? mtSubscriptionId;

  const BucketUsageDetail({
    required this.expireTime,
    required this.expireDateTime,
    required this.currentAmount,
    required this.instanceId,
    required this.purchaseSeq,
    required this.mtSubscriptionId,
  });

  factory BucketUsageDetail.fromJson(Map<String, dynamic> json) {
    final expireTime = _asString(json['ExpireTime']);

    return BucketUsageDetail(
      expireTime: expireTime,
      expireDateTime: _parseDateTime(expireTime),
      currentAmount: _asDouble(json['CurrentAmount']),
      // Keep this as String because the API sends very large numeric IDs.
      instanceId: _asString(json['InstanceId']),
      purchaseSeq: _asString(json['PurchaseSeq']),
      mtSubscriptionId: _asNullableString(json['MTSubscriptionID']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ExpireTime': expireTime,
      'CurrentAmount': currentAmount,
      'InstanceId': instanceId,
      'PurchaseSeq': purchaseSeq,
      'MTSubscriptionID': mtSubscriptionId,
    };
  }

  @override
  String toString() {
    return 'BucketUsageDetail(expireTime: $expireTime, '
        'currentAmount: $currentAmount, instanceId: $instanceId)';
  }
}

String _asString(dynamic value) {
  return value?.toString() ?? '';
}

String? _asNullableString(dynamic value) {
  if (value == null) {
    return null;
  }
  return value.toString();
}

double _asDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }

  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _parseDateTime(String value) {
  if (value.trim().isEmpty) {
    return null;
  }

  // API value example: "2026-05-29 11:27:28".
  final normalizedValue = value.replaceFirst(' ', 'T');
  return DateTime.tryParse(normalizedValue);
}
