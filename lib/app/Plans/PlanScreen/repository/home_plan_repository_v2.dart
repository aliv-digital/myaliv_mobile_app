import 'package:core/core.dart';
import '../models/plan_model.dart';
import '../models/add_on_model.dart';
import '../models/add_ons_primary_plan_model.dart';
import '../models/daily_plan_model.dart';
import '../models/weekly_plan_model.dart';
import '../models/monthly_plan_model.dart';
import '../models/roaming_plan_model.dart';
import '../models/roameasy_plan_model.dart';
import '../models/mifi_plan_model.dart';
import '../models/liberty_global_plan_model.dart';
import '../../PlanScreenPostPaid/models/home_plans_postpaid_plan_model.dart';
import 'base_plan_repository.dart';
import 'plan_types.dart';
import 'services/plan_cache.dart';
import 'services/plan_api_client.dart';
import 'services/plan_filter_service.dart';
import 'services/plan_json_parser.dart';

/// Plan repository - simplified version using service composition.
///
/// This repository orchestrates:
/// - PlanCache: Manages in-memory cache
/// - PlanApiClient: Handles API calls
/// - PlanFilterService: Filters plans by criteria
/// - PlanJsonParser: Parses JSON in background
class HomePlanRepositoryV2 implements BasePlanRepository {
  HomePlanRepositoryV2({
    NetworkService? networkService,
    AuthManager? authManager,
    PlanCache? cache,
    PlanApiClient? apiClient,
    PlanFilterService? filterService,
    PlanJsonParser? jsonParser,
  })  : _cache = cache ?? PlanCache(),
        _apiClient = apiClient ??
            PlanApiClient(
              networkService: networkService,
              authManager: authManager,
            ),
        _filterService = filterService ?? PlanFilterService(),
        _jsonParser = jsonParser ?? PlanJsonParser();

  final PlanCache _cache;
  final PlanApiClient _apiClient;
  final PlanFilterService _filterService;
  final PlanJsonParser _jsonParser;

  // ========== Public API ==========

  @override
  Future<List<Map<String, dynamic>>> getPlans({
    bool printRawResponse = false,
  }) async {
    // Fetch and parse
    final rawJson = await _apiClient.fetchRawPlansJson();
    final plans = await _jsonParser.parse(rawJson);

    // Cache and return
    _cache.setRawPlans(plans);
    return plans;
  }

