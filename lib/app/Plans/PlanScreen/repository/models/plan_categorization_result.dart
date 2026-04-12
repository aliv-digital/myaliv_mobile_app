import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/daily_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/weekly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/monthly_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roaming_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/roameasy_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/mifi_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/liberty_global_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';

/// Result of categorizing and parsing all plans
class PlanCategorizationResult {
  const PlanCategorizationResult({
    required this.categorizedPlans,
    required this.timestamp,
    this.totalProcessed = 0,
    this.totalUnknown = 0,
  });

  /// Plans grouped by category
  final Map<PlanCategory, List<dynamic>> categorizedPlans;

  /// When this categorization was created
  final DateTime timestamp;

  /// Total plans processed
  final int totalProcessed;

  /// Plans that didn't match any category
  final int totalUnknown;

  /// Get daily plans (typed)
  List<DailyPlanModel> get dailyPlans =>
      (categorizedPlans[PlanCategory.daily] ?? []).cast<DailyPlanModel>();

  /// Get weekly plans (typed)
  List<WeeklyPlanModel> get weeklyPlans =>
      (categorizedPlans[PlanCategory.weekly] ?? []).cast<WeeklyPlanModel>();

  /// Get monthly plans (typed)
  List<MonthlyPlanModel> get monthlyPlans =>
      (categorizedPlans[PlanCategory.monthly] ?? []).cast<MonthlyPlanModel>();

  /// Get roaming plans (typed)
  List<RoamingPlanModel> get roamingPlans =>
      (categorizedPlans[PlanCategory.roaming] ?? []).cast<RoamingPlanModel>();

  /// Get RoamEasy plans (typed)
  List<RoamEasyPlanModel> get roamEasyPlans =>
      (categorizedPlans[PlanCategory.roameasy] ?? [])
          .cast<RoamEasyPlanModel>();

  /// Get MiFi plans (typed)
  List<MifiPlanModel> get mifiPlans =>
      (categorizedPlans[PlanCategory.mifi] ?? []).cast<MifiPlanModel>();

  /// Get Liberty Global plans (typed)
  List<LibertyGlobalPlanModel> get libertyGlobalPlans =>
      (categorizedPlans[PlanCategory.libertyGlobal] ?? [])
          .cast<LibertyGlobalPlanModel>();

  /// Get Postpaid Roaming plans (typed)
  List<HomePlansPostPaidPlanModel> get postpaidRoamingPlans =>
      (categorizedPlans[PlanCategory.postpaidRoaming] ?? [])
          .cast<HomePlansPostPaidPlanModel>();

  /// Get plans for any category
  List<T> getPlansForCategory<T>(PlanCategory category) {
    return (categorizedPlans[category] ?? []).cast<T>();
  }

  /// Get count for a category
  int getCategoryCount(PlanCategory category) {
    return categorizedPlans[category]?.length ?? 0;
  }

  /// Get all category counts
  Map<String, int> getAllCategoryCounts() {
    return {
      for (final category in PlanCategory.values)
        category.name: getCategoryCount(category),
    };
  }

  @override
  String toString() {
    return 'PlanCategorizationResult('
        'processed: $totalProcessed, '
        'unknown: $totalUnknown, '
        'counts: ${getAllCategoryCounts()})';
  }
}
