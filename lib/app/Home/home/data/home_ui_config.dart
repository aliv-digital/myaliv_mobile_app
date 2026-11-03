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
  final LineRole primaryLineRole;
  final bool isViewingChildLine;
  final int? activeDeviceId;

  const HomeUiConfig({
    required this.userType,
    required this.hasActivePlan,
    this.openMyLimits = false,
    required this.isFuturePlan,
    this.isCurrentPlan = false,
    this.lineRole = LineRole.parent,
    LineRole? primaryLineRole,
    this.isViewingChildLine = false,
    this.activeDeviceId,
  }) : primaryLineRole = primaryLineRole ?? lineRole;

  bool get isPrepaid => userType == UserType.prepaid;

  bool get isPostpaid => userType == UserType.postpaid;

  /// True iff the currently active line has read-only restrictions.
  bool get isRestricted => lineRole == LineRole.readOnly;

  HomeUiConfig copyWith({
    UserType? userType,
    bool? hasActivePlan,
    bool? isFuturePlan,
    bool? openMyLimits,
    bool? isCurrentPlan,
    LineRole? lineRole,
    LineRole? primaryLineRole,
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
      primaryLineRole: primaryLineRole ?? this.primaryLineRole,
      isViewingChildLine: isViewingChildLine ?? this.isViewingChildLine,
      activeDeviceId: clearActiveDeviceId
          ? null
          : (activeDeviceId ?? this.activeDeviceId),
    );
  }
}
