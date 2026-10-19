/// Model for Limited Time Offer (Ads Timer)
///
/// Represents a promotional offer with expiration timer.
/// Maps to API response from /v1/ads-timer/active endpoint.
class LimitedOfferModel {
  final int id;
  final String title;
  final String subHeading;
  final String? link;
  final String type; // 'prepaid' | 'postpaid'
  final DateTime addedOn;
  final DateTime expireOn;
  final String status; // 'active' | 'inactive'
  final String? backgroundImageUrl;

  const LimitedOfferModel({
    required this.id,
    required this.title,
    required this.subHeading,
    this.link,
    required this.type,
    required this.addedOn,
    required this.expireOn,
    required this.status,
    this.backgroundImageUrl,
  });

  /// Parse from API JSON response
  factory LimitedOfferModel.fromJson(Map<String, dynamic> json) {
    return LimitedOfferModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Limited Offer',
      subHeading: json['subHeading'] as String? ?? '',
      link: json['link'] as String?,
      type: json['type'] as String? ?? 'prepaid',
      addedOn: DateTime.parse(json['addedOn'] as String),
      expireOn: DateTime.parse(json['expireOn'] as String),
      status: json['status'] as String? ?? 'inactive',
      backgroundImageUrl: json['backgroundImageUrl'] as String?,
    );
  }

  /// Create a copy with updated fields
  LimitedOfferModel copyWith({
    int? id,
    String? title,
    String? subHeading,
    String? link,
    String? type,
    DateTime? addedOn,
    DateTime? expireOn,
    String? status,
    String? backgroundImageUrl,
  }) {
    return LimitedOfferModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subHeading: subHeading ?? this.subHeading,
      link: link ?? this.link,
      type: type ?? this.type,
      addedOn: addedOn ?? this.addedOn,
      expireOn: expireOn ?? this.expireOn,
      status: status ?? this.status,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
    );
  }

  /// Calculate time remaining until expiration
  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(expireOn)) {
      return Duration.zero;
    }
    return expireOn.difference(now);
  }

  /// Check if offer has expired (date-only, so offer is valid for the entire expiry day)
  bool get isExpired {
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final expireDate = DateTime(expireOn.year, expireOn.month, expireOn.day);
    return todayDate.isAfter(expireDate);
  }

  /// Check if offer is currently active
  bool get isActive => status == 'active' && !isExpired;

  /// Check if offer is for prepaid users
  bool get isPrepaid => type.toLowerCase() == 'prepaid';

  /// Check if offer is for postpaid users
  bool get isPostpaid => type.toLowerCase() == 'postpaid';

  @override
  String toString() {
    return 'LimitedOfferModel(id: $id, title: $title, type: $type, '
        'status: $status, expireOn: $expireOn, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LimitedOfferModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
