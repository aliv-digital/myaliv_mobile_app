enum UserType { prepaid, postpaid }

extension UserTypeExtension on UserType {
  bool get isPrepaid => this == UserType.prepaid;

  bool get isPostpaid => this == UserType.postpaid;

  String get label => isPrepaid ? 'prepaid' : 'postpaid';
}

enum LineRole { parent, fullAccess, readOnly }

class HomeUiConfig {
  final UserType userType;
  final bool hasActivePlan;
  final bool isFuturePlan;
  final bool isCurrentPlan;
  final bool openMyLimits;
  final LineRole lineRole;
  final bool isViewingChildLine;
  final int? activeDeviceId;

  const HomeUiConfig({
    required this.userType,
    required this.hasActivePlan,
    this.openMyLimits = false,
    required this.isFuturePlan,
    this.isCurrentPlan = false,
    this.lineRole = LineRole.parent,
    this.isViewingChildLine = false,
    this.activeDeviceId,
  });

  bool get isPrepaid => userType == UserType.prepaid;

  bool get isPostpaid => userType == UserType.postpaid;

  /// True only for a read-only child logged in directly.
  /// Parent on own line, parent on child's line, and full-access child are all false.
  bool get isRestricted => lineRole == LineRole.readOnly && !isViewingChildLine;

  HomeUiConfig copyWith({
    UserType? userType,
    bool? hasActivePlan,
    bool? isFuturePlan,
    bool? openMyLimits,
    bool? isCurrentPlan,
    LineRole? lineRole,
    bool? isViewingChildLine,
    int? activeDeviceId,
    bool clearActiveDeviceId = false,
  }) {
    return HomeUiConfig(
      userType: userType ?? this.userType,
      hasActivePlan: hasActivePlan ?? this.hasActivePlan,
      isFuturePlan: isFuturePlan ?? this.isFuturePlan,
      openMyLimits: openMyLimits ?? this.openMyLimits,
      isCurrentPlan: isCurrentPlan ?? this.isCurrentPlan,
      lineRole: lineRole ?? this.lineRole,
      isViewingChildLine: isViewingChildLine ?? this.isViewingChildLine,
      activeDeviceId: clearActiveDeviceId
          ? null
          : (activeDeviceId ?? this.activeDeviceId),
    );
  }
}
