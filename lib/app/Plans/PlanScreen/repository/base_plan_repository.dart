import '../models/plan_model.dart';
import '../models/add_on_model.dart';
import '../models/daily_plan_model.dart';
import '../models/weekly_plan_model.dart';
import '../models/monthly_plan_model.dart';
import '../models/roaming_plan_model.dart';
import '../models/roameasy_plan_model.dart';
import '../models/mifi_plan_model.dart';
import '../models/liberty_global_plan_model.dart';
import 'plan_types.dart';

/// Abstract base class for plan repositories.
///
/// This interface defines the contract for fetching and managing plans.
/// Implementations can be:
/// - Production repository (API-based)
/// - Mock repository (hardcoded data for testing/development)
/// - Test repository (for unit tests)
abstract class BasePlanRepository {
  /// Fetches full available-plans payload and normalizes it.
  ///
  /// Returns a list of normalized plan maps from the data source.
  Future<List<Map<String, dynamic>>> getPlans({
    bool printRawResponse = false,
  });

  /// Fetch and parse daily plans.
  ///
  /// Filtering rule (strict):
  /// - PlanType = P
  /// - Frequency = D
  Future<List<DailyPlanModel>> fetchDailyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredDailyPlans = false,
  });

  /// Fetch and parse weekly plans.
  ///
  /// Filtering rule (strict):
  /// - PlanType = P
  /// - Frequency = W
  Future<List<WeeklyPlanModel>> fetchWeeklyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredWeeklyPlans = false,
  });

  /// Fetch and parse monthly plans.
  ///
  /// Filtering rule (strict):
  /// - PlanType = P
  /// - Frequency = M
  Future<List<MonthlyPlanModel>> fetchMonthlyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredMonthlyPlans = false,
  });

  /// Fetch and parse roaming plans.
  ///
  /// Filtering rule (strict):
  /// - PlanType = A
  /// - PlanGroup = roaming
  Future<List<RoamingPlanModel>> fetchRoamingPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredRoamingPlans = false,
  });

  /// Fetch and parse RoamEasy plans.
  ///
  /// Filtering rule (strict):
  /// - PlanType = A
  /// - PlanGroup = roameasy
  Future<List<RoamEasyPlanModel>> fetchRoamEasyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredRoamEasyPlans = false,
  });

  /// Fetch and parse MiFi plans.
  ///
  /// Filtering rule (strict):
  /// - PlanType = P
  /// - PlanGroup = mifi (30 day)
  Future<List<MifiPlanModel>> fetchMifiPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredMifiPlans = false,
  });

  /// Fetch and parse Liberty Global plans.
  ///
  /// Filtering rule (strict):
  /// - PlanType = A
  /// - PlanGroup = liberty global
  Future<List<LibertyGlobalPlanModel>> fetchLibertyGlobalPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredLibertyGlobalPlans = false,
  });

  /// Fetch plans for a specific tab.
  ///
  /// Returns UI-ready HomePlanModel list for display.
  Future<List<HomePlanModel>> fetchPlans({
    required HomePlanTab tab,
  });

  /// Fetch add-ons.
  ///
  /// Returns UI-ready HomePlanAddOnModel list for display.
  Future<List<HomePlanAddOnModel>> fetchAddOns();

  // ========== Read-Only Getters ==========

  /// Read-only view of latest raw payload cache.
  List<Map<String, dynamic>> get lastFetchedPlans;

  /// Read-only view of latest payload fetch time.
  DateTime? get lastFetchedAt;

  /// Read-only latest strict daily plans cache.
  List<DailyPlanModel> get lastFetchedDailyPlans;

  /// Read-only latest strict daily filter timestamp.
  DateTime? get lastFetchedDailyAt;

  /// Read-only latest strict weekly plans cache.
  List<WeeklyPlanModel> get lastFetchedWeeklyPlans;

  /// Read-only latest strict weekly filter timestamp.
  DateTime? get lastFetchedWeeklyAt;

  /// Read-only latest strict monthly plans cache.
  List<MonthlyPlanModel> get lastFetchedMonthlyPlans;

  /// Read-only latest strict monthly filter timestamp.
  DateTime? get lastFetchedMonthlyAt;

  /// Read-only latest strict roaming plans cache.
  List<RoamingPlanModel> get lastFetchedRoamingPlans;

  /// Read-only latest strict roaming filter timestamp.
  DateTime? get lastFetchedRoamingAt;

  /// Read-only latest strict RoamEasy plans cache.
  List<RoamEasyPlanModel> get lastFetchedRoamEasyPlans;

  /// Read-only latest strict RoamEasy filter timestamp.
  DateTime? get lastFetchedRoamEasyAt;

  /// Read-only latest strict MiFi plans cache.
  List<MifiPlanModel> get lastFetchedMifiPlans;

  /// Read-only latest strict MiFi filter timestamp.
  DateTime? get lastFetchedMifiAt;

  /// Read-only latest strict Liberty Global plans cache.
  List<LibertyGlobalPlanModel> get lastFetchedLibertyGlobalPlans;

  /// Read-only latest strict Liberty Global filter timestamp.
  DateTime? get lastFetchedLibertyGlobalAt;
}
