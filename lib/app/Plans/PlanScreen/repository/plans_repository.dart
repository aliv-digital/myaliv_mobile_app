import 'package:flutter/foundation.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_on_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/models/plan_categorization_result.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_api_service.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_parser_service.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_cache_service.dart';

/// Result class for add-ons fetch
class AddOnsResult {
  const AddOnsResult({
    this.addOns = const [],
    this.primaryPlans = const [],
    this.standAlonePlans = const [],
  });

  final List<HomePlanAddOnModel> addOns;
  final List<BasePlanModel> primaryPlans;
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
  })  : _apiService = apiService ?? PlanApiService(),
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
    if (!forceRefresh && _cacheService.hasFreshCategorizedPlans(ttl: cacheTtl)) {
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
      // Fetch bundles
      final bundles = await fetchBundles(
        forceRefresh: forceRefresh,
        cacheTtl: cacheTtl,
      );

      // Extract primary plans
      final rawPrimaryPlans = _asMapList(bundles['PrimaryPlans']);

      // Parse to BasePlanModel
      final primaryPlans = rawPrimaryPlans
          .map((map) => BasePlanModel.fromApiMap(map, includeRawPayload: false))
          .toList(growable: false);

      // Sort by earliest start date
      final sortedPrimaryPlans = _sortPrimaryPlansByEarliestStartDate(
        primaryPlans,
      );

      // Map bolt-ons from earliest primary plan to UI add-ons
      final addOns = sortedPrimaryPlans.isNotEmpty
          ? _mapAvailableBoltOnsToUiAddOns(sortedPrimaryPlans.first)
          : <HomePlanAddOnModel>[];

      // Extract and parse stand-alone plans (travel20/30/50 etc.)
      // SecondaryPlans is intentionally ignored.
      final standAlonePlans = _sortPrimaryPlansByEarliestStartDate(
        _asMapList(bundles['StandAlonePlans'])
            .map(
              (map) => BasePlanModel.fromApiMap(map, includeRawPayload: false),
            )
            .toList(growable: false),
      );

      if (kDebugMode) {
        debugPrint(
          '✅ PlansRepository: Fetched ${sortedPrimaryPlans.length} primary plans, '
          '${standAlonePlans.length} stand-alone plans, '
          '${addOns.length} add-ons',
        );
      }

      return AddOnsResult(
        addOns: addOns,
        primaryPlans: sortedPrimaryPlans,
        standAlonePlans: standAlonePlans,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ PlansRepository: Error fetching add-ons - $e');
      }
      return const AddOnsResult();
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ═══════════════════════════════════════════════════════════════════

  List<BasePlanModel> _sortPrimaryPlansByEarliestStartDate(
    List<BasePlanModel> primaryPlans,
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

  List<HomePlanAddOnModel> _mapAvailableBoltOnsToUiAddOns(
    BasePlanModel primaryPlan,
  ) {
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

  String _buildAddOnLabel(BasePlanModel addOnPlan) {
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

  String _buildAddOnValue(BasePlanModel addOnPlan) {
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
  final BasePlanModel plan;
}
