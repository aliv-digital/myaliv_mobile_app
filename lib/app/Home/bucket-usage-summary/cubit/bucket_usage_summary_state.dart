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

  /// Primary + secondary plans counted toward the home screen's usage cards.
  ///
  /// Sourced from `PlansState.activePlansForBucketUsage`. Used by
  /// [activePlanBucketUsage], with [standAlonePlans] contributions
  /// subtracted from any shared buckets so primary entitlements aren't
  /// inflated by roaming-plan allotments.
  final List<BasePlanModel> activePlans;

  /// Stand-alone plans (roameasy / travel20). Not rendered on the home
  /// screen — kept here so future surfaces (e.g. the Usage tab's roaming
  /// section) can read [roamingPlanBucketUsage] without recomputing.
  final List<BasePlanModel> standAlonePlans;

  const BucketUsageSummaryState({
    required this.status,
    this.summary,
    this.errorMessage,
    this.lastFetchedAt,
    this.deviceAccountId,
    this.activePlans = const <BasePlanModel>[],
    this.standAlonePlans = const <BasePlanModel>[],
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
    List<BasePlanModel>? standAlonePlans,
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
      standAlonePlans: clearActivePlans
          ? const <BasePlanModel>[]
          : (standAlonePlans ?? this.standAlonePlans),
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

  /// Plan ids of all primary + secondary plans counted on the home screen.
  Set<String> get activePlanIds {
    return activePlans
        .map((p) => p.planId)
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  /// Plan ids of all stand-alone (roaming) plans.
  Set<String> get standAlonePlanIds {
    return standAlonePlans
        .map((p) => p.planId)
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  /// Per-bucket view-model for primary + secondary plans, with stand-alone
  /// nested-detail contributions stripped from any shared buckets (e.g.
  /// roameasy's local 200 MB "data" share is moved into
  /// [roamingPlanBucketUsage] rather than inflating liberty40's row).
  ///
  /// Pure function call — cheap on rebuilds and identical for the same
  /// state instance (BLoC state is immutable).
  List<PlanBucketUsage> get activePlanBucketUsage => computePlanBucketUsage(
        activePlans: activePlans,
        items: items,
        excludePlanIds: standAlonePlanIds,
      );

  /// Per-bucket view-model for stand-alone (roaming) plans. Mirror of
  /// [activePlanBucketUsage] with the two plan groups swapped — primary +
  /// secondary contributions are excluded so each row reflects only the
  /// roaming plan's own allowance. Currently stored for future surfaces;
  /// the home screen does not render it.
  List<PlanBucketUsage> get roamingPlanBucketUsage => computePlanBucketUsage(
        activePlans: standAlonePlans,
        items: items,
        excludePlanIds: activePlanIds,
      );

  /// Per-bucket view-model for a single stand-alone plan. Excludes
  /// primary/secondary plans **and** every other stand-alone plan so the
  /// rows reflect only this plan's own allowance — required when the
  /// Usage tab renders one usage block per roaming card and shared bucket
  /// names (e.g. two roaming plans both contributing to "data") must not
  /// bleed across cards.
  List<PlanBucketUsage> bucketUsageForPlan(BasePlanModel plan) {
    final otherStandAloneIds = standAlonePlanIds.difference({plan.planId});
    return computePlanBucketUsage(
      activePlans: [plan],
      items: items,
      excludePlanIds: activePlanIds.union(otherStandAloneIds),
    );
  }

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
    standAlonePlans,
  ];

  @override
  String toString() {
    return 'BucketUsageSummaryState(status: $status, '
        'itemCount: $itemCount, deviceAccountId: $deviceAccountId, '
        'activePlanIds: $activePlanIds, '
        'standAlonePlanIds: $standAlonePlanIds, '
        'errorMessage: $errorMessage, lastFetchedAt: $lastFetchedAt)';
  }
}
