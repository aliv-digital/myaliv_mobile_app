# Plan-aware candidate filter — worked example (travel30, planId `18933`)

Companion to `README.md` §3 and `logic/plan_bucket_usage_calculator.dart:128-144`.
Explains *why* the pre-claim step at lines 137-144 of the calculator exists,
with the canonical bug it was added to fix.

---

## 1. The problem in one sentence

The user has a travel30 roaming plan declaring a `"roaming data"` bucket, but
the API row literally named `"roaming data"` belongs to a **different** plan.
The travel30 user's actual entitlement is in an API row named
`"US/Can/UK roaming data"`. Without the plan-aware filter the Usage card
would silently claim the wrong row and show wrong (or zero) numbers.

---

## 2. The inputs

### 2.1 Active plan (caller passes this to `bucketUsageForPlan(plan)`)

```dart
BasePlanModel(
  planId: '18933',                    // travel30
  planName: 'travel30',
  planBuckets: [
    PlanBucket(
      name: 'roaming data',           // ← the bucket the user sees on the card
      bucketUnit: 'INS_Data_roam_US_Canada',
      unit: 'GB',
      amount: 3,                      // plan-side declared 3 GB (unreliable)
      unlimited: false,
      suppress: false,
    ),
    // ...other buckets (roaming minutes, roaming texts, etc.)
  ],
);
```

### 2.2 API bucket-usage summary (`List<BucketUsageItem>`)

Trimmed to the two rows that matter for this case:

```jsonc
[
  {
    "FreeUnitTypeName": "roaming data",          // ← name-twin
    "TotalInitialAmount": 3145728,               // raw KB (= 3 GB)
    "UnitType": "GB",
    "NestedDetail": [
      {
        // PurchaseSeq prefix is the contributing planId
        "PurchaseSeq": "29911.20260301120000.001.20260401120000",
        "CurrentAmount": 3145728                 // 3 GB remaining, belongs to plan 29911
      }
    ]
  },
  {
    "FreeUnitTypeName": "US/Can/UK roaming data", // ← travel30's real row
    "TotalInitialAmount": 3145728,                // 3 GB
    "UnitType": "GB",
    "NestedDetail": [
      {
        "PurchaseSeq": "18933.20260620153737.000.20260720153749",
        "CurrentAmount": 2097152                  // 2 GB remaining, belongs to travel30 (18933)
      }
    ]
  }
]
```

Key fact: every `NestedDetail` carries a `PurchaseSeq` whose **first
dot-segment is the planId that contributed that instance**.
`_planIdOf("18933.20260620…")` returns `"18933"` (calculator
`:307-312`).

---

## 3. What would happen *without* the plan-aware filter

The matcher runs Pass 1 (exact) walking `orderedKeys` in plan-declared order
(calculator `:146-159`). For `"roaming data"`:

1. Tier A (exact) finds index `0` — API row `"roaming data"` — and claims it.
2. travel30's bucket is now bound to the **wrong** API row.
3. In the numeric pass (`:226-240`), the calculator iterates that row's
   `nestedDetails`:
   - Only detail has `planId = 29911`.
   - `29911` is **not** in `planIds = {18933}`, so `rawRemaining` stays `0`.
   - `29911` is **not** in `excludePlanIds` either (it's the *current* plan's
     siblings that are excluded, not random unrelated plans), so
     `excludedContribution` stays `0`.
4. Result: `initial = 3 GB`, `remaining = 0 GB`, `used = 3 GB`, progress full.
5. Meanwhile the *real* travel30 row `"US/Can/UK roaming data"` is never
   matched — no other plan bucket name resolves to it — so the user sees a
   completely fabricated "you've used all 3 GB" reading.

Visible bug: the Usage card for travel30 shows "0 GB of 3 GB remaining"
even though the API plainly says the user has 2 GB left.

---

## 4. What actually happens *with* the filter

`computePlanBucketUsage` runs the pre-claim block at lines `137-144`:

```dart
if (planIds.isNotEmpty) {                       // planIds = {'18933'}
  for (int i = 0; i < items.length; i++) {
    final hasContribution = items[i].nestedDetails.any(
      (d) => planIds.contains(_planIdOf(d.purchaseSeq)),
    );
    if (!hasContribution) claimed.add(i);       // mark item as off-limits
  }
}
```

Walking the two API items:

