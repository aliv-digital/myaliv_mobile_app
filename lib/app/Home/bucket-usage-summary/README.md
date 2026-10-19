# Bucket Usage Summary — Dev Guide

End-to-end doc for the "active plan usage remaining" feature: how the
data is fetched, joined against the user's active plans, transformed
into display values, and surfaced on the home screen + bucket detail
modal. Read this before changing any of the files under
`lib/app/Home/bucket-usage-summary/` or its consumers in
`lib/app/Home/widgets/`.

---

## 1. What the feature does

For an authenticated subscriber, render their current allowances for
data / minutes / texts / roaming buckets across all active plans.
Surfaces:

- **Home → "active plan usage remaining"** — horizontal cards for the
  primary/secondary plan group, plus a "your active plans" expander
  listing every active plan (primary, add-on, stand-alone roaming).
- **Bucket detail modal** — opens on tap of a usage card; shows raw API
  totals, per-instance expiry rows, and the same active-plans expander
  (collapsed by default).
- **`roamingPlanBucketUsage`** — stand-alone (roameasy/travel20) view
  stored on state for future surfaces (Usage tab, dedicated roaming
  page) without recomputation.

---

## 2. The data: two API surfaces, joined

### 2.1 Plans (from `PlansCubit`)

The bundles API returns three plan groups:

| API field | Meaning | Badge | Drives |
|---|---|---|---|
| `PrimaryPlans` | Primary subscriptions (liberty40, freedom5, …) | Primary | Home cards |
| `SecondaryPlans` | Add-on / bolt-on plans (liberty data1, …) | Add-ons | Home cards |
| `StandAlonePlans` | Roaming / travel plans (roameasy, travel20) | Roaming plan | Roaming view (future) |

`PlansState` exposes them separately *and* via two derived getters:

- **`activePlansForBucketUsage`** — Primary ∪ Secondary, deduped by
  `planId` (first-wins). This is the set whose buckets drive the home
  usage cards.
- **`standAlonePlansForBucketUsage`** — StandAlone deduped by `planId`
  (first-wins). The bundles API can echo the same stand-alone plan
  twice (one row per active purchase); the API-side
  `BucketUsageItem.totalInitialAmount` already aggregates across both
  purchases, so we count the plan once.

### 2.2 Bucket usage summary (from `BucketUsageSummaryCubit`)

Endpoint returns a flat list of `BucketUsageItem`, one per bucket name
(`FreeUnitTypeName`). Each item carries:

- `totalInitialAmount` — global initial allowance across *all*
  contributing plans (the API already sums these).
- `totalUnusedAmount` / `totalAmountUsed` — current remaining / used.
- `nestedDetails` — per-instance rows with `currentAmount`,
  `expireTime`, and `purchaseSeq`. The first dot-segment of
  `purchaseSeq` is the `planId` that contributed that instance
  (e.g. `"29916.20260520153737.000.20260520153749"` → `29916`).
- `unitType` — `"GB"`, `"Minutes"`, `"Text"`, etc.

### 2.3 The join

`BucketUsageSummaryCubit.loadBucketUsageSummary(...)` is called from the
home screen with both plan groups. It stores the API response plus the
two plan lists on `BucketUsageSummaryState`. Two pure-function getters
on the state derive the view-models:

- `activePlanBucketUsage` — primary/secondary view (stand-alone
  subtracted).
- `roamingPlanBucketUsage` — stand-alone view (primary/secondary
  subtracted).

Both delegate to `computePlanBucketUsage(...)` in
`logic/plan_bucket_usage_calculator.dart`.

---

## 3. Business rules (the part where bugs live)

### 3.1 Which buckets render and in what order

