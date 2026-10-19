import 'package:equatable/equatable.dart';

/// Derived per-bucket view-model that joins a plan allowance with usage.
///
/// All numeric fields are in **display unit** (e.g. GB, mins) — never raw
/// API units. Built by `computePlanBucketUsage` from the active primary plan
/// and the bucket usage summary.
class PlanBucketUsage extends Equatable {
  const PlanBucketUsage({
    required this.bucketName,
    required this.bucketUnit,
    required this.unitLabel,
    required this.isUnlimited,
    required this.initial,
    required this.remaining,
    required this.used,
    required this.progress,
    required this.matchedDetailCount,
  });

  /// Plan bucket name (e.g. "Data", "Voice"). Sourced from
  /// `BasePlanBucketModel.name`. Marketing-facing — may be renamed without
  /// backend coordination; prefer [bucketUnit] for identity checks.
  final String bucketName;

  /// Stable backend identifier (e.g. `INS_Data_roam_US_Canada`). Sourced
  /// from `BasePlanBucketModel.bucketUnit`. Use this instead of
  /// [bucketName] when gating UI on a specific bucket.
  final String bucketUnit;

  /// Canonical display label for the unit (e.g. "GB", "mins").
  final String unitLabel;

  /// True when the plan bucket is unlimited; numeric fields are zero in
  /// that case and the UI should render an "unlimited" treatment.
  final bool isUnlimited;

  /// Plan allowance for this bucket in display unit.
  final double initial;

  /// Remaining amount for this bucket (sum of matched nested-detail
  /// `currentAmount` values, in display unit).
  final double remaining;

  /// `max(initial - remaining, 0)` in display unit.
  final double used;

  /// `used / initial`, clamped to `[0, 1]`. Zero when `initial <= 0`.
  final double progress;

  /// Number of nested-detail rows that contributed to [remaining]. Useful
  /// for debug / drill-down; not used by `==`.
  final int matchedDetailCount;

  @override
  List<Object?> get props => [
    bucketName,
    bucketUnit,
    unitLabel,
    isUnlimited,
    initial,
    remaining,
    used,
    progress,
    matchedDetailCount,
  ];

  @override
  String toString() {
    return 'PlanBucketUsage(name: $bucketName, code: $bucketUnit, '
        'unit: $unitLabel, unlimited: $isUnlimited, initial: $initial, '
        'remaining: $remaining, used: $used, progress: $progress, '
        'matched: $matchedDetailCount)';
  }
}
