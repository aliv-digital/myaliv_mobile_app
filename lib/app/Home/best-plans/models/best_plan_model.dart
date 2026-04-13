/// Data model for Best Plan
///
/// Represents a single plan from the API response.
/// Contains plan details, pricing, validity, and computed properties for status checks.
class BestPlanModel {
  final int id;
  final String price;
  final String planName;
  final String subHeading;
  final String? link;
  final DateTime startFrom;
  final DateTime expireOn;
  final String? backgroundImageUrl;
  final String type; // 'prepaid' | 'postpaid'
  final String status; // 'active' | 'inactive'

  const BestPlanModel({
    required this.id,
    required this.price,
    required this.planName,
    required this.subHeading,
    this.link,
    required this.startFrom,
    required this.expireOn,
    this.backgroundImageUrl,
    required this.type,
    required this.status,
  });

  /// Parse from JSON
  ///
  /// Expected JSON structure from API:
  /// ```json
  /// {
  ///   "id": 12,
  ///   "price": "45.00",
  ///   "planName": "Test 1001",
  ///   "subHeading": "7 days plan",
  ///   "link": "https://www.google.com",
  ///   "startFrom": "2026-04-06T00:00:00.000Z",
  ///   "expireOn": "2026-04-06T00:00:00.000Z",
  ///   "backgroundImageUrl": "https://...",
  ///   "type": "postpaid",
  ///   "status": "active"
  /// }
  /// ```
  factory BestPlanModel.fromJson(Map<String, dynamic> json) {
    return BestPlanModel(
      id: json['id'] as int,
      price: json['price'] as String? ?? '0.00',
      planName: json['planName'] as String? ?? '',
      subHeading: json['subHeading'] as String? ?? '',
      link: json['link'] as String?,
      startFrom: DateTime.parse(json['startFrom'] as String),
      expireOn: DateTime.parse(json['expireOn'] as String),
      backgroundImageUrl: json['backgroundImageUrl'] as String?,
      type: json['type'] as String? ?? 'prepaid',
      status: json['status'] as String? ?? 'inactive',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'price': price,
      'planName': planName,
      'subHeading': subHeading,
      'link': link,
      'startFrom': startFrom.toIso8601String(),
      'expireOn': expireOn.toIso8601String(),
      'backgroundImageUrl': backgroundImageUrl,
      'type': type,
      'status': status,
    };
  }

  // ========== Computed Properties ==========

  /// Check if plan is expired (expireOn date has passed)
  bool get isExpired => DateTime.now().isAfter(expireOn);

  /// Check if plan is active (status is 'active' and not expired)
  bool get isActive => status.toLowerCase() == 'active' && !isExpired;

  /// Check if plan has started (startFrom date has passed)
  bool get isStarted => DateTime.now().isAfter(startFrom);

  /// Check if plan is valid (active, started, and not expired)
  bool get isValid => isActive && isStarted;

  /// Create a copy with updated fields (used for debug mode extension)
  BestPlanModel copyWith({
    int? id,
    String? price,
    String? planName,
    String? subHeading,
    String? link,
    DateTime? startFrom,
    DateTime? expireOn,
    String? backgroundImageUrl,
    String? type,
    String? status,
  }) {
    return BestPlanModel(
      id: id ?? this.id,
      price: price ?? this.price,
      planName: planName ?? this.planName,
      subHeading: subHeading ?? this.subHeading,
      link: link ?? this.link,
      startFrom: startFrom ?? this.startFrom,
      expireOn: expireOn ?? this.expireOn,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'BestPlanModel(id: $id, planName: "$planName", price: $price, '
        'type: $type, status: $status, isActive: $isActive, isExpired: $isExpired)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BestPlanModel &&
        other.id == id &&
        other.price == price &&
        other.planName == planName &&
        other.subHeading == subHeading &&
        other.link == link &&
        other.startFrom == startFrom &&
        other.expireOn == expireOn &&
        other.backgroundImageUrl == backgroundImageUrl &&
        other.type == type &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      price,
      planName,
      subHeading,
      link,
      startFrom,
      expireOn,
      backgroundImageUrl,
      type,
      status,
    );
  }
}
