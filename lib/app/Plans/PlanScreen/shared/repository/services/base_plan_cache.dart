/// Generic cache entry with timestamp.
///
/// Reduces boilerplate in cache implementations by providing
/// common caching functionality.
///
/// Usage:
/// ```dart
/// final cache = CacheEntry<List<MyModel>>();
/// cache.set([model1, model2]);
/// final data = cache.get();
/// final timestamp = cache.getTimestamp();
/// ```
class CacheEntry<T> {
  T? _data;
  DateTime? _timestamp;

  /// Store data and update timestamp
  void set(T data) {
    _data = data;
    _timestamp = DateTime.now();
  }

  /// Retrieve cached data
  T? get() => _data;

  /// Get timestamp of when data was cached
  DateTime? getTimestamp() => _timestamp;

  /// Check if cache has data
  ///
  /// For List and Map types, checks if collection is non-empty.
  /// For other types, checks if data is not null.
  bool hasData() {
    if (_data is List) {
      return (_data as List).isNotEmpty;
    }
    if (_data is Map) {
      return (_data as Map).isNotEmpty;
    }
    return _data != null;
  }

  /// Check if cache is stale based on TTL (time-to-live)
  ///
  /// Returns true if:
  /// - No timestamp exists (never cached)
  /// - Time since last cache exceeds TTL
  bool isStale(Duration ttl) {
    final timestamp = _timestamp;
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp) > ttl;
  }

  /// Clear cached data and timestamp
  void clear() {
    _data = null;
    _timestamp = null;
  }
}

/// Base cache with common raw plans caching.
///
/// All plan cache implementations should extend this to get
/// consistent raw plans caching behavior.
///
/// Benefits:
/// - Consistent caching pattern across all plan services
/// - Reduces boilerplate code
/// - Easy to add cache invalidation logic
/// - Built-in TTL support via CacheEntry
///
/// Usage:
/// ```dart
/// class MyPlanCache extends BasePlanCache {
///   final CacheEntry<List<MyPlanModel>> _myPlansCache = CacheEntry();
///
///   void setMyPlans(List<MyPlanModel> plans) => _myPlansCache.set(plans);
///   List<MyPlanModel> getMyPlans() => _myPlansCache.get() ?? [];
///   DateTime? getMyPlansTimestamp() => _myPlansCache.getTimestamp();
///
///   @override
///   void clearAll() {
///     super.clearAll();
///     _myPlansCache.clear();
///   }
/// }
/// ```
abstract class BasePlanCache {
  final CacheEntry<List<Map<String, dynamic>>> _rawPlansCache = CacheEntry();

  /// Store raw plans from API
  void setRawPlans(List<Map<String, dynamic>> plans) => _rawPlansCache.set(plans);

  /// Retrieve raw plans
  List<Map<String, dynamic>> getRawPlans() => _rawPlansCache.get() ?? [];

  /// Get timestamp of when raw plans were cached
  DateTime? getRawPlansTimestamp() => _rawPlansCache.getTimestamp();

  /// Check if raw plans cache has data
  bool hasRawPlans() => _rawPlansCache.hasData();

  /// Check if raw plans cache is stale
  bool isRawPlansStale(Duration ttl) => _rawPlansCache.isStale(ttl);

  /// Clear all cached data
  ///
  /// Subclasses should override and call super to clear their own caches.
  void clearAll() {
    _rawPlansCache.clear();
  }
}
