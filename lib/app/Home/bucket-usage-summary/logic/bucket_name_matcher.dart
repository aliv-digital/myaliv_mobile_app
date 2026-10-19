/// Tiered matcher that joins plan bucket names to API
/// `BucketUsageItem.freeUnitTypeName`.
///
/// The API often prefixes regions onto bucket names (e.g.
/// `"US/Can/UK roaming data"` for the plan-side bucket `"roaming data"`),
/// so strict equality alone produces empty Usage rows whenever marketing
/// renames a row. Three tiers run in priority order; exact match always
/// wins. The looser tiers are gated behind a word-boundary check so a
/// plan bucket called `"data"` does not silently swallow an API row
/// called `"metadata"`.
enum BucketMatchTier {
  /// `normalized(api) == normalized(bucket)`.
  exact,

  /// All plan-bucket tokens are present in the API row's token set,
  /// after splitting on whitespace / `/` / `-`.
  tokenSubset,

  /// Like [tokenSubset], but each plan token is allowed to match an API
  /// token via a prefix relation (either side a prefix of the other),
  /// gated by [_prefixMatchMinLength] and the [_prefixMatchDenylist].
  /// Catches abbreviated/stemmed forms such as plan `"roaming"` ↔ API
  /// `"roam"` without admitting `"data"` ↔ `"database"`.
  tokenPrefix,

  /// `\b<bucket>\b` whole-word substring of the API name. Last resort
  /// for names that aren't cleanly tokenizable.
  wordBoundary,

  /// No tier matched. Never appears on a returned [BucketNameMatch].
  none,
}

/// One scored candidate from [findBestMatch].
class BucketNameMatch {
  const BucketNameMatch({
    required this.itemIndex,
    required this.tier,
    required this.extraTokenCount,
    required this.apiNameLength,
  });

  /// Index into the `items` list passed to [findBestMatch].
  final int itemIndex;

  /// Which tier produced this candidate.
  final BucketMatchTier tier;

  /// `apiTokens.length - bucketTokens.length` when tier is
  /// [BucketMatchTier.tokenSubset] or [BucketMatchTier.tokenPrefix];
  /// zero otherwise. Lower = more specific match for the bucket.
  final int extraTokenCount;

  /// Normalized API name length. Used as a deterministic tiebreaker
  /// between same-tier, same-extraTokenCount candidates.
  final int apiNameLength;
}

/// `s.trim().toLowerCase()`. Public so the calculator and tests share
/// one normalization rule instead of redeclaring it.
String normalizeBucketName(String s) => s.trim().toLowerCase();

/// Splits on whitespace, `/`, and `-`; drops empty tokens. These
/// separators cover the common roaming bucket name shapes
/// (`"US/Can/UK roaming data"`, `"post-paid voice"`). Returns a set
/// because the subset check is order-independent.
Set<String> tokenizeBucketName(String normalized) {
  if (normalized.isEmpty) return const <String>{};
  return normalized
      .split(RegExp(r'[\s/\-]+'))
      .where((t) => t.isNotEmpty)
      .toSet();
}

/// Minimum length on BOTH sides for a prefix relation to count as a
/// match. Prevents `"sms"` from prefix-matching `"smsc"` and the
/// symmetric short-token noise. Tuned to 4 so `"roam"` (4) still
/// prefix-matches `"roaming"` — the headline reason this tier exists.
const int _prefixMatchMinLength = 4;

/// Tokens that are short enough to look like a legitimate prefix-match
/// candidate but mean something completely different. The prefix tier
/// rejects any match involving an entry on this list — e.g. plan
/// `"data"` will not silently swallow API `"database"`.
///
/// Keep this list tight. An open-ended denylist re-introduces exactly
/// the "every rename needs a code change" problem the tolerant matcher
/// is trying to escape. Add entries only when QA reports a concrete
/// false-positive in production.
const Set<String> _prefixMatchDenylist = <String>{'database'};

