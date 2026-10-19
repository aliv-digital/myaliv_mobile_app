/// Plan tabs available in the UI
enum HomePlanTab {
  daily,
  weekly,
  monthly,
  roaming,
  roameasy,
  addOns,
  mifi,
  libertyGlobal,
  postpaidRoaming, // For postpaid users - roaming data add-ons
}

/// Helper extension for plan tab types
extension HomePlanTabExtension on HomePlanTab {
  /// Returns true if this tab is only for prepaid users
  bool get isPrepaidOnly {
    return this != HomePlanTab.postpaidRoaming;
  }

  /// Returns true if this tab is only for postpaid users
  bool get isPostpaidOnly {
    return this == HomePlanTab.postpaidRoaming;
  }

  /// Returns user-friendly display name
  String get displayName {
    switch (this) {
      case HomePlanTab.daily:
        return 'Daily';
      case HomePlanTab.weekly:
        return 'Weekly';
      case HomePlanTab.monthly:
        return 'Monthly';
      case HomePlanTab.roaming:
        return 'Roaming';
      case HomePlanTab.roameasy:
        return 'RoamEasy';
      case HomePlanTab.addOns:
        return 'Add-Ons';
      case HomePlanTab.mifi:
        return 'MiFi';
      case HomePlanTab.libertyGlobal:
        return 'Liberty Global';
      case HomePlanTab.postpaidRoaming:
        return 'Roaming Data';
    }
  }
}
