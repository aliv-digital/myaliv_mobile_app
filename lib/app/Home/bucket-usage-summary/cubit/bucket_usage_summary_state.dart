import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/logic/plan_bucket_usage.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/logic/plan_bucket_usage_calculator.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/models/bucket_usage_summary_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

/// Loading state for bucket usage summary.
enum BucketUsageSummaryStatus { initial, loading, loaded, failure }

/// Immutable state for the bucket usage summary feature.
class BucketUsageSummaryState extends Equatable {
  final BucketUsageSummaryStatus status;
  final BucketUsageSummaryModel? summary;
  final String? errorMessage;
  final DateTime? lastFetchedAt;
  final int? deviceAccountId;

  /// Plans counted toward bucket-usage aggregation.
  ///
  /// Sourced from `PlansState.activePlansForBucketUsage` — the union of
  /// primary and secondary plans, falling back to stand-alone plans when
  /// both are empty. Used by [activePlanBucketUsage] to join with the
  /// bucket-usage summary.
  final List<BasePlanModel> activePlans;

  const BucketUsageSummaryState({
    required this.status,
    this.summary,
    this.errorMessage,
    this.lastFetchedAt,
    this.deviceAccountId,
    this.activePlans = const <BasePlanModel>[],
  });

  factory BucketUsageSummaryState.initial() {
    return const BucketUsageSummaryState(
      status: BucketUsageSummaryStatus.initial,
    );
  }

  BucketUsageSummaryState copyWith({
    BucketUsageSummaryStatus? status,
    BucketUsageSummaryModel? summary,
    String? errorMessage,
    DateTime? lastFetchedAt,
    int? deviceAccountId,
    List<BasePlanModel>? activePlans,
    bool clearSummary = false,
    bool clearError = false,
    bool clearActivePlans = false,
  }) {
    return BucketUsageSummaryState(
      status: status ?? this.status,
      summary: clearSummary ? null : (summary ?? this.summary),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      deviceAccountId: deviceAccountId ?? this.deviceAccountId,
      activePlans: clearActivePlans
          ? const <BasePlanModel>[]
          : (activePlans ?? this.activePlans),
    );
  }

  bool get isLoading => status == BucketUsageSummaryStatus.loading;

  bool get isLoaded => status == BucketUsageSummaryStatus.loaded;

  bool get hasError => status == BucketUsageSummaryStatus.failure;

  bool get hasSummary => summary != null;

  List<BucketUsageItem> get items {
    return summary?.items ?? const <BucketUsageItem>[];
  }

  int get itemCount => items.length;

  // ===== Active plan convenience getters =====

  bool get hasActivePlans => activePlans.isNotEmpty;

  /// Plan ids of all plans counted toward bucket-usage aggregation.
  Set<String> get activePlanIds {
    return activePlans
        .map((p) => p.planId)
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  /// Derived per-bucket view-model joining [activePlans] with [items].
  ///
  /// Pure function call — cheap on rebuilds and identical for the same
  /// state instance (BLoC state is immutable).
  List<PlanBucketUsage> get activePlanBucketUsage =>
      computePlanBucketUsage(activePlans: activePlans, items: items);

  /// Cache is valid only for the same device account.
  bool isCacheValidFor(int requestedDeviceAccountId) {
    if (lastFetchedAt == null) {
      return false;
    }

    if (deviceAccountId != requestedDeviceAccountId) {
      return false;
    }

    final age = DateTime.now().difference(lastFetchedAt!);
    return age.inMinutes < 5;
  }

  @override
  List<Object?> get props => [
    status,
    summary,
    errorMessage,
    lastFetchedAt,
    deviceAccountId,
    activePlans,
  ];

  @override
  String toString() {
    return 'BucketUsageSummaryState(status: $status, '
        'itemCount: $itemCount, deviceAccountId: $deviceAccountId, '
        'activePlanIds: $activePlanIds, '
        'errorMessage: $errorMessage, lastFetchedAt: $lastFetchedAt)';
  }
}
