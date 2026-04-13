import 'package:myaliv_mobile_app/app/Home/best-plans/models/best_plan_model.dart';

/// Status enum for Best Plan state
enum BestPlanStatus {
  initial, // Initial state, no data loaded
  loading, // Fetching plans from API
  loaded, // Plans loaded successfully
  empty, // No active plans available
  failure, // Error occurred
}

/// Immutable state for Best Plan feature
///
/// Contains list of plans, loading status, and error information.
class BestPlanState {
  final BestPlanStatus status;
  final List<BestPlanModel> plans;
  final String? errorMessage;
  final DateTime? lastFetchedAt;

  const BestPlanState({
    required this.status,
    required this.plans,
    this.errorMessage,
    this.lastFetchedAt,
  });

  /// Initial state factory
  factory BestPlanState.initial() {
    return const BestPlanState(
      status: BestPlanStatus.initial,
      plans: [],
      errorMessage: null,
      lastFetchedAt: null,
    );
  }

  /// Copy state with updated fields
  BestPlanState copyWith({
    BestPlanStatus? status,
    List<BestPlanModel>? plans,
    String? errorMessage,
    DateTime? lastFetchedAt,
    bool clearPlans = false,
    bool clearError = false,
  }) {
    return BestPlanState(
      status: status ?? this.status,
      plans: clearPlans ? [] : (plans ?? this.plans),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
    );
  }

  // ========== Convenience Getters ==========

  /// Check if we have plans to display
  bool get hasPlans => plans.isNotEmpty;

  /// Check if currently loading
  bool get isLoading => status == BestPlanStatus.loading;

  /// Check if there was an error
  bool get hasError => status == BestPlanStatus.failure;

  /// Check if state is empty (no plans)
  bool get isEmpty => status == BestPlanStatus.empty;

  /// Check if data is loaded successfully
  bool get isLoaded => status == BestPlanStatus.loaded;

  /// Get number of plans
  int get planCount => plans.length;

  /// Check if cache is still valid (5 minutes TTL)
  bool get isCacheValid {
    if (lastFetchedAt == null) return false;
    final age = DateTime.now().difference(lastFetchedAt!);
    return age.inMinutes < 5;
  }

  @override
  String toString() {
    return 'BestPlanState(status: $status, planCount: $planCount, '
        'errorMessage: $errorMessage, lastFetchedAt: $lastFetchedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BestPlanState &&
        other.status == status &&
        _listEquals(other.plans, plans) &&
        other.errorMessage == errorMessage &&
        other.lastFetchedAt == lastFetchedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      Object.hashAll(plans),
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
