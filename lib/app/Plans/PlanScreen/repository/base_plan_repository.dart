import '../models/plan_model.dart';
import '../models/add_on_model.dart';
import '../models/base_plan_model.dart';
import '../../PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import 'plan_types.dart';

/// Abstract base class for plan repositories.
///
/// This interface defines the contract for fetching and managing plans.
/// Implementations can be:
/// - Production repository (API-based)
/// - Mock repository (hardcoded data for testing/development)
/// - Test repository (for unit tests)
///
/// Now uses unified BasePlanModel for all prepaid plan types
/// (Daily, Weekly, Monthly, Roaming, RoamEasy, MiFi, Liberty Global)
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
  Future<List<BasePlanModel>> fetchDailyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredDailyPlans = false,
  });

  /// Fetch and parse weekly plans.
  ///
  /// Filtering rule (strict):
  /// - PlanType = P
  /// - Frequency = W
  Future<List<BasePlanModel>> fetchWeeklyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredWeeklyPlans = false,
  });

  /// Fetch and parse monthly plans.
  ///
  /// Filtering rule (strict):
  /// - PlanType = P
  /// - Frequency = M
  Future<List<BasePlanModel>> fetchMonthlyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredMonthlyPlans = false,
  });

  /// Fetch and parse roaming plans.
  ///
  /// Filtering rule (strict):
  /// - PlanType = A
  /// - PlanGroup = roaming
  Future<List<BasePlanModel>> fetchRoamingPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredRoamingPlans = false,
  });

  /// Fetch and parse RoamEasy plans.
  ///
  /// Filtering rule (strict):
  /// - PlanType = A
  /// - PlanGroup = roameasy
  Future<List<BasePlanModel>> fetchRoamEasyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredRoamEasyPlans = false,
  });

  /// Fetch and parse MiFi plans.
  ///
  /// Filtering rule (strict):
  /// - PlanType = P
  /// - PlanGroup = mifi (30 day)
  Future<List<BasePlanModel>> fetchMifiPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredMifiPlans = false,
  });

  /// Fetch and parse Liberty Global plans.
  ///
  /// Filtering rule (strict):
  /// - PlanType = A
  /// - PlanGroup = liberty global
  Future<List<BasePlanModel>> fetchLibertyGlobalPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredLibertyGlobalPlans = false,
  });

  /// Fetch and parse Postpaid Roaming plans.
  ///
  /// Filtering rule (strict):
  /// - PlanType = A
  /// - PlanGroup = roaming
  /// - PaymentOption = postpay
  Future<List<HomePlansPostPaidPlanModel>> fetchPostpaidRoamingPlansFromApi({
    bool printRawResponse = false,
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

  /// Fetch and parse bundles `PrimaryPlans` for Add-ons tab.
  Future<List<BasePlanModel>> fetchAddOnsPrimaryPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredPrimaryPlans = false,
  });

  /// Returns the earliest primary plan after repository sorting.
  BasePlanModel? selectEarliestAddOnsPrimaryPlan(
    List<BasePlanModel> primaryPlans,
  );

  /// Maps the selected primary plan's `AvailableBoltOns` to UI add-on models.
  List<HomePlanAddOnModel> mapAvailableBoltOnsToUiAddOns({
    required BasePlanModel primaryPlan,
  });

  // ========== Read-Only Getters ==========

  /// Read-only view of latest raw payload cache.
  List<Map<String, dynamic>> get lastFetchedPlans;

  /// Read-only view of latest payload fetch time.
  DateTime? get lastFetchedAt;

  /// Read-only latest strict daily plans cache.
  List<BasePlanModel> get lastFetchedDailyPlans;

  /// Read-only latest strict daily filter timestamp.
  DateTime? get lastFetchedDailyAt;

  /// Read-only latest strict weekly plans cache.
  List<BasePlanModel> get lastFetchedWeeklyPlans;

  /// Read-only latest strict weekly filter timestamp.
  DateTime? get lastFetchedWeeklyAt;

  /// Read-only latest strict monthly plans cache.
  List<BasePlanModel> get lastFetchedMonthlyPlans;

  /// Read-only latest strict monthly filter timestamp.
  DateTime? get lastFetchedMonthlyAt;

  /// Read-only latest strict roaming plans cache.
  List<BasePlanModel> get lastFetchedRoamingPlans;

  /// Read-only latest strict roaming filter timestamp.
  DateTime? get lastFetchedRoamingAt;

  /// Read-only latest strict RoamEasy plans cache.
  List<BasePlanModel> get lastFetchedRoamEasyPlans;

  /// Read-only latest strict RoamEasy filter timestamp.
  DateTime? get lastFetchedRoamEasyAt;

  /// Read-only latest strict MiFi plans cache.
  List<BasePlanModel> get lastFetchedMifiPlans;

  /// Read-only latest strict MiFi filter timestamp.
  DateTime? get lastFetchedMifiAt;

  /// Read-only latest strict Liberty Global plans cache.
  List<BasePlanModel> get lastFetchedLibertyGlobalPlans;

  /// Read-only latest strict Liberty Global filter timestamp.
  DateTime? get lastFetchedLibertyGlobalAt;

  /// Read-only latest strict Postpaid Roaming plans cache.
  List<HomePlansPostPaidPlanModel> get lastFetchedPostpaidRoamingPlans;

  /// Read-only latest strict Postpaid Roaming filter timestamp.
  DateTime? get lastFetchedPostpaidRoamingAt;

  /// Read-only latest Add-ons primary plan cache.
  List<BasePlanModel> get lastFetchedAddOnsPrimaryPlans;

  /// Read-only latest Add-ons primary plan fetch timestamp.
  DateTime? get lastFetchedAddOnsPrimaryPlansAt;
}
