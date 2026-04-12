import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';

/// Result of categorizing and parsing all plans
///
/// Now uses unified BasePlanModel for all prepaid plan types
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
  List<BasePlanModel> get dailyPlans =>
      (categorizedPlans[PlanCategory.daily] ?? []).cast<BasePlanModel>();

  /// Get weekly plans (typed)
  List<BasePlanModel> get weeklyPlans =>
      (categorizedPlans[PlanCategory.weekly] ?? []).cast<BasePlanModel>();

  /// Get monthly plans (typed)
  List<BasePlanModel> get monthlyPlans =>
      (categorizedPlans[PlanCategory.monthly] ?? []).cast<BasePlanModel>();

  /// Get roaming plans (typed)
  List<BasePlanModel> get roamingPlans =>
      (categorizedPlans[PlanCategory.roaming] ?? []).cast<BasePlanModel>();

  /// Get RoamEasy plans (typed)
  List<BasePlanModel> get roamEasyPlans =>
      (categorizedPlans[PlanCategory.roameasy] ?? [])
          .cast<BasePlanModel>();

  /// Get MiFi plans (typed)
  List<BasePlanModel> get mifiPlans =>
      (categorizedPlans[PlanCategory.mifi] ?? []).cast<BasePlanModel>();

  /// Get Liberty Global plans (typed)
  List<BasePlanModel> get libertyGlobalPlans =>
      (categorizedPlans[PlanCategory.libertyGlobal] ?? [])
          .cast<BasePlanModel>();

  /// Get Postpaid Roaming plans (typed - different structure)
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
