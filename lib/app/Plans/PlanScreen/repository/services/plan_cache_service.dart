import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/models/plan_categorization_result.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/models/plan_cache_entry.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/enums/plan_category.dart';

/// Service for caching categorized plans
class PlanCacheService {
  PlanCacheEntry<PlanCategorizationResult>? _categorizedPlansCache;
  PlanCacheEntry<Map<String, dynamic>>? _bundlesCache;

  /// Check if categorized plans cache exists and is fresh
  bool hasFreshCategorizedPlans({Duration ttl = const Duration(hours: 1)}) {
    if (_categorizedPlansCache == null) return false;
    return !_categorizedPlansCache!.isStale(ttl: ttl);
  }

  /// Get cached categorized plans
  PlanCategorizationResult? getCategorizedPlans() {
    return _categorizedPlansCache?.data;
  }

  /// Set categorized plans cache
  void setCategorizedPlans(PlanCategorizationResult result) {
    _categorizedPlansCache = PlanCacheEntry(data: result);
  }

  /// Get cache timestamp
  DateTime? getCategorizedPlansTimestamp() {
    return _categorizedPlansCache?.timestamp;
  }

  /// Get cache age
  Duration? getCategorizedPlansAge() {
    return _categorizedPlansCache?.age;
  }

  /// Check if bundles cache exists and is fresh
  bool hasFreshBundles({Duration ttl = const Duration(hours: 1)}) {
    if (_bundlesCache == null) return false;
    return !_bundlesCache!.isStale(ttl: ttl);
  }

  /// Get cached bundles
  Map<String, dynamic>? getBundles() {
    return _bundlesCache?.data;
  }

  /// Set bundles cache
  void setBundles(Map<String, dynamic> bundles) {
    _bundlesCache = PlanCacheEntry(data: bundles);
  }

  /// Get bundles cache timestamp
  DateTime? getBundlesTimestamp() {
    return _bundlesCache?.timestamp;
  }

  /// Clear all caches
  void clearAll() {
    _categorizedPlansCache = null;
    _bundlesCache = null;
  }

  /// Clear only categorized plans cache
  void clearCategorizedPlans() {
    _categorizedPlansCache = null;
  }

  /// Clear only bundles cache
  void clearBundles() {
    _bundlesCache = null;
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'categorizedPlans': {
        'exists': _categorizedPlansCache != null,
        'age': _categorizedPlansCache?.age.inMinutes,
        'stale': _categorizedPlansCache?.isStale() ?? false,
        'timestamp': _categorizedPlansCache?.timestamp.toIso8601String(),
      },
      'bundles': {
        'exists': _bundlesCache != null,
        'age': _bundlesCache?.age.inMinutes,
        'stale': _bundlesCache?.isStale() ?? false,
        'timestamp': _bundlesCache?.timestamp.toIso8601String(),
      },
    };
  }

  /// Refresh cache (mark as fresh without changing data)
  void refreshCategorizedPlans() {
    if (_categorizedPlansCache != null) {
      _categorizedPlansCache = _categorizedPlansCache!.refresh();
    }
  }

  /// Check if specific category has data
  bool hasCategoryData(PlanCategory category) {
    final result = getCategorizedPlans();
    if (result == null) return false;

    final plans = result.categorizedPlans[category];
    return plans != null && plans.isNotEmpty;
  }

  /// Get plan count for a category
  int getCategoryCount(PlanCategory category) {
    final result = getCategorizedPlans();
    if (result == null) return 0;

    return result.categorizedPlans[category]?.length ?? 0;
  }
}
