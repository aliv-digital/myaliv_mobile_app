import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_on_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/models/plan_categorization_result.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/bundle_response_parser.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_api_service.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_parser_service.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_cache_service.dart';

/// Result class for add-ons fetch
class AddOnsResult {
  const AddOnsResult({
    this.addOns = const [],
    this.primaryPlans = const [],
    this.secondaryPlans = const [],
    this.standAlonePlans = const [],
  });

  final List<HomePlanAddOnModel> addOns;
  final List<BasePlanModel> primaryPlans;
  final List<BasePlanModel> secondaryPlans;
  final List<BasePlanModel> standAlonePlans;

  BasePlanModel? get primaryPlan =>
      primaryPlans.isNotEmpty ? primaryPlans.first : null;
}

/// Repository for managing plan data
///
/// Responsibilities:
/// - Coordinate API, Parser, and Cache services
/// - Provide simple API for fetching categorized plans
/// - Handle errors and fallbacks
class PlansRepository {
  PlansRepository({
    PlanApiService? apiService,
    PlanParserService? parserService,
    PlanCacheService? cacheService,
  }) : _apiService = apiService ?? PlanApiService(),
       _parserService = parserService ?? PlanParserService(),
       _cacheService = cacheService ?? PlanCacheService();

  final PlanApiService _apiService;
  final PlanParserService _parserService;
  final PlanCacheService _cacheService;

  /// Fetch and categorize all plans
  ///
  /// Returns categorized plans from cache if fresh, otherwise fetches from API
  Future<PlanCategorizationResult> fetchCategorizedPlans({
    bool forceRefresh = false,
    Duration cacheTtl = const Duration(hours: 1),
  }) async {
    // Return cached data if available and fresh
    if (!forceRefresh &&
        _cacheService.hasFreshCategorizedPlans(ttl: cacheTtl)) {
      final cached = _cacheService.getCategorizedPlans();
      if (cached != null) return cached;
    }

    // Fetch from API
    final rawJson = await _apiService.fetchRawPlansJson();

    // Parse JSON to list of maps
    final rawPlans = await _parserService.parseRawJson(rawJson);

    // Categorize and parse in single pass
    final result = await _parserService.parseAndCategorize(rawPlans);

    // Cache the result
    _cacheService.setCategorizedPlans(result);

    return result;
  }

  /// Get plans for a specific category
  Future<List<T>> fetchPlansForCategory<T>(
    PlanCategory category, {
    bool forceRefresh = false,
  }) async {
    final result = await fetchCategorizedPlans(forceRefresh: forceRefresh);
    return result.getPlansForCategory<T>(category);
  }

  /// Fetch bundles data
  Future<Map<String, dynamic>> fetchBundles({
    bool forceRefresh = false,
    Duration cacheTtl = const Duration(hours: 1),
  }) async {
    // Return cached data if available and fresh
    if (!forceRefresh && _cacheService.hasFreshBundles(ttl: cacheTtl)) {
      final cached = _cacheService.getBundles();
      if (cached != null) return cached;
    }

    // Fetch from API
    final rawJson = await _apiService.fetchRawBundlesJson();

    // Parse JSON
    final bundles = await _parserService.parseBundlesJson(rawJson);

    // Cache the result
    _cacheService.setBundles(bundles);

    return bundles;
  }

  /// Clear all caches
  void clearCache() {
    _cacheService.clearAll();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return _cacheService.getCacheStats();
  }

  /// Check if category has cached data
  bool hasCachedDataForCategory(PlanCategory category) {
    return _cacheService.hasCategoryData(category);
  }

  /// Get cached result without fetching
  PlanCategorizationResult? getCachedResult() {
    return _cacheService.getCategorizedPlans();
  }

  /// Fetch add-ons data (primary plans + available bolt-ons)
  ///
  /// This fetches bundles, extracts primary plans, sorts by earliest start date,
  /// and maps available bolt-ons to UI add-on models.
  Future<AddOnsResult> fetchAddOnsData({
    bool forceRefresh = false,
    Duration cacheTtl = const Duration(hours: 1),
  }) async {
    try {
      final bundles = await fetchBundles(
        forceRefresh: forceRefresh,
        cacheTtl: cacheTtl,
      );

      final result = BundleResponseParser.parse(bundles);

      if (kDebugMode) {
        debugPrint(
          '✅ PlansRepository: Fetched ${result.primaryPlans.length} primary plans, '
          '${result.secondaryPlans.length} secondary plans, '
          '${result.standAlonePlans.length} stand-alone plans, '
          '${result.addOns.length} add-ons',
        );
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PlansRepository: Error fetching add-ons - $e');
      }
      return const AddOnsResult();
    }
  }
}