- Source of bucket *names* is the **plan declarations**, not the API.
  Walk `plan.planBuckets` across the active set, dedup by normalized
  bucket `name`, skip rows where `Suppress=True` (internal-only buckets
  like roameasy's `ALIV to ALIV minutes`). Order = first-seen across
  plans, so the user sees the headline buckets from their primary plan
  first.
- A plan-declared bucket that is **missing from the API response** is
  skipped (not zero-rendered). The API is authoritative on
  provisioned/unprovisioned state.

### 3.2 Numbers per row

For each rendered bucket name:

1. Look up the matching `BucketUsageItem` by case-insensitive
   `freeUnitTypeName` equality.
2. `initial` ← API's `totalInitialAmount`, **minus** the sum of
   `currentAmount` for nested-detail entries whose `planId` is in
   `excludePlanIds`.
3. `remaining` ← sum of `currentAmount` for nested-detail entries
   whose `planId` is in the active set.
4. Both values converted to display units via
   `bucket_unit_converter.dart`:
   - `GB` → divide raw by `1024 × 1024`
   - `Minutes` / `mins` / `min` → divide raw by `60`
   - Anything else → pass through.
5. `used = max(0, initial − remaining)`, `progress = used / initial`.

> **Why subtract from initial?** The API-side `totalInitialAmount` is a
> global aggregate that includes contributions from every plan that
> touches the bucket. When rendering only one plan group, we want
> initial and remaining to be consistent with each other. Subtracting
> the excluded group's `currentAmount` from `totalInitialAmount` is
> exact while the excluded group is 0% consumed and slightly
> under-states our group's initial as the excluded group spends down.
> The API doesn't expose per-instance initial, so this is the closest
> consistent signal.

### 3.3 Unlimited rules

A row renders as the text `"unlimited"` (skipping numeric computation)
when **either**:

- **Plan-marked unlimited** — any contributing plan declares
  `bucket.unlimited = true`. Once true, later non-unlimited
  declarations of the same bucket name don't flip it back. Wins over
  finite same-name buckets from other plans (e.g. liberty40's unlimited
  `minutes` wins over roameasy's finite 20 min `minutes`).
- **Effectively unlimited** — `initial <= 0` but `remaining > 0` after
  subtraction. Catches promotional buckets like `whatsapp full` where
  the API has a balance but no recorded entitlement.

### 3.4 Stand-alone dedup

If the API returns the same stand-alone plan twice (one per active
purchase), the dedup in `standAlonePlansForBucketUsage` keeps the
**first occurrence**. The API has already aggregated the two purchases
into `totalInitialAmount`, so counting the plan twice in `planIds`
would have no effect; the dedup is for display lists.

---

## 4. The view-model: `PlanBucketUsage`

```dart
PlanBucketUsage(
  bucketName,      // display name as declared by the plan
  unitLabel,       // "GB", "mins", "Text", ...
  isUnlimited,     // see §3.3
  initial,         // display unit
  remaining,       // display unit
  used,            // display unit
  progress,        // 0.0..1.0
  matchedDetailCount,  // diagnostic: how many nestedDetails contributed
);
```

This is what every UI widget consumes. UI never reaches for raw
`BucketUsageItem` numbers (except the detail modal, which intentionally
shows raw values — see §6.3).

---

## 5. File map

```
lib/app/Home/bucket-usage-summary/
├── cubit/
│   ├── bucket_usage_summary_cubit.dart   # fetch + plan sync
│   └── bucket_usage_summary_state.dart   # state + derived getters
├── logic/                                 # pure functions, no Flutter
│   ├── bucket_unit_converter.dart        # raw → display units
│   ├── plan_bucket_usage.dart            # PlanBucketUsage view-model
│   └── plan_bucket_usage_calculator.dart # the join algorithm
├── models/
│   └── bucket_usage_summary_model.dart   # API parsing + display getters
├── repository/
│   └── bucket_usage_summary_repository.dart  # API client wrapper
├── view/
│   └── bucket_usage_view_helpers.dart    # icon/color/format helpers
└── README.md (this file)

lib/app/Home/widgets/
├── active_plan_usage_section.dart        # section on the home screen
├── active_plans_expander.dart            # reusable "your active plans"
├── bucket_detail_modal.dart              # tap-card modal
├── usage_card.dart                       # one horizontal card
└── roaming_card.dart                     # full-width roaming row
```

---

## 6. Implementation, step by step

### 6.1 Step 1 — Parse the API safely

`BucketUsageItem.fromJson` is defensive: missing fields → 0 /
empty-string; `NestedDetail` skipped if not a `Map`. Expiry strings
("2026-06-01 18:55:50") are pre-parsed into `expireDateTime` so the UI
can sort/format without re-parsing on rebuilds.

Display getters on the item do all unit conversion in one place:

```dart
item.displayInitialAmount  // raw / (1024*1024) for GB, raw / 60 for mins
item.displayUsedAmount
item.displayUnusedAmount
item.displayUnitLabelText  // "GB" / "mins" / passthrough
```

### 6.2 Step 2 — `computePlanBucketUsage`

Pure function in `logic/plan_bucket_usage_calculator.dart`. Signature:

```dart
List<PlanBucketUsage> computePlanBucketUsage({
  required List<BasePlanModel> activePlans,
  required List<BucketUsageItem> items,
  Set<String> excludePlanIds = const <String>{},
});
```

Algorithm in plain English:

1. Bail out if either input is empty.
2. Collect active `planId`s from `activePlans`.
3. Walk `plan.planBuckets` across `activePlans`. For each non-suppressed
   bucket, register an entry in `planMeta` keyed by normalized name.
   First-seen wins for display name + unit; `isUnlimited` is OR-ed
   across plans (true sticks).
4. For each entry in `planMeta` (in first-seen order):
   - Look up the matching `BucketUsageItem` by `freeUnitTypeName`.
   - Skip if no match.
   - If unlimited, push an `_unlimitedRow` and continue.
   - Otherwise walk `nestedDetails`: for each detail, classify by
     `_planIdOf(detail.purchaseSeq)`:
     - In `excludePlanIds` → accumulate into `excludedContribution`.
     - In `planIds` → accumulate into `rawRemaining`,
       increment `matchedDetailCount`.
     - Otherwise → ignored.
   - `adjustedInitialRaw = totalInitialAmount − excludedContribution`.
   - Convert both to display units; check the effectively-unlimited
     rule; otherwise compute `used` / `progress` and push a
     `PlanBucketUsage`.

Tested in `test/app/Home/bucket-usage-summary/logic/plan_bucket_usage_calculator_test.dart` (34 cases covering empty inputs,
multi-plan aggregation, unit conversion, unlimited rules,
suppress/dedup, malformed `purchaseSeq`).

### 6.3 Step 3 — State / Cubit

`BucketUsageSummaryState` holds:

```dart
status, summary, errorMessage, lastFetchedAt, deviceAccountId,
activePlans,       // primary ∪ secondary (deduped)
standAlonePlans,   // stand-alone (deduped)
```

Derived getters:

```dart
activePlanBucketUsage  // primary view (exclude = standAlonePlanIds)
roamingPlanBucketUsage // stand-alone view (exclude = activePlanIds)
```

Both call `computePlanBucketUsage` with opposite `excludePlanIds`, so
each plan group's row is a pure projection of its own slice.

`BucketUsageSummaryCubit.loadBucketUsageSummary(...)` is the single
entry point. It:

1. No-ops if `deviceAccountId <= 0`.
2. If already loading, just adopts the latest plan references.
3. If cache is valid for the same device, ditto.
4. Otherwise fetches, then emits `loaded` with both plan lists.

`updateActivePlans(activePlans, {standAlonePlans})` is the cheap path
when only the plan refs change (e.g. `PlansCubit` re-emits without a
usage re-fetch).

### 6.4 Step 4 — Home wiring

`home_screen.dart` calls `loadBucketUsageSummary` after login and listens
to `PlansCubit` changes to push the latest plan groups into the bucket
cubit:

```dart
final plansState = context.read<PlansCubit>().state;
context.read<BucketUsageSummaryCubit>().loadBucketUsageSummary(
  deviceAccountId: accountInfo.idAcc,
  activePlans: plansState.activePlansForBucketUsage,
  standAlonePlans: plansState.standAlonePlansForBucketUsage,
);
```

The `listenWhen` on the `BlocListener<PlansCubit, PlansState>` fires on
`addOnsApiPrimaryPlans` / `secondaryPlans` / `standAlonePlans` changes
(not just primary, since secondary/stand-alone now drive surfaces too).

### 6.5 Step 5 — `active_plan_usage_section.dart`

Lays out the section vertically:

1. Header row + "view all" navigates to `AppRoutes.usage`.
2. `_planNameHeader` — current plan name (lowercased) from
   `state.activePlans.first.planName`.
3. Horizontal usage cards driven by `state.activePlanBucketUsage`.
   Postpaid retains the mocked card row pending real postpaid data.
4. `ActivePlansExpander()` — initially expanded on home.

Each `UsageCard` is wrapped in an `InkWell` (via the optional `onTap`
prop) that calls `BucketDetailModal.show(context, usage.bucketName)`.

### 6.6 Step 6 — `ActivePlansExpander`

Reusable widget (`StatefulWidget` for the open/closed toggle).

- White card on a tinted page background (so it stands out without a
  shadow).
- Each row: plan name + badge (Primary mint / Add-ons gray / Roaming
  plan gray) + `expires on: <day, month date, year time>`.
- Date format: `DateFormat('EEEE, MMMM d, yyyy h:mm a').format(date).toLowerCase()`.
- Dedup by `planId` (first-wins) when flattening Primary → Add-on →
  Roaming so duplicate API entries collapse to one row.
- `initiallyExpanded` toggles default state — home passes `true`, modal
  passes `false`.

### 6.7 Step 7 — `BucketDetailModal`

Bottom sheet (`DraggableScrollableSheet`, 50–95% height range).
Reused tint `#F1F7FA` on the sheet so the inner white cards pop the
same way the home section does.

Contents top to bottom:

1. Title (`bucketName.toLowerCase()`) + circular close `×`.
2. **details** card — `total | used` row + `remaining` full-width row,
   read from `item.displayInitial/Used/UnusedAmount`.
3. **expire dates** card — one line per `NestedDetail`, sorted by
   `expireDateTime` ascending, formatted as
   `"<currentAmount> <unit> expires <date>"`. Uses
   `toDisplayUnit(detail.currentAmount, item.unitType)` for the
   per-instance amount.
4. `ActivePlansExpander(initiallyExpanded: false)` — same widget as on
   home, collapsed.
5. Left-aligned `fair use policy` link — taps
   `launchUrl('https://www.bealiv.com/fair-use-policy/',
   LaunchMode.externalApplication)` and falls back to
   `AppToast.show(message: 'could not open fair use policy', ...)` on
   failure (same handler as `HomePlanAddOnsTabContent`).
6. Full-width purple close button.

> The modal intentionally shows **raw API totals** (no plan-group
> subtraction). Rationale: the modal is the "see everything about this
> bucket" surface — including standalone contributions to a shared
> bucket name like `data`. So the home card may show 6.00 GB while the
> modal shows 6.40 GB; the 0.40 GB delta is the roameasy local-data
> contribution.

---

## 7. Worked example (the canonical sample data)

Plans:

- Primary: liberty40 (29916), freedom5 (29836)
- Secondary: liberty talk100 (7653), liberty data1 (6813)
- Stand-alone: roameasy usa & can (29214, × 2 purchases)

`activePlanIds = {29916, 29836, 7653, 6813}` (Primary ∪ Secondary,
deduped).
`standAlonePlanIds = {29214}` (first wins of the two echoed rows).

`activePlanBucketUsage` (home cards) — the `data` row:

```
TotalInitialAmount  = 6,710,884 KB     (API global aggregate)
excluded (29214)    = 4 × 104,857      (roameasy local Bahamas data)
adjustedInitial     = 6,291,456 KB     → 6.00 GB
remaining           = 6,291,456 KB     → 6.00 GB
```

`roamingPlanBucketUsage` (stored, not on home) — same `data` row:

```
TotalInitialAmount  = 6,710,884 KB
excluded (29916)    = 6,291,456 KB
adjustedInitial     = 419,428 KB       → 0.40 GB
remaining           = 419,428 KB       → 0.40 GB
```

`minutes` row in the home cards short-circuits to `"unlimited"` because
liberty40 declares it unlimited — the numeric path is skipped entirely,
so 29214's 20-min finite contribution doesn't surface here. The same
bucket in `roamingPlanBucketUsage` *does* render as a finite row
(roameasy is the only contributor in that view).

---

## 8. Edge cases the code already handles

- **Empty inputs** — calculator returns `[]`; UI renders
  `SizedBox.shrink()`.
- **Plan-declared but API-missing bucket** — skipped.
- **All-suppressed bucket** — skipped (every plan-row was filtered out
  before reaching `planMeta`).
- **Bucket name casing/whitespace drift** between plan and API —
  matched via `_normalize(name)` (trim + toLowerCase).
- **Malformed `purchaseSeq`** (no dot) — `_planIdOf` returns the whole
  string; matches when full string equals a `planId`, otherwise no-op.
- **`remaining > initial`** (data anomaly) — `used` clamped to ≥ 0,
  `progress` clamped to [0, 1].
- **Duplicate stand-alone plans** — deduped by `planId` on the way into
  the calculator.

---

## 9. Known caveats / future work

- The subtraction in §3.2 assumes the excluded group is 0%-consumed.
  Once a stand-alone plan starts spending against a shared bucket, the
  primary's `initial` will under-state by exactly the consumed amount.
  Resolving this requires either:
  - The API returning per-instance initial alongside `currentAmount`,
    or
  - Switching the source of `initial` to summed plan-side
    `bucket.amount`, accepting the future-plan + bolt-on attribution
    issues that comes with.
- `roamingPlanBucketUsage` is computed and stored but no surface
  renders it yet (Usage tab's roaming section is still hardcoded).
- The bucket detail modal's per-instance amount column displays
  `currentAmount` (the *remaining* per instance). When the user spends
  down an instance, that column shrinks rather than reflecting the
  originally provisioned amount. Same root cause as the subtraction
  caveat — the API does not expose per-instance initial.

---

## 10. Tests

`test/app/Home/bucket-usage-summary/` covers:

- `logic/bucket_unit_converter_test.dart` — 11 cases (unit
  conversions, aliases, unknown passthrough).
- `models/bucket_usage_summary_model_test.dart` — 6 cases (display
  getters, ratio invariance).
- `logic/plan_bucket_usage_calculator_test.dart` — 34 cases (empty
  inputs, multi-plan aggregation, unit conversion, unlimited rules,
  suppress/dedup, malformed `purchaseSeq`, math safety).

When adding new business rules, mirror them in
`plan_bucket_usage_calculator_test.dart` — that's the test most likely
to catch regressions because the join is where most of the complexity
lives.
