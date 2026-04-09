import 'package:myaliv_mobile_app/app/Plans/shared/repository/services/base_plan_cache.dart';
import '../../models/daily_plan_model.dart';
import '../../models/weekly_plan_model.dart';
import '../../models/monthly_plan_model.dart';
import '../../models/roaming_plan_model.dart';
import '../../models/roameasy_plan_model.dart';
import '../../models/mifi_plan_model.dart';
import '../../models/liberty_global_plan_model.dart';
import '../../models/add_ons_primary_plan_model.dart';
import '../../../PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';

/// Manages in-memory cache for prepaid plan data.
///
/// Extends BasePlanCache to inherit raw plans caching.
/// Adds caching for typed plan models (Daily, Weekly, Monthly, etc.)
class PlanCache extends BasePlanCache {

  // Typed plans cache using CacheEntry
  final CacheEntry<List<DailyPlanModel>> _dailyPlansCache = CacheEntry();
  final CacheEntry<List<WeeklyPlanModel>> _weeklyPlansCache = CacheEntry();
  final CacheEntry<List<MonthlyPlanModel>> _monthlyPlansCache = CacheEntry();
  final CacheEntry<List<RoamingPlanModel>> _roamingPlansCache = CacheEntry();
  final CacheEntry<List<RoamEasyPlanModel>> _roamEasyPlansCache = CacheEntry();
  final CacheEntry<List<MifiPlanModel>> _mifiPlansCache = CacheEntry();
  final CacheEntry<List<LibertyGlobalPlanModel>> _libertyGlobalPlansCache = CacheEntry();
  final CacheEntry<List<HomePlansPostPaidPlanModel>> _postpaidRoamingPlansCache = CacheEntry();
  final CacheEntry<Map<String, dynamic>> _bundlesResponseCache = CacheEntry();
  final CacheEntry<List<AddOnsPrimaryPlanModel>> _addOnsPrimaryPlansCache = CacheEntry();

  // ========== Daily Plans ==========

  void setDailyPlans(List<DailyPlanModel> plans) => _dailyPlansCache.set(plans);

  List<DailyPlanModel> getDailyPlans() => _dailyPlansCache.get() ?? [];

  DateTime? getDailyPlansTimestamp() => _dailyPlansCache.getTimestamp();

  // ========== Weekly Plans ==========

  void setWeeklyPlans(List<WeeklyPlanModel> plans) => _weeklyPlansCache.set(plans);

  List<WeeklyPlanModel> getWeeklyPlans() => _weeklyPlansCache.get() ?? [];

  DateTime? getWeeklyPlansTimestamp() => _weeklyPlansCache.getTimestamp();

  // ========== Monthly Plans ==========

  void setMonthlyPlans(List<MonthlyPlanModel> plans) => _monthlyPlansCache.set(plans);

  List<MonthlyPlanModel> getMonthlyPlans() => _monthlyPlansCache.get() ?? [];

  DateTime? getMonthlyPlansTimestamp() => _monthlyPlansCache.getTimestamp();

  // ========== Roaming Plans ==========

  void setRoamingPlans(List<RoamingPlanModel> plans) => _roamingPlansCache.set(plans);

  List<RoamingPlanModel> getRoamingPlans() => _roamingPlansCache.get() ?? [];

  DateTime? getRoamingPlansTimestamp() => _roamingPlansCache.getTimestamp();

  // ========== RoamEasy Plans ==========

  void setRoamEasyPlans(List<RoamEasyPlanModel> plans) => _roamEasyPlansCache.set(plans);

  List<RoamEasyPlanModel> getRoamEasyPlans() => _roamEasyPlansCache.get() ?? [];

  DateTime? getRoamEasyPlansTimestamp() => _roamEasyPlansCache.getTimestamp();

  // ========== MiFi Plans ==========

  void setMifiPlans(List<MifiPlanModel> plans) => _mifiPlansCache.set(plans);

  List<MifiPlanModel> getMifiPlans() => _mifiPlansCache.get() ?? [];

  DateTime? getMifiPlansTimestamp() => _mifiPlansCache.getTimestamp();

  // ========== Liberty Global Plans ==========

  void setLibertyGlobalPlans(List<LibertyGlobalPlanModel> plans) =>
      _libertyGlobalPlansCache.set(plans);

  List<LibertyGlobalPlanModel> getLibertyGlobalPlans() =>
      _libertyGlobalPlansCache.get() ?? [];

  DateTime? getLibertyGlobalPlansTimestamp() =>
      _libertyGlobalPlansCache.getTimestamp();

  // ========== Postpaid Roaming Plans ==========

  void setPostpaidRoamingPlans(List<HomePlansPostPaidPlanModel> plans) =>
      _postpaidRoamingPlansCache.set(plans);

  List<HomePlansPostPaidPlanModel> getPostpaidRoamingPlans() =>
      _postpaidRoamingPlansCache.get() ?? [];

  DateTime? getPostpaidRoamingPlansTimestamp() =>
      _postpaidRoamingPlansCache.getTimestamp();

  // ========== Bundles Response ==========

  void setBundlesResponse(Map<String, dynamic> response) =>
      _bundlesResponseCache.set(response);

  Map<String, dynamic> getBundlesResponse() =>
      _bundlesResponseCache.get() ?? {};

  DateTime? getBundlesResponseTimestamp() =>
      _bundlesResponseCache.getTimestamp();

  bool hasBundlesResponse() => _bundlesResponseCache.hasData();

  // ========== Add-ons Primary Plans ==========

  void setAddOnsPrimaryPlans(List<AddOnsPrimaryPlanModel> plans) =>
      _addOnsPrimaryPlansCache.set(plans);

  List<AddOnsPrimaryPlanModel> getAddOnsPrimaryPlans() =>
      _addOnsPrimaryPlansCache.get() ?? [];

  DateTime? getAddOnsPrimaryPlansTimestamp() =>
      _addOnsPrimaryPlansCache.getTimestamp();

  bool hasAddOnsPrimaryPlans() => _addOnsPrimaryPlansCache.hasData();

  // ========== Cache Management ==========

  /// Clear all cached data
  @override
  void clearAll() {
    super.clearAll(); // Clear raw plans cache from base class

    _dailyPlansCache.clear();
    _weeklyPlansCache.clear();
    _monthlyPlansCache.clear();
    _roamingPlansCache.clear();
    _roamEasyPlansCache.clear();
    _mifiPlansCache.clear();
    _libertyGlobalPlansCache.clear();
    _postpaidRoamingPlansCache.clear();
    _bundlesResponseCache.clear();
    _addOnsPrimaryPlansCache.clear();
  }
}