| i | `freeUnitTypeName`         | details' planIds | contains `18933`? | action |
|---|-----------------------------|------------------|--------------------|---|
| 0 | `roaming data`              | `{29911}`        | no                 | `claimed.add(0)` |
| 1 | `US/Can/UK roaming data`    | `{18933}`        | yes                | left available |

Now the matcher runs:

**Pass 1 (exact, calculator `:146-159`)**
- `"roaming data"` → tries index 0; `claimed.contains(0)` is true, skipped
  (`bucket_name_matcher.dart:148`). No exact match elsewhere.

**Pass 2 (fuzzy, calculator `:175-192`)**
- `"roaming data"` is reconsidered with Tiers B/C/D allowed.
- Index 1 (`"us/can/uk roaming data"`) — normalize +
  tokenize → `{us, can, uk, roaming, data}`.
- Plan tokens `{roaming, data}` ⊆ `{us, can, uk, roaming, data}` →
  **Tier B (tokenSubset)** match (matcher `:157-161`).
- `extraTokenCount = 5 - 2 = 3` — fine, it's the only candidate.
- Match recorded; index 1 added to `claimed`.

**Numeric pass (calculator `:223-254`)**
On the matched item (index 1):

```
totalInitialAmount   = 3,145,728 KB
nestedDetails        = [{ planId: 18933, currentAmount: 2,097,152 }]

excludedContribution = 0                  (18933 not in excludePlanIds for this call)
rawRemaining         = 2,097,152          (18933 ∈ planIds → accumulate)
matchedDetailCount   = 1

adjustedInitialRaw   = 3,145,728 − 0 = 3,145,728
initial              = toDisplayUnit(3,145,728, "GB") = 3.00 GB
remaining            = toDisplayUnit(2,097,152, "GB") = 2.00 GB
used                 = max(3.00 − 2.00, 0)            = 1.00 GB
progress             = 1.00 / 3.00                    ≈ 0.333
```

Resulting `PlanBucketUsage`:

```dart
PlanBucketUsage(
  bucketName: 'roaming data',           // displayed as-declared by the plan
  bucketUnit: 'INS_Data_roam_US_Canada',
  unitLabel: 'GB',
  isUnlimited: false,
  initial: 3.00,
  remaining: 2.00,
  used: 1.00,
  progress: 0.333,
  matchedDetailCount: 1,
);
```

The Usage card for travel30 now correctly renders
"2.00 GB of 3.00 GB remaining" with a ~33% progress bar.

---

## 5. Why this lives in the calculator (not the matcher)

The matcher (`logic/bucket_name_matcher.dart`) is intentionally
plan-agnostic — it operates purely on strings. Plan context (which planId
contributed which detail) is an orthogonal signal that the calculator owns,
so the pre-claim step is layered on top: filter the candidate pool first,
then let the string matcher run unmodified.

This keeps `bucket_name_matcher.dart` re-usable for surfaces that don't
have plan context (debug tools, future bulk views) without bending the
abstraction.

---

## 6. Failure modes the filter does **not** rescue

| Scenario | Outcome |
|---|---|
| API row has no `NestedDetail` entries at all | Item is pre-claimed → never matched → bucket renders nothing (unless plan-marked unlimited, which renders without numbers via `_unlimitedRow`). Same outcome as "no API row" — intentional per README §3.1. |
| Travel30's only matching API row is itself plan-twinned by a sibling (both `"roaming data"` rows contribute only to other plans) | Both are pre-claimed; no match found; bucket skipped. Correct behavior — the API genuinely has no entitlement for this plan. |
| `PurchaseSeq` malformed (no dot) | `_planIdOf` returns the whole string; matches when it equals `planId`, otherwise treated as "not this plan". Filter still safe. |

---

## 7. Related code & tests

- Calculator pre-claim: `lib/app/Home/bucket-usage-summary/logic/plan_bucket_usage_calculator.dart:128-144`
- `_planIdOf` parser: same file, `:307-312`
- Matcher tier definitions: `lib/app/Home/bucket-usage-summary/logic/bucket_name_matcher.dart:11-32`
- `claimedIndices` skip in matcher: `lib/app/Home/bucket-usage-summary/logic/bucket_name_matcher.dart:148`
- Usage screen consumer: `lib/app/Usage/widgets/roaming_plan_section.dart:49`
  (`state.bucketUsageForPlan(plans[i])`)
- State helper: `lib/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_state.dart:146-153`
- Tests: `test/app/Home/bucket-usage-summary/logic/plan_bucket_usage_calculator_test.dart`
  (add a regression case here if changing the pre-claim rule)