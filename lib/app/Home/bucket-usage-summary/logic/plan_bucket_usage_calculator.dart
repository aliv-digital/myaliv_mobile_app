import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/logic/bucket_name_matcher.dart';
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
/// Name-matching strategy (joining plan-bucket → API item):
///  - Two passes over a tiered matcher defined in `bucket_name_matcher.dart`:
///    Tier A `exact`, Tier B `tokenSubset`, Tier C `tokenPrefix`, Tier D
///    `wordBoundary`. Pass 1 resolves all Tier-A matches in plan order; pass
///    2 sorts the remaining keys by descending specificity (more plan tokens
///    first) and resolves the looser tiers. Each API item can be claimed by
///    at most one plan bucket per call, so a less-specific bucket can't
///    steal a more-specific bucket's item.
///  - Plan-aware candidate filter: when [activePlans] have plan ids, API
///    items whose `nestedDetails` contain zero entries from those ids are
///    pre-claimed and excluded from matching. Without this, a plan-side
///    name that exact-matches an API row whose details all belong to
///    sibling plans would steal the join — burying the active plan's real
///    entitlement in a same-family API row (e.g. travel30's "roaming data"
///    entitlement actually lives under "US/Can/UK roaming data") that
///    never gets matched. The filter only runs when [activePlans] declare
///    plan ids; otherwise all items remain candidates.
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

      final key = normalizeBucketName(bucket.name);
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

  // ─── two-pass bucket name resolution ─────────────────────────────────────
  //
  // Pass 1 (exact): walk orderedKeys in plan-declared order. Exact match
  // is 1:1 — two distinct keys can't both exact-match the same item — so
  // order is safe here.
  //
  // Pass 2 (tokenSubset → wordBoundary): a single item may satisfy
  // several plan buckets via the looser tiers, so resolving in plan-
  // declared order would let a less-specific bucket steal a more-
  // specific bucket's item (e.g. plan-side "data" claiming
  // "US/Can/UK roaming data" before plan-side "roaming data" gets a
  // chance). Sort the remaining keys by descending specificity so the
  // most-specific bucket claims first. Once claimed, an item is removed
  // from contention to prevent double-counting.
  final apiNormalized = items
      .map((it) => normalizeBucketName(it.freeUnitTypeName))
      .toList(growable: false);
  final apiTokens =
      apiNormalized.map(tokenizeBucketName).toList(growable: false);
  final bucketTokensByKey = <String, Set<String>>{
    for (final key in orderedKeys) key: tokenizeBucketName(key),
  };

  final matchedIndexByKey = <String, int>{};
  final claimed = <int>{};

  // Pre-claim items the active plans don't contribute to. Without this,
  // a plan-side bucket name that exact-matches an API row whose
  // `nestedDetails` are all from sibling plans (real-world example:
  // travel30's `"roaming data"` matching the API row `"roaming data"`
  // whose only detail comes from a different plan) would steal the
  // join — burying the active plan's real entitlement in a different
  // API row (e.g. `"US/Can/UK roaming data"`) that never gets matched.
  // Pre-claiming the empty items lets the tolerant tiers reach the
  // right row in pass 2.
  if (planIds.isNotEmpty) {
    for (int i = 0; i < items.length; i++) {
      final hasContribution = items[i].nestedDetails.any(
        (d) => planIds.contains(_planIdOf(d.purchaseSeq)),
      );
      if (!hasContribution) claimed.add(i);
    }
  }

  for (final key in orderedKeys) {
    final match = findBestMatch(
      bucketNormalized: key,
      bucketTokens: bucketTokensByKey[key]!,
      apiNormalized: apiNormalized,
      apiTokens: apiTokens,
      claimedIndices: claimed,
      allowTiers: const <BucketMatchTier>{BucketMatchTier.exact},
    );
    if (match != null) {
      matchedIndexByKey[key] = match.itemIndex;
      claimed.add(match.itemIndex);
    }
  }

  final orderIndex = <String, int>{
    for (int i = 0; i < orderedKeys.length; i++) orderedKeys[i]: i,
  };
  final fuzzyKeys = orderedKeys
      .where((k) => !matchedIndexByKey.containsKey(k))
      .toList()
    ..sort((a, b) {
      final at = bucketTokensByKey[a]!.length;
      final bt = bucketTokensByKey[b]!.length;
      if (at != bt) return bt.compareTo(at); // more tokens first
      if (a.length != b.length) return b.length.compareTo(a.length);
      return orderIndex[a]!.compareTo(orderIndex[b]!);
    });

  for (final key in fuzzyKeys) {
    final match = findBestMatch(
      bucketNormalized: key,
      bucketTokens: bucketTokensByKey[key]!,
      apiNormalized: apiNormalized,
      apiTokens: apiTokens,
      claimedIndices: claimed,
      allowTiers: const <BucketMatchTier>{
        BucketMatchTier.tokenSubset,
        BucketMatchTier.tokenPrefix,
        BucketMatchTier.wordBoundary,
      },
    );
    if (match != null) {
      matchedIndexByKey[key] = match.itemIndex;
      claimed.add(match.itemIndex);
    }
  }

  final result = <PlanBucketUsage>[];
  for (final key in orderedKeys) {
    final meta = planMeta[key]!;
    final matchedIndex = matchedIndexByKey[key];
    final matchedItem = matchedIndex != null ? items[matchedIndex] : null;
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
