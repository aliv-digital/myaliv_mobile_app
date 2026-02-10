enum UserType { prepaid, postpaid }

class HomeUiConfig {
  final UserType userType;
  final bool hasActivePlan;
  final bool isFuturePlan;

  /// NEW (optional, UI intent only)
  final bool openMyLimits;

  const HomeUiConfig({
    required this.userType,
    required this.hasActivePlan,
    this.openMyLimits = false, required this.isFuturePlan,
  });

  bool get isPrepaid => userType == UserType.prepaid;
  bool get isPostpaid => userType == UserType.postpaid;
  bool get isFuture => isFuturePlan;
}
