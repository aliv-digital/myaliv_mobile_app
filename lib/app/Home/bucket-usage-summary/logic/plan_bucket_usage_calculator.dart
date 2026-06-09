import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/logic/bucket_unit_converter.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/logic/plan_bucket_usage.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/models/bucket_usage_summary_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

/// Joins the active plans' `planBuckets` with the bucket-usage summary to
/// produce a per-bucket [PlanBucketUsage] in display units.
///
/// Source of truth:
///  - The list of bucket *names* to render comes from [activePlans] (deduped
///    by normalized name, in first-seen order, skipping `suppress` rows).
///  - The numeric `initial` for each row starts from the API's
///    `BucketUsageItem.totalInitialAmount` (authoritative user entitlement)
///    and then subtracts the sum of `currentAmount` for nested-detail rows
///    whose `purchaseSeq` planId is in [excludePlanIds]. This lets a caller
///    render usage for one plan subset (e.g. primary + secondary) while
///    "moving" the contribution from another subset (e.g. stand-alone
///    roaming) out of the row — the subtraction is exact when the excluded
///    plans are 0% used and slightly under-counts the primary initial
///    otherwise.
///  - `remaining` is the sum of `currentAmount` for nested rows whose
///    `purchaseSeq` planId matches an active plan id, converted to display
///    unit once at the end. The `planId` filter keeps out unrelated
///    purchase lines that may share a `BucketUsageItem` with the active
///    plan set.
///
/// Buckets declared on a plan but missing from the API response are skipped
/// — the plan's declared `bucket.amount` has been observed to misrepresent
/// the user's total entitlement (e.g. per-period quota vs accumulated
/// allowance), so we render nothing rather than something misleading.
///
/// Unlimited rules:
///  - Plan-marked unlimited (any contributing `bucket.unlimited` wins).
///  - Effectively unlimited: API has remaining but no initial allowance
///    (e.g. promotional buckets like "whatsapp full").
List<PlanBucketUsage> computePlanBucketUsage({
  required List<BasePlanModel> activePlans,
  required List<BucketUsageItem> items,
  Set<String> excludePlanIds = const <String>{},
}) {
  if (activePlans.isEmpty || items.isEmpty) {
    return const <PlanBucketUsage>[];
  }

  final planIds = <String>{};
  for (final plan in activePlans) {
    if (plan.planId.isNotEmpty) planIds.add(plan.planId);
  }

  final planMeta = <String, _PlanBucketMeta>{};
  final orderedKeys = <String>[]; // preserve first-seen order for stable UI

  for (final plan in activePlans) {
    for (final bucket in plan.planBuckets) {
      // Unlimited buckets bypass suppress — `Suppress: True` paired with
      // `Unlimited: True` (e.g. roameasy's "ALIV to ALIV minutes/texts") is
      // a user-facing perk that should render even though the API marks it
      // suppressed for metered displays.
      if (bucket.suppress && !bucket.unlimited) continue;

      final key = _normalize(bucket.name);
      if (key.isEmpty) continue;

      final existing = planMeta[key];
      if (existing == null) {
        planMeta[key] = _PlanBucketMeta(
          displayName: bucket.name,
          bucketUnit: bucket.bucketUnit,
          unitFromPlan: bucket.unit,
          isUnlimited: bucket.unlimited,
        );
        orderedKeys.add(key);
      } else if (bucket.unlimited) {
        existing.isUnlimited = true;
      }
    }
  }

  if (planMeta.isEmpty) {
    return const <PlanBucketUsage>[];
  }

  final result = <PlanBucketUsage>[];
  for (final key in orderedKeys) {
    final meta = planMeta[key]!;
    final matchedItem = _findItemForBucketName(items, key);
    if (matchedItem == null) {
      // Unlimited buckets render from plan-side info only (no numbers
      // needed), so a missing API item is fine. Metered buckets still
      // need the API row — without it we'd show stale plan-side numbers.
      if (meta.isUnlimited) {
        result.add(_unlimitedRow(
          meta.displayName,
          meta.bucketUnit,
          displayUnitLabel(meta.unitFromPlan),
        ));
      }
      continue;
    }

    final unitType = matchedItem.unitType.isNotEmpty
        ? matchedItem.unitType
        : meta.unitFromPlan;
    final unitLabel = displayUnitLabel(unitType);

    if (meta.isUnlimited) {
      result.add(_unlimitedRow(meta.displayName, meta.bucketUnit, unitLabel));
      continue;
    }

    double rawRemaining = 0;
    int matchedDetailCount = 0;
    double excludedContribution = 0;
    for (final detail in matchedItem.nestedDetails) {
      final detailPlanId = _planIdOf(detail.purchaseSeq);
      if (excludePlanIds.contains(detailPlanId)) {
        // Strip excluded plans' nested-detail contribution from initial so
        // the row reflects only the requested plan subset's entitlement.
        // Exact when the excluded plans are 0% used; under-counts the
        // primary initial slightly when they have consumed some allowance.
        excludedContribution += detail.currentAmount;
        continue;
      }
      if (planIds.contains(detailPlanId)) {
        rawRemaining += detail.currentAmount;
        matchedDetailCount++;
      }
    }
    final adjustedInitialRaw =
        matchedItem.totalInitialAmount - excludedContribution;
    final initial = toDisplayUnit(adjustedInitialRaw, unitType);
    final remaining = toDisplayUnit(rawRemaining, unitType);

    // Effectively unlimited: API reports a balance but no initial allowance
    // (e.g. promotional bucket like "whatsapp full").
    if (initial <= 0 && remaining > 0) {
      result.add(_unlimitedRow(meta.displayName, meta.bucketUnit, unitLabel));
      continue;
    }

    final used = (initial - remaining).clamp(0.0, double.infinity);
    final progress = initial > 0 ? (used / initial).clamp(0.0, 1.0) : 0.0;

    result.add(
      PlanBucketUsage(
        bucketName: meta.displayName,
        bucketUnit: meta.bucketUnit,
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

PlanBucketUsage _unlimitedRow(String name, String bucketUnit, String unitLabel) {
  return PlanBucketUsage(
    bucketName: name,
    bucketUnit: bucketUnit,
    unitLabel: unitLabel,
    isUnlimited: true,
    initial: 0,
    remaining: 0,
    used: 0,
    progress: 0,
    matchedDetailCount: 0,
  );
}

class _PlanBucketMeta {
  _PlanBucketMeta({
    required this.displayName,
    required this.bucketUnit,
    required this.unitFromPlan,
    required this.isUnlimited,
  });

  final String displayName;
  final String bucketUnit;
  final String unitFromPlan;
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
