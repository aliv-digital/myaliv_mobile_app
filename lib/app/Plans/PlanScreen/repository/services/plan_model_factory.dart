import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/daily_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/weekly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/monthly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roaming_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roameasy_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/mifi_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/liberty_global_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';

/// Factory for creating typed plan models from raw maps
class PlanModelFactory {
  /// Create a typed model based on plan category
  dynamic createModel({
    required Map<String, dynamic> rawPlan,
    required PlanCategory category,
    bool includeRawPayload = false,
  }) {
    switch (category) {
      case PlanCategory.daily:
        return _createDailyPlan(rawPlan, includeRawPayload);

      case PlanCategory.weekly:
        return _createWeeklyPlan(rawPlan, includeRawPayload);

      case PlanCategory.monthly:
        return _createMonthlyPlan(rawPlan, includeRawPayload);

      case PlanCategory.roaming:
        return _createRoamingPlan(rawPlan, includeRawPayload);

      case PlanCategory.roameasy:
        return _createRoamEasyPlan(rawPlan, includeRawPayload);

      case PlanCategory.mifi:
        return _createMifiPlan(rawPlan, includeRawPayload);

      case PlanCategory.libertyGlobal:
        return _createLibertyGlobalPlan(rawPlan, includeRawPayload);

      case PlanCategory.postpaidRoaming:
        return _createPostpaidRoamingPlan(rawPlan, includeRawPayload);

      case PlanCategory.unknown:
        return null; // Don't parse unknown plans
    }
  }

  /// Create daily plan model
  DailyPlanModel _createDailyPlan(
    Map<String, dynamic> raw,
    bool includePayload,
  ) {
    try {
      return DailyPlanModel.fromApiMap(raw, includeRawPayload: includePayload);
    } catch (e) {
      throw FormatException('Failed to parse daily plan: $e');
    }
  }

  /// Create weekly plan model
  WeeklyPlanModel _createWeeklyPlan(
    Map<String, dynamic> raw,
    bool includePayload,
  ) {
    try {
      return WeeklyPlanModel.fromApiMap(raw, includeRawPayload: includePayload);
    } catch (e) {
      throw FormatException('Failed to parse weekly plan: $e');
    }
  }

  /// Create monthly plan model
  MonthlyPlanModel _createMonthlyPlan(
    Map<String, dynamic> raw,
    bool includePayload,
  ) {
    try {
      return MonthlyPlanModel.fromApiMap(raw, includeRawPayload: includePayload);
    } catch (e) {
      throw FormatException('Failed to parse monthly plan: $e');
    }
  }

  /// Create roaming plan model
  RoamingPlanModel _createRoamingPlan(
    Map<String, dynamic> raw,
    bool includePayload,
  ) {
    try {
      return RoamingPlanModel.fromApiMap(raw, includeRawPayload: includePayload);
    } catch (e) {
      throw FormatException('Failed to parse roaming plan: $e');
    }
  }

  /// Create RoamEasy plan model
  RoamEasyPlanModel _createRoamEasyPlan(
    Map<String, dynamic> raw,
    bool includePayload,
  ) {
    try {
      return RoamEasyPlanModel.fromApiMap(raw, includeRawPayload: includePayload);
    } catch (e) {
      throw FormatException('Failed to parse RoamEasy plan: $e');
    }
  }

  /// Create MiFi plan model
  MifiPlanModel _createMifiPlan(
    Map<String, dynamic> raw,
    bool includePayload,
  ) {
    try {
      return MifiPlanModel.fromApiMap(raw, includeRawPayload: includePayload);
    } catch (e) {
      throw FormatException('Failed to parse MiFi plan: $e');
    }
  }

  /// Create Liberty Global plan model
  LibertyGlobalPlanModel _createLibertyGlobalPlan(
    Map<String, dynamic> raw,
    bool includePayload,
  ) {
    try {
      return LibertyGlobalPlanModel.fromApiMap(
        raw,
        includeRawPayload: includePayload,
      );
    } catch (e) {
      throw FormatException('Failed to parse Liberty Global plan: $e');
    }
  }

  /// Create Postpaid Roaming plan model
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
