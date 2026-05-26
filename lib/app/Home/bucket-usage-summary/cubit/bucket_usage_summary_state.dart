import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/models/bucket_usage_summary_model.dart';

/// Loading state for bucket usage summary.
enum BucketUsageSummaryStatus { initial, loading, loaded, failure }

/// Immutable state for the bucket usage summary feature.
class BucketUsageSummaryState {
  final BucketUsageSummaryStatus status;
  final BucketUsageSummaryModel? summary;
  final String? errorMessage;
  final DateTime? lastFetchedAt;
  final int? deviceAccountId;

  const BucketUsageSummaryState({
    required this.status,
    this.summary,
    this.errorMessage,
    this.lastFetchedAt,
    this.deviceAccountId,
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
    bool clearSummary = false,
    bool clearError = false,
  }) {
    return BucketUsageSummaryState(
      status: status ?? this.status,
      summary: clearSummary ? null : (summary ?? this.summary),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      deviceAccountId: deviceAccountId ?? this.deviceAccountId,
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
  String toString() {
    return 'BucketUsageSummaryState(status: $status, '
        'itemCount: $itemCount, deviceAccountId: $deviceAccountId, '
        'errorMessage: $errorMessage, lastFetchedAt: $lastFetchedAt)';
  }
}
