import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/logic/bucket_unit_converter.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/logic/plan_bucket_usage.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/models/bucket_usage_summary_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

/// Joins the active plans' `planBuckets` with the bucket-usage summary to
/// produce a per-bucket [PlanBucketUsage] in display units.
///
/// Aggregation rules:
///  - Plan allowances are summed across all [activePlans] for buckets that
///    share a normalized name (e.g. primary's "Data" 14 GB + secondary's
///    "Data" 5 GB → combined `initial = 19 GB`).
///  - Any contributing bucket marked `unlimited` makes the combined bucket
///    unlimited (any-unlimited-wins).
///  - Buckets marked `suppress` are dropped from that plan's contribution
///    (but other plans may still contribute the same bucket name).
///  - Nested-detail rows are matched when `_planIdOf(detail.purchaseSeq)`
///    is in the set of `activePlans` plan ids.
///
/// Assumes that, across plans, the raw `bucket.amount` for a given bucket
/// name is in the same unit (verified by API contract). If divergence ever
/// shows up, convert per-instance before summing.
List<PlanBucketUsage> computePlanBucketUsage({
  required List<BasePlanModel> activePlans,
  required List<BucketUsageItem> items,
}) {
  if (activePlans.isEmpty) {
    return const <PlanBucketUsage>[];
  }

  final planIds = <String>{};
  for (final plan in activePlans) {
    if (plan.planId.isNotEmpty) planIds.add(plan.planId);
  }

  final aggregates = <String, _BucketAggregate>{};
  final orderedKeys = <String>[]; // preserve first-seen order for stable UI

  for (final plan in activePlans) {
    for (final bucket in plan.planBuckets) {
      if (bucket.suppress) continue;

      final key = _normalize(bucket.name);
      if (key.isEmpty) continue;

      final existing = aggregates[key];
      if (existing == null) {
        aggregates[key] = _BucketAggregate(
          displayName: bucket.name,
          unitFromPlan: bucket.unit,
          rawInitial: bucket.amount,
          isUnlimited: bucket.unlimited,
        );
        orderedKeys.add(key);
      } else {
        existing.rawInitial += bucket.amount;
        if (bucket.unlimited) existing.isUnlimited = true;
      }
    }
  }

  if (aggregates.isEmpty) {
    return const <PlanBucketUsage>[];
  }

  final result = <PlanBucketUsage>[];
  for (final key in orderedKeys) {
    final agg = aggregates[key]!;

    final matchedItem = _findItemForBucketName(items, key);
    final unitType = (matchedItem != null && matchedItem.unitType.isNotEmpty)
        ? matchedItem.unitType
        : agg.unitFromPlan;
    final unitLabel = displayUnitLabel(unitType);

    if (agg.isUnlimited) {
      result.add(
        PlanBucketUsage(
          bucketName: agg.displayName,
          unitLabel: unitLabel,
          isUnlimited: true,
          initial: 0,
          remaining: 0,
          used: 0,
          progress: 0,
          matchedDetailCount: 0,
        ),
      );
      continue;
    }

    final initial = toDisplayUnit(agg.rawInitial, unitType);

    double rawRemaining = 0;
    int matchedDetailCount = 0;
    if (matchedItem != null) {
      for (final detail in matchedItem.nestedDetails) {
        if (planIds.contains(_planIdOf(detail.purchaseSeq))) {
          rawRemaining += detail.currentAmount;
          matchedDetailCount++;
        }
      }
    }
    final remaining = toDisplayUnit(rawRemaining, unitType);
    final used = (initial - remaining).clamp(0.0, double.infinity);
    final progress = initial > 0 ? (used / initial).clamp(0.0, 1.0) : 0.0;

    result.add(
      PlanBucketUsage(
        bucketName: agg.displayName,
        unitLabel: unitLabel,
        isUnlimited: false,
        initial: initial,
        remaining: remaining,
        used: used,
        progress: progress,
        matchedDetailCount: matchedDetailCount,
      ),
    );
  }

  return result;
}

class _BucketAggregate {
  _BucketAggregate({
    required this.displayName,
    required this.unitFromPlan,
    required this.rawInitial,
    required this.isUnlimited,
  });

  final String displayName;
  final String unitFromPlan;
  double rawInitial;
  bool isUnlimited;
}

BucketUsageItem? _findItemForBucketName(
  List<BucketUsageItem> items,
  String normalizedName,
) {
  if (normalizedName.isEmpty) return null;
  for (final item in items) {
    if (_normalize(item.freeUnitTypeName) == normalizedName) {
      return item;
    }
  }
  return null;
}

/// Extracts the plan id from a `PurchaseSeq` value.
///
/// Format: `"<planId>.<timestamp>.<seq>.<expiry>"`, e.g.
/// `"29866.20260303153113.001.20260303153124"` → `"29866"`.
/// Returns the full string when no dot is present, and `""` for empty input.
String _planIdOf(String purchaseSeq) {
  final trimmed = purchaseSeq.trim();
  if (trimmed.isEmpty) return '';
  final dotIndex = trimmed.indexOf('.');
  return dotIndex < 0 ? trimmed : trimmed.substring(0, dotIndex);
}

String _normalize(String s) => s.trim().toLowerCase();
