/// Cache entry with timestamp and TTL support
class PlanCacheEntry<T> {
  PlanCacheEntry({
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Cached data
  final T data;

  /// When this entry was cached
  final DateTime timestamp;

  /// Check if cache is stale based on TTL
  bool isStale({Duration ttl = const Duration(hours: 1)}) {
    final age = DateTime.now().difference(timestamp);
    return age > ttl;
  }

  /// Get age of cache entry
  Duration get age => DateTime.now().difference(timestamp);

  /// Create a fresh entry with same data but new timestamp
  PlanCacheEntry<T> refresh() {
    return PlanCacheEntry(
      data: data,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'PlanCacheEntry(age: ${age.inMinutes}m, stale: ${isStale()})';
  }
}
