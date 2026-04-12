import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';

/// Factory for creating typed plan models from raw maps
///
/// Now uses unified BasePlanModel for all prepaid plan types
/// (Daily, Weekly, Monthly, Roaming, RoamEasy, MiFi, Liberty Global)
class PlanModelFactory {
  /// Create a typed model based on plan category
  dynamic createModel({
    required Map<String, dynamic> rawPlan,
    required PlanCategory category,
    bool includeRawPayload = false,
  }) {
    // All prepaid plan types now use the same BasePlanModel
    switch (category) {
      case PlanCategory.daily:
      case PlanCategory.weekly:
      case PlanCategory.monthly:
      case PlanCategory.roaming:
      case PlanCategory.roameasy:
      case PlanCategory.mifi:
      case PlanCategory.libertyGlobal:
        return _createBasePlan(rawPlan, includeRawPayload);

      case PlanCategory.postpaidRoaming:
        return _createPostpaidRoamingPlan(rawPlan, includeRawPayload);

      case PlanCategory.unknown:
        return null; // Don't parse unknown plans
    }
  }

  /// Create base plan model (used for all prepaid plan types)
  ///
  /// Replaces 7 separate methods:
  /// - _createDailyPlan
  /// - _createWeeklyPlan
  /// - _createMonthlyPlan
  /// - _createRoamingPlan
  /// - _createRoamEasyPlan
  /// - _createMifiPlan
  /// - _createLibertyGlobalPlan
  BasePlanModel _createBasePlan(
    Map<String, dynamic> raw,
    bool includePayload,
  ) {
    try {
      return BasePlanModel.fromApiMap(raw, includeRawPayload: includePayload);
    } catch (e) {
      throw FormatException('Failed to parse plan: $e');
    }
  }

  /// Create Postpaid Roaming plan model (different structure from prepaid)
  HomePlansPostPaidPlanModel _createPostpaidRoamingPlan(
    Map<String, dynamic> raw,
    bool includePayload,
  ) {
    try {
      return HomePlansPostPaidPlanModel.fromApiMap(
        raw,
        includeRawPayload: includePayload,
      );
    } catch (e) {
      throw FormatException('Failed to parse Postpaid Roaming plan: $e');
    }
  }
}
