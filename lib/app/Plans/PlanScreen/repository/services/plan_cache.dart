import '../../models/daily_plan_model.dart';
import '../../models/weekly_plan_model.dart';
import '../../models/monthly_plan_model.dart';
import '../../models/roaming_plan_model.dart';
import '../../models/roameasy_plan_model.dart';
import '../../models/mifi_plan_model.dart';
import '../../models/liberty_global_plan_model.dart';

/// Manages in-memory cache for plan data.
///
/// This class stores:
/// - Raw plan data from API
/// - Typed plan models (Daily, Weekly, Monthly, etc.)
/// - Timestamps for cache invalidation
class PlanCache {
  // Raw plans cache
  List<Map<String, dynamic>> _rawPlans = <Map<String, dynamic>>[];
  DateTime? _rawPlansTimestamp;

  // Typed plans cache
  List<DailyPlanModel> _dailyPlans = <DailyPlanModel>[];
  DateTime? _dailyPlansTimestamp;

  List<WeeklyPlanModel> _weeklyPlans = <WeeklyPlanModel>[];
  DateTime? _weeklyPlansTimestamp;

  List<MonthlyPlanModel> _monthlyPlans = <MonthlyPlanModel>[];
  DateTime? _monthlyPlansTimestamp;

  List<RoamingPlanModel> _roamingPlans = <RoamingPlanModel>[];
  DateTime? _roamingPlansTimestamp;

  List<RoamEasyPlanModel> _roamEasyPlans = <RoamEasyPlanModel>[];
  DateTime? _roamEasyPlansTimestamp;

  List<MifiPlanModel> _mifiPlans = <MifiPlanModel>[];
  DateTime? _mifiPlansTimestamp;

  List<LibertyGlobalPlanModel> _libertyGlobalPlans = <LibertyGlobalPlanModel>[];
  DateTime? _libertyGlobalPlansTimestamp;

  // ========== Raw Plans ==========

  void setRawPlans(List<Map<String, dynamic>> plans) {
    _rawPlans = plans;
    _rawPlansTimestamp = DateTime.now();
  }

  List<Map<String, dynamic>> getRawPlans() => _rawPlans;

  DateTime? getRawPlansTimestamp() => _rawPlansTimestamp;

  bool hasRawPlans() => _rawPlans.isNotEmpty;

  // ========== Daily Plans ==========

  void setDailyPlans(List<DailyPlanModel> plans) {
    _dailyPlans = plans;
    _dailyPlansTimestamp = DateTime.now();
  }

  List<DailyPlanModel> getDailyPlans() => _dailyPlans;

  DateTime? getDailyPlansTimestamp() => _dailyPlansTimestamp;

  // ========== Weekly Plans ==========

  void setWeeklyPlans(List<WeeklyPlanModel> plans) {
    _weeklyPlans = plans;
    _weeklyPlansTimestamp = DateTime.now();
  }

  List<WeeklyPlanModel> getWeeklyPlans() => _weeklyPlans;

  DateTime? getWeeklyPlansTimestamp() => _weeklyPlansTimestamp;

  // ========== Monthly Plans ==========

  void setMonthlyPlans(List<MonthlyPlanModel> plans) {
    _monthlyPlans = plans;
    _monthlyPlansTimestamp = DateTime.now();
  }

  List<MonthlyPlanModel> getMonthlyPlans() => _monthlyPlans;

  DateTime? getMonthlyPlansTimestamp() => _monthlyPlansTimestamp;

  // ========== Roaming Plans ==========

  void setRoamingPlans(List<RoamingPlanModel> plans) {
    _roamingPlans = plans;
    _roamingPlansTimestamp = DateTime.now();
  }

  List<RoamingPlanModel> getRoamingPlans() => _roamingPlans;

  DateTime? getRoamingPlansTimestamp() => _roamingPlansTimestamp;

  // ========== RoamEasy Plans ==========

  void setRoamEasyPlans(List<RoamEasyPlanModel> plans) {
    _roamEasyPlans = plans;
    _roamEasyPlansTimestamp = DateTime.now();
  }

  List<RoamEasyPlanModel> getRoamEasyPlans() => _roamEasyPlans;

  DateTime? getRoamEasyPlansTimestamp() => _roamEasyPlansTimestamp;

  // ========== MiFi Plans ==========

  void setMifiPlans(List<MifiPlanModel> plans) {
    _mifiPlans = plans;
    _mifiPlansTimestamp = DateTime.now();
  }

  List<MifiPlanModel> getMifiPlans() => _mifiPlans;

  DateTime? getMifiPlansTimestamp() => _mifiPlansTimestamp;

  // ========== Liberty Global Plans ==========

  void setLibertyGlobalPlans(List<LibertyGlobalPlanModel> plans) {
    _libertyGlobalPlans = plans;
    _libertyGlobalPlansTimestamp = DateTime.now();
  }

  List<LibertyGlobalPlanModel> getLibertyGlobalPlans() => _libertyGlobalPlans;

  DateTime? getLibertyGlobalPlansTimestamp() => _libertyGlobalPlansTimestamp;

  // ========== Cache Management ==========

  /// Clear all cached data
  void clearAll() {
    _rawPlans = <Map<String, dynamic>>[];
    _rawPlansTimestamp = null;

    _dailyPlans = <DailyPlanModel>[];
    _dailyPlansTimestamp = null;

    _weeklyPlans = <WeeklyPlanModel>[];
    _weeklyPlansTimestamp = null;

    _monthlyPlans = <MonthlyPlanModel>[];
    _monthlyPlansTimestamp = null;

    _roamingPlans = <RoamingPlanModel>[];
    _roamingPlansTimestamp = null;

    _roamEasyPlans = <RoamEasyPlanModel>[];
    _roamEasyPlansTimestamp = null;

    _mifiPlans = <MifiPlanModel>[];
    _mifiPlansTimestamp = null;

    _libertyGlobalPlans = <LibertyGlobalPlanModel>[];
    _libertyGlobalPlansTimestamp = null;
  }
}
