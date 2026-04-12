import 'package:myaliv_mobile_app/app/Plans/PlanScreen/shared/repository/services/base_plan_cache.dart';
import '../../models/base_plan_model.dart';
import '../../../PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';

/// Manages in-memory cache for prepaid plan data.
///
/// Extends BasePlanCache to inherit raw plans caching.
/// Adds caching for typed plan models using unified BasePlanModel
/// (Daily, Weekly, Monthly, Roaming, RoamEasy, MiFi, Liberty Global)
class PlanCache extends BasePlanCache {

  // Typed plans cache using CacheEntry
  // All prepaid plan types now use BasePlanModel
  final CacheEntry<List<BasePlanModel>> _dailyPlansCache = CacheEntry();
  final CacheEntry<List<BasePlanModel>> _weeklyPlansCache = CacheEntry();
  final CacheEntry<List<BasePlanModel>> _monthlyPlansCache = CacheEntry();
  final CacheEntry<List<BasePlanModel>> _roamingPlansCache = CacheEntry();
  final CacheEntry<List<BasePlanModel>> _roamEasyPlansCache = CacheEntry();
  final CacheEntry<List<BasePlanModel>> _mifiPlansCache = CacheEntry();
  final CacheEntry<List<BasePlanModel>> _libertyGlobalPlansCache = CacheEntry();
  final CacheEntry<List<HomePlansPostPaidPlanModel>> _postpaidRoamingPlansCache = CacheEntry();
  final CacheEntry<Map<String, dynamic>> _bundlesResponseCache = CacheEntry();
  final CacheEntry<List<BasePlanModel>> _addOnsPrimaryPlansCache = CacheEntry();

  // ========== Daily Plans ==========

  void setDailyPlans(List<BasePlanModel> plans) => _dailyPlansCache.set(plans);

  List<BasePlanModel> getDailyPlans() => _dailyPlansCache.get() ?? [];

  DateTime? getDailyPlansTimestamp() => _dailyPlansCache.getTimestamp();

  // ========== Weekly Plans ==========

  void setWeeklyPlans(List<BasePlanModel> plans) => _weeklyPlansCache.set(plans);

  List<BasePlanModel> getWeeklyPlans() => _weeklyPlansCache.get() ?? [];

  DateTime? getWeeklyPlansTimestamp() => _weeklyPlansCache.getTimestamp();

  // ========== Monthly Plans ==========

  void setMonthlyPlans(List<BasePlanModel> plans) => _monthlyPlansCache.set(plans);

  List<BasePlanModel> getMonthlyPlans() => _monthlyPlansCache.get() ?? [];

  DateTime? getMonthlyPlansTimestamp() => _monthlyPlansCache.getTimestamp();

  // ========== Roaming Plans ==========

  void setRoamingPlans(List<BasePlanModel> plans) => _roamingPlansCache.set(plans);

  List<BasePlanModel> getRoamingPlans() => _roamingPlansCache.get() ?? [];

  DateTime? getRoamingPlansTimestamp() => _roamingPlansCache.getTimestamp();

  // ========== RoamEasy Plans ==========

  void setRoamEasyPlans(List<BasePlanModel> plans) => _roamEasyPlansCache.set(plans);

  List<BasePlanModel> getRoamEasyPlans() => _roamEasyPlansCache.get() ?? [];

  DateTime? getRoamEasyPlansTimestamp() => _roamEasyPlansCache.getTimestamp();

  // ========== MiFi Plans ==========

  void setMifiPlans(List<BasePlanModel> plans) => _mifiPlansCache.set(plans);

  List<BasePlanModel> getMifiPlans() => _mifiPlansCache.get() ?? [];

  DateTime? getMifiPlansTimestamp() => _mifiPlansCache.getTimestamp();

  // ========== Liberty Global Plans ==========

  void setLibertyGlobalPlans(List<BasePlanModel> plans) =>
      _libertyGlobalPlansCache.set(plans);

  List<BasePlanModel> getLibertyGlobalPlans() =>
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

  void setAddOnsPrimaryPlans(List<BasePlanModel> plans) =>
      _addOnsPrimaryPlansCache.set(plans);

  List<BasePlanModel> getAddOnsPrimaryPlans() =>
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