  @override
  Future<List<DailyPlanModel>> fetchDailyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredDailyPlans = false,
  }) async {
    final plans = await _ensureCacheLoaded();
    final filtered = _filterService.filterByTypeAndFrequency(
      plans: plans,
      planType: 'P',
      frequency: 'D',
    );

    final models = filtered
        .map((map) => DailyPlanModel.fromApiMap(map, includeRawPayload: false))
        .toList(growable: false);

    _cache.setDailyPlans(models);
    return models;
  }

  @override
  Future<List<WeeklyPlanModel>> fetchWeeklyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredWeeklyPlans = false,
  }) async {
    final plans = await _ensureCacheLoaded();
    final filtered = _filterService.filterByTypeAndFrequency(
      plans: plans,
      planType: 'P',
      frequency: 'W',
    );

    final models = filtered
        .map((map) => WeeklyPlanModel.fromApiMap(map, includeRawPayload: false))
        .toList(growable: false);

    _cache.setWeeklyPlans(models);
    return models;
  }

  @override
  Future<List<MonthlyPlanModel>> fetchMonthlyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredMonthlyPlans = false,
  }) async {
    final plans = await _ensureCacheLoaded();
    final filtered = _filterService.filterByTypeAndFrequency(
      plans: plans,
      planType: 'P',
      frequency: 'M',
    );

    final models = filtered
        .map(
            (map) => MonthlyPlanModel.fromApiMap(map, includeRawPayload: false))
        .toList(growable: false);

    _cache.setMonthlyPlans(models);
    return models;
  }

  @override
  Future<List<RoamingPlanModel>> fetchRoamingPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredRoamingPlans = false,
  }) async {
    final plans = await _ensureCacheLoaded();
    final filtered = _filterService.filterByTypeAndGroup(
      plans: plans,
      planType: 'A',
      planGroup: 'roaming',
    );

    final models = filtered
        .map(
            (map) => RoamingPlanModel.fromApiMap(map, includeRawPayload: false))
        .toList(growable: false);

    _cache.setRoamingPlans(models);
    return models;
  }

  @override
  Future<List<RoamEasyPlanModel>> fetchRoamEasyPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredRoamEasyPlans = false,
  }) async {
    final plans = await _ensureCacheLoaded();
    final filtered = _filterService.filterByTypeAndGroup(
      plans: plans,
      planType: 'A',
      planGroup: 'roameasy',
    );

    final models = filtered
        .map((map) =>
            RoamEasyPlanModel.fromApiMap(map, includeRawPayload: false))
        .toList(growable: false);

    _cache.setRoamEasyPlans(models);
    return models;
  }

  @override
  Future<List<MifiPlanModel>> fetchMifiPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredMifiPlans = false,
  }) async {
    final plans = await _ensureCacheLoaded();
    final filtered = _filterService.filterByTypeAndGroup(
      plans: plans,
      planType: 'P',
      planGroup: 'mifi (30 day)',
    );

    final models = filtered
        .map((map) => MifiPlanModel.fromApiMap(map, includeRawPayload: false))
        .toList(growable: false);

    _cache.setMifiPlans(models);
    return models;
  }

  @override
  Future<List<LibertyGlobalPlanModel>> fetchLibertyGlobalPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredLibertyGlobalPlans = false,
  }) async {
    final plans = await _ensureCacheLoaded();
    final filtered = _filterService.filterByTypeAndGroup(
      plans: plans,
      planType: 'A',
      planGroup: 'liberty global',
    );

    final models = filtered
        .map((map) =>
            LibertyGlobalPlanModel.fromApiMap(map, includeRawPayload: false))
        .toList(growable: false);

    _cache.setLibertyGlobalPlans(models);
    return models;
  }

  @override
  Future<List<HomePlansPostPaidPlanModel>> fetchPostpaidRoamingPlansFromApi({
    bool printRawResponse = false,
  }) async {
    final plans = await _ensureCacheLoaded();
    final filtered = _filterService.filterByTypeGroupAndPaymentOption(
      plans: plans,
      planType: 'A',
      planGroup: 'roaming',
      paymentOption: 'postpay',
    );

    final models = filtered
        .map(
          (map) => HomePlansPostPaidPlanModel.fromApiMap(
            map,
            includeRawPayload: false,
          ),
        )
        .toList(growable: false);

    _cache.setPostpaidRoamingPlans(models);
    return models;
  }

  @override
  Future<List<HomePlanModel>> fetchPlans({required HomePlanTab tab}) async {
    // This method is not used for API-based tabs (daily, weekly, monthly, etc.)
    // Those tabs use dedicated fetchXxxPlansFromApi() methods.
    // This is a fallback for any future tabs that might need it.
    // For now, return empty list.
    return const [];
  }

  @override
  Future<List<HomePlanAddOnModel>> fetchAddOns() async {
    final primaryPlans = await fetchAddOnsPrimaryPlansFromApi();
    final selectedPrimaryPlan = selectEarliestAddOnsPrimaryPlan(primaryPlans);

    if (selectedPrimaryPlan == null) {
      return const <HomePlanAddOnModel>[];
    }

    return mapAvailableBoltOnsToUiAddOns(primaryPlan: selectedPrimaryPlan);
  }

  @override
  Future<List<AddOnsPrimaryPlanModel>> fetchAddOnsPrimaryPlansFromApi({
    bool printRawResponse = false,
    bool printFilteredPrimaryPlans = false,
  }) async {
    if (_cache.hasAddOnsPrimaryPlans()) {
      return _cache.getAddOnsPrimaryPlans();
    }

    final bundlesResponse = await _ensureBundlesCacheLoaded();
    final rawPrimaryPlans = _asMapList(bundlesResponse['PrimaryPlans']);

    final primaryPlans = rawPrimaryPlans
        .map(
          (map) =>
              AddOnsPrimaryPlanModel.fromApiMap(map, includeRawPayload: false),
        )
        .toList(growable: false);

    final sortedPrimaryPlans =
        _sortPrimaryPlansByEarliestStartDate(primaryPlans);

    _cache.setAddOnsPrimaryPlans(sortedPrimaryPlans);
    return sortedPrimaryPlans;
  }

  @override
  AddOnsPrimaryPlanModel? selectEarliestAddOnsPrimaryPlan(
    List<AddOnsPrimaryPlanModel> primaryPlans,
  ) {
    if (primaryPlans.isEmpty) {
      return null;
    }

    return primaryPlans.first;
  }

  @override
  List<HomePlanAddOnModel> mapAvailableBoltOnsToUiAddOns({
    required AddOnsPrimaryPlanModel primaryPlan,
  }) {
    return primaryPlan.availableBoltOns
        .map(
          (addOnPlan) => HomePlanAddOnModel(
            id: addOnPlan.planId,
            title: addOnPlan.planName,
            label: _buildAddOnLabel(addOnPlan),
            value: _buildAddOnValue(addOnPlan),
            price: addOnPlan.planAmount,
            vatAmount: addOnPlan.vatAmount,
          ),
        )
        .toList(growable: false);
  }

  // ========== Read-Only Getters ==========

  @override
  List<Map<String, dynamic>> get lastFetchedPlans =>
      List.unmodifiable(_cache.getRawPlans());

  @override
  DateTime? get lastFetchedAt => _cache.getRawPlansTimestamp();

  @override
  List<DailyPlanModel> get lastFetchedDailyPlans =>
      List.unmodifiable(_cache.getDailyPlans());

  @override
  DateTime? get lastFetchedDailyAt => _cache.getDailyPlansTimestamp();

  @override
  List<WeeklyPlanModel> get lastFetchedWeeklyPlans =>
      List.unmodifiable(_cache.getWeeklyPlans());

  @override
  DateTime? get lastFetchedWeeklyAt => _cache.getWeeklyPlansTimestamp();

  @override
  List<MonthlyPlanModel> get lastFetchedMonthlyPlans =>
      List.unmodifiable(_cache.getMonthlyPlans());

  @override
  DateTime? get lastFetchedMonthlyAt => _cache.getMonthlyPlansTimestamp();

  @override
  List<RoamingPlanModel> get lastFetchedRoamingPlans =>
      List.unmodifiable(_cache.getRoamingPlans());

  @override
  DateTime? get lastFetchedRoamingAt => _cache.getRoamingPlansTimestamp();

  @override
  List<RoamEasyPlanModel> get lastFetchedRoamEasyPlans =>
      List.unmodifiable(_cache.getRoamEasyPlans());

  @override
  DateTime? get lastFetchedRoamEasyAt => _cache.getRoamEasyPlansTimestamp();

  @override
  List<MifiPlanModel> get lastFetchedMifiPlans =>
      List.unmodifiable(_cache.getMifiPlans());

  @override
  DateTime? get lastFetchedMifiAt => _cache.getMifiPlansTimestamp();

  @override
  List<LibertyGlobalPlanModel> get lastFetchedLibertyGlobalPlans =>
      List.unmodifiable(_cache.getLibertyGlobalPlans());

  @override
  DateTime? get lastFetchedLibertyGlobalAt =>
      _cache.getLibertyGlobalPlansTimestamp();

  @override
  List<HomePlansPostPaidPlanModel> get lastFetchedPostpaidRoamingPlans =>
      List.unmodifiable(_cache.getPostpaidRoamingPlans());

  @override
  DateTime? get lastFetchedPostpaidRoamingAt =>
      _cache.getPostpaidRoamingPlansTimestamp();

  @override
  List<AddOnsPrimaryPlanModel> get lastFetchedAddOnsPrimaryPlans =>
      List.unmodifiable(_cache.getAddOnsPrimaryPlans());

  @override
  DateTime? get lastFetchedAddOnsPrimaryPlansAt =>
      _cache.getAddOnsPrimaryPlansTimestamp();

  // ========== Private Helpers ==========

  /// Ensure cache is loaded, or fetch from API
  Future<List<Map<String, dynamic>>> _ensureCacheLoaded() async {
    if (_cache.hasRawPlans()) {
      return _cache.getRawPlans();
    }
    return getPlans();
  }

  Future<Map<String, dynamic>> _ensureBundlesCacheLoaded() async {
    if (_cache.hasBundlesResponse()) {
      return _cache.getBundlesResponse();
    }

    final rawJson = await _apiClient.fetchRawBundlesJson();
    final bundles = await _jsonParser.parseBundles(rawJson);
    _cache.setBundlesResponse(bundles);
    return bundles;
  }

  List<AddOnsPrimaryPlanModel> _sortPrimaryPlansByEarliestStartDate(
    List<AddOnsPrimaryPlanModel> primaryPlans,
  ) {
    final sortablePrimaryPlans = primaryPlans
        .asMap()
        .entries
        .map(
          (entry) => _SortablePrimaryPlan(
            originalIndex: entry.key,
            plan: entry.value,
          ),
        )
        .toList(growable: false);

    sortablePrimaryPlans.sort((left, right) {
      final leftStartDate = left.plan.startDateTime;
      final rightStartDate = right.plan.startDateTime;

      if (leftStartDate == null && rightStartDate == null) {
        return left.originalIndex.compareTo(right.originalIndex);
      }

      if (leftStartDate == null) return 1;
      if (rightStartDate == null) return -1;

      final dateCompare = leftStartDate.compareTo(rightStartDate);
      if (dateCompare != 0) return dateCompare;

      return left.originalIndex.compareTo(right.originalIndex);
    });

    return sortablePrimaryPlans
        .map((sortablePlan) => sortablePlan.plan)
        .toList(growable: false);
  }

  String _buildAddOnLabel(AddOnsPrimaryPlanModel addOnPlan) {
    final firstBucket =
        addOnPlan.planBuckets.isEmpty ? null : addOnPlan.planBuckets.first;

    if (firstBucket == null) {
      return 'balance';
    }

    final normalizedBucketName = firstBucket.name.trim().toLowerCase();
    if (normalizedBucketName.isEmpty) {
      return 'balance';
    }

    switch (normalizedBucketName) {
      case 'data':
        return 'data balance';
      case 'minutes':
        return 'minutes balance';
      case 'texts':
        return 'text balance';
      default:
        return '$normalizedBucketName balance';
    }
  }

  String _buildAddOnValue(AddOnsPrimaryPlanModel addOnPlan) {
    final firstBucket =
        addOnPlan.planBuckets.isEmpty ? null : addOnPlan.planBuckets.first;

    if (firstBucket == null) {
      return '';
    }

    final amountText = _formatWholeOrDecimal(firstBucket.amount);
    final unitText = firstBucket.unit.trim().toLowerCase();

    if (unitText.isEmpty) {
      return amountText;
    }

    return '$amountText$unitText';
  }

  String _formatWholeOrDecimal(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value is! List) {
      return const <Map<String, dynamic>>[];
    }

    return value
        .whereType<Map>()
        .map(
          (map) => map.map(
            (dynamic key, dynamic value) =>
                MapEntry<String, dynamic>(key.toString(), value),
          ),
        )
        .toList(growable: false);
  }
}

class _SortablePrimaryPlan {
  const _SortablePrimaryPlan({
    required this.originalIndex,
    required this.plan,
  });

  final int originalIndex;
  final AddOnsPrimaryPlanModel plan;
}
