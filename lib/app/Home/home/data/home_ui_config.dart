enum UserType { prepaid, postpaid }

extension UserTypeExtension on UserType {
  bool get isPrepaid => this == UserType.prepaid;

  bool get isPostpaid => this == UserType.postpaid;

  String get label => isPrepaid ? 'prepaid' : 'postpaid';
}

class HomeUiConfig {
  final UserType userType;
  final bool hasActivePlan;
  final bool isFuturePlan;
  final bool isCurrentPlan;

  /// NEW (optional, UI intent only)
  final bool openMyLimits;

  const HomeUiConfig({
    required this.userType,
    required this.hasActivePlan,
    this.openMyLimits = false,
    required this.isFuturePlan,
    this.isCurrentPlan = false,
  });

  bool get isPrepaid => userType == UserType.prepaid;

  bool get isPostpaid => userType == UserType.postpaid;

  /// Keeps updates explicit and easy to read across the app.
  HomeUiConfig copyWith({
    UserType? userType,
    bool? hasActivePlan,
    bool? isFuturePlan,
    bool? openMyLimits,
    bool? isCurrentPlan,
  }) {
    return HomeUiConfig(
      userType: userType ?? this.userType,
      hasActivePlan: hasActivePlan ?? this.hasActivePlan,
      isFuturePlan: isFuturePlan ?? this.isFuturePlan,
      openMyLimits: openMyLimits ?? this.openMyLimits,
      isCurrentPlan: isCurrentPlan ?? this.isCurrentPlan,
    );
  }
}