bool _tokenPrefixMatches(String planToken, String apiToken) {
  if (_prefixMatchDenylist.contains(planToken)) return false;
  if (_prefixMatchDenylist.contains(apiToken)) return false;
  if (planToken == apiToken) return true;
  if (planToken.length < _prefixMatchMinLength) return false;
  if (apiToken.length < _prefixMatchMinLength) return false;
  return planToken.startsWith(apiToken) || apiToken.startsWith(planToken);
}

bool _isTokenPrefixSubset(Set<String> planTokens, Set<String> apiTokens) {
  if (planTokens.isEmpty) return false;
  for (final pt in planTokens) {
    bool found = false;
    for (final at in apiTokens) {
      if (_tokenPrefixMatches(pt, at)) {
        found = true;
        break;
      }
    }
    if (!found) return false;
  }
  return true;
}

/// Finds the best unclaimed item matching [bucketNormalized] under
/// [allowTiers].
///
/// [apiNormalized] and [apiTokens] are pre-computed parallel to the
/// items list — the calculator computes them once and passes them in to
/// keep per-bucket lookups cheap.
///
/// Within the allowed tiers, candidates are ranked by
/// `(tier index, extraTokenCount, apiNameLength, itemIndex)` — all
/// ascending. Exact matches short-circuit since no later candidate can
/// beat them.
BucketNameMatch? findBestMatch({
  required String bucketNormalized,
  required Set<String> bucketTokens,
  required List<String> apiNormalized,
  required List<Set<String>> apiTokens,
  required Set<int> claimedIndices,
  required Set<BucketMatchTier> allowTiers,
}) {
  if (bucketNormalized.isEmpty) return null;
  if (allowTiers.isEmpty) return null;

  final allowExact = allowTiers.contains(BucketMatchTier.exact);
  final allowSubset = allowTiers.contains(BucketMatchTier.tokenSubset);
  final allowPrefix = allowTiers.contains(BucketMatchTier.tokenPrefix);
  final allowBoundary = allowTiers.contains(BucketMatchTier.wordBoundary);
  final RegExp? boundary = allowBoundary
      ? RegExp(r'\b' + RegExp.escape(bucketNormalized) + r'\b')
      : null;

  BucketNameMatch? best;
  for (int i = 0; i < apiNormalized.length; i++) {
    if (claimedIndices.contains(i)) continue;
    final apiName = apiNormalized[i];
    if (apiName.isEmpty) continue;

    BucketMatchTier tier = BucketMatchTier.none;
    int extra = 0;

    if (allowExact && apiName == bucketNormalized) {
      tier = BucketMatchTier.exact;
    } else if (allowSubset &&
        bucketTokens.isNotEmpty &&
        bucketTokens.every(apiTokens[i].contains)) {
      tier = BucketMatchTier.tokenSubset;
      extra = apiTokens[i].length - bucketTokens.length;
    } else if (allowPrefix &&
        bucketTokens.isNotEmpty &&
        _isTokenPrefixSubset(bucketTokens, apiTokens[i])) {
      tier = BucketMatchTier.tokenPrefix;
      extra = apiTokens[i].length - bucketTokens.length;
    } else if (allowBoundary && boundary!.hasMatch(apiName)) {
      tier = BucketMatchTier.wordBoundary;
    }

    if (tier == BucketMatchTier.none) continue;

    final candidate = BucketNameMatch(
      itemIndex: i,
      tier: tier,
      extraTokenCount: extra,
      apiNameLength: apiName.length,
    );

    if (best == null || _isBetter(candidate, best)) {
      best = candidate;
      // Exact short-circuits — no later candidate can beat tier index 0
      // with extraTokenCount 0.
      if (tier == BucketMatchTier.exact) return best;
    }
  }
  return best;
}

bool _isBetter(BucketNameMatch a, BucketNameMatch b) {
  if (a.tier.index != b.tier.index) return a.tier.index < b.tier.index;
  if (a.extraTokenCount != b.extraTokenCount) {
    return a.extraTokenCount < b.extraTokenCount;
  }
  if (a.apiNameLength != b.apiNameLength) {
    return a.apiNameLength < b.apiNameLength;
  }
  return a.itemIndex < b.itemIndex;
}
