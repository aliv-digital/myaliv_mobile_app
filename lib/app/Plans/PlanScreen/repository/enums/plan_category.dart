import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';

/// Category for grouping plans (maps to tabs)
enum PlanCategory {
  /// Daily plans
  daily,

  /// Weekly plans
  weekly,

  /// Monthly plans
  monthly,

  /// Roaming plans (prepaid)
  roaming,

  /// RoamEasy plans
  roameasy,

  /// MiFi plans
  mifi,

  /// Liberty Global plans
  libertyGlobal,

  /// Postpaid roaming plans
  postpaidRoaming,

  /// Unknown/uncategorized plans
  unknown;

  /// Get category from HomePlanTab
  static PlanCategory fromTab(HomePlanTab tab) {
    switch (tab) {
      case HomePlanTab.daily:
        return PlanCategory.daily;
      case HomePlanTab.weekly:
        return PlanCategory.weekly;
      case HomePlanTab.monthly:
        return PlanCategory.monthly;
      case HomePlanTab.roaming:
        return PlanCategory.roaming;
      case HomePlanTab.roameasy:
        return PlanCategory.roameasy;
      case HomePlanTab.mifi:
        return PlanCategory.mifi;
      case HomePlanTab.libertyGlobal:
        return PlanCategory.libertyGlobal;
      case HomePlanTab.postpaidRoaming:
        return PlanCategory.postpaidRoaming;
      case HomePlanTab.addOns:
        throw ArgumentError('Add-ons use different mechanism');
    }
  }

  /// Get HomePlanTab from category
  HomePlanTab? toTab() {
    switch (this) {
      case PlanCategory.daily:
        return HomePlanTab.daily;
      case PlanCategory.weekly:
        return HomePlanTab.weekly;
      case PlanCategory.monthly:
        return HomePlanTab.monthly;
      case PlanCategory.roaming:
        return HomePlanTab.roaming;
      case PlanCategory.roameasy:
        return HomePlanTab.roameasy;
      case PlanCategory.mifi:
        return HomePlanTab.mifi;
      case PlanCategory.libertyGlobal:
        return HomePlanTab.libertyGlobal;
      case PlanCategory.postpaidRoaming:
        return HomePlanTab.postpaidRoaming;
      case PlanCategory.unknown:
        return null;
    }
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case PlanCategory.daily:
        return 'Daily';
      case PlanCategory.weekly:
        return 'Weekly';
      case PlanCategory.monthly:
        return 'Monthly';
      case PlanCategory.roaming:
        return 'Roaming';
      case PlanCategory.roameasy:
        return 'RoamEasy';
      case PlanCategory.mifi:
        return 'MiFi';
      case PlanCategory.libertyGlobal:
        return 'Liberty Global';
      case PlanCategory.postpaidRoaming:
        return 'Postpaid Roaming';
      case PlanCategory.unknown:
        return 'Unknown';
    }
  }
}
