import 'package:myaliv_mobile_app/app/Home/my-limits/models/consumption_limit_model.dart';

/// Status enum for Consumption Limit state
enum ConsumptionLimitStatus {
  initial, // Initial state, no data loaded
  loading, // Fetching limits from API
  loaded, // Limits loaded successfully
  failure, // Error occurred
}

/// Immutable state for Consumption Limit feature
///
/// Contains limits data, loading status, and error information.
class ConsumptionLimitState {
  final ConsumptionLimitStatus status;
  final List<ConsumptionLimitModel> limits;
  final String? errorMessage;
  final DateTime? lastFetchedAt;

  const ConsumptionLimitState({
    required this.status,
    required this.limits,
    this.errorMessage,
    this.lastFetchedAt,
  });

  /// Initial state factory
  factory ConsumptionLimitState.initial() {
    return const ConsumptionLimitState(
      status: ConsumptionLimitStatus.initial,
      limits: [],
      errorMessage: null,
      lastFetchedAt: null,
    );
  }

  /// Copy state with updated fields
  ConsumptionLimitState copyWith({
    ConsumptionLimitStatus? status,
    List<ConsumptionLimitModel>? limits,
    String? errorMessage,
    DateTime? lastFetchedAt,
    bool clearLimits = false,
    bool clearError = false,
  }) {
    return ConsumptionLimitState(
      status: status ?? this.status,
      limits: clearLimits ? [] : (limits ?? this.limits),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
    );
  }

  // ========== Convenience Getters ==========

  /// Check if we have limits data
  bool get hasLimits => limits.isNotEmpty;

  /// Check if currently loading
  bool get isLoading => status == ConsumptionLimitStatus.loading;

  /// Check if there was an error
  bool get hasError => status == ConsumptionLimitStatus.failure;

  /// Check if data is loaded successfully
  bool get isLoaded => status == ConsumptionLimitStatus.loaded;

  /// Get limit by API name
  ConsumptionLimitModel? getLimitByName(String name) {
    try {
      return limits.firstWhere((l) => l.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Get local text limit
  ConsumptionLimitModel? get localTextLimit =>
      getLimitByName('C_SMS_local_Restriction');

  /// Get local data limit
  ConsumptionLimitModel? get localDataLimit =>
      getLimitByName('C_GPRS_Local');

  /// Get local talk mins limit
  ConsumptionLimitModel? get localTalkLimit =>
      getLimitByName('C_Voice_local_restriction');

  /// Get international roaming limit
  ConsumptionLimitModel? get intlRoamingLimit =>
      getLimitByName('C_IR_restriction');

  /// Get international talk mins limit
  ConsumptionLimitModel? get intlTalkLimit =>
      getLimitByName('C_IDD_Restriction');

  /// Check if cache is still valid (5 minutes TTL)
  bool get isCacheValid {
    if (lastFetchedAt == null) return false;
    final age = DateTime.now().difference(lastFetchedAt!);
    return age.inMinutes < 5;
  }

  @override
  String toString() {
    return 'ConsumptionLimitState(status: $status, '
        'limitsCount: ${limits.length}, '
        'errorMessage: $errorMessage, '
        'lastFetchedAt: $lastFetchedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConsumptionLimitState &&
        other.status == status &&
        _listEquals(other.limits, limits) &&
        other.errorMessage == errorMessage &&
        other.lastFetchedAt == lastFetchedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      Object.hashAll(limits),
      errorMessage,
      lastFetchedAt,
    );
  }

  /// Helper to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
