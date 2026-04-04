# Plans Module README

Last updated: April 1, 2026

This document is the working context for the `lib/app/Plans` module.

If a future Codex session needs to work on plans, start here first.

## 1. What This Folder Contains

`lib/app/Plans` is not only one screen. It contains the full prepaid/postpaid plans purchase area and several downstream flows.

Main subfolders:

- `PlanScreen`
  - Main plans browsing module.
  - This is where most recent API integration work was done.
- `homePlanConfirmation`
  - Generic prepaid plan confirmation flow.
- `homeRoamingConfirmation`
  - Roaming-specific confirmation flow.
- `homePlansPaymentMethod`
  - Payment method selection flow.
- `homePlanPurchaseReceipt`
  - Purchase receipt flow.
- `purchasePlanAddOns`
  - Add-ons purchase UI reused by the Add-ons tab inside `PlanScreen`.

In short:

- `PlanScreen` = plan discovery and tab browsing.
- Confirmation/payment/receipt folders = downstream purchase journey screens.

## 2. Main Entry Flow

Primary entry file:

- `PlanScreen/view/plans_entry_screen.dart`

Current routing behavior:

- Prepaid users go to `PlanScreen/view/home_plan_screen.dart`
- Postpaid users go to `PlanScreen/view/postpaid_roaming_screen.dart`

So when working on the main prepaid tabbed plans experience, the real starting point is:

- `PlanScreen/view/home_plan_screen.dart`

## 3. Current Architecture Inside PlanScreen

`PlanScreen` is split into:

- `bloc`
- `repository`
- `models`
- `widgets`
- `view`
- `theme`
- `data`

The important architecture is:

- `home_plan_repository.dart`
  - Fetches or serves plan data.
  - Contains both the old mock/generic flow and the new API-backed tab flow.
- `home_plan_bloc.dart`
  - Handles tab changes, loading, sync requests, failure states, and toast side effects.
- `home_plan_state.dart`
  - Holds per-tab UI state and dedicated typed API lists.
- `home_plan_event.dart`
  - Contains both UI events and internal API sync events.
- `home_plan_plans_list.dart`
  - The main UI switch that decides which card list to render for each tab.

## 4. What We Changed In PlanScreen

The recent work was about migrating plan tabs from old mock/generic data into real API-backed flows, step by step.

We followed one repeated pattern:

1. Add a dedicated typed model for the tab.
2. Add repository filtering for that tab from the real `available-plans` API response.
3. Add a dedicated internal sync event.
4. Add dedicated state fields for that tab's typed list and sync timestamp.
5. Add bloc sync handling with auth loading, duplicate-call guards, and failure handling.
6. Connect the UI only after the data layer is stable.

This exact staged approach was used across the migrated tabs.

## 5. API Source And Auth Strategy

All migrated tabs use the same backend source:

- endpoint:
  - `GET {Api.getAllPlans}/{deviceAccountID}/available-plans`

Repository file:

- `PlanScreen/repository/home_plan_repository.dart`

Auth/context source used by bloc:

- `AppConstants.userName`
- `LocalStorage.getTicket()`
- `LocalStorage.getAccountInfoMap()`

The bloc reads those values through:

- `_readPlanApiAuthContext()`

That produces:

- `username`
- `password`
- `deviceAccountID`

The repository then sends the request with Basic Auth.

## 6. Shared API Pattern

### 6.1 Repository behavior

The new API-backed tabs do not hit separate endpoints per tab.

Instead:

1. `home_plan_repository.dart` fetches the full `available-plans` payload.
2. It decodes JSON in a background isolate using `compute(...)`.
3. It caches the full normalized payload in `_lastFetchedPlans`.
4. Each migrated tab filters from that cached full payload using strict business rules.
5. Each tab then parses the filtered rows into a dedicated typed model list.

Important shared repository helpers:

- `getPlans(...)`
- `_ensureFullPlansCacheLoaded(...)`
- `_filterStrictPlansFromFullCache(...)`
- `_filterStrictPlansFromFullCacheByPlanGroup(...)`

### 6.2 Bloc behavior

The bloc does not directly fetch typed plans inside `_loadByTab(...)`.

Instead, `_loadByTab(...)`:

- sets the selected tab to loading
- clears unrelated list state when needed
- routes the tab into an internal sync event

Then a dedicated handler completes the sync.

Examples:

- `_onDailyApiSyncRequested(...)`
- `_onWeeklyApiSyncRequested(...)`
- `_onMonthlyApiSyncRequested(...)`
- `_onRoamingApiSyncRequested(...)`
- `_onRoamEasyApiSyncRequested(...)`
- `_onMifiApiSyncRequested(...)`
- `_onLibertyGlobalApiSyncRequested(...)`

Each sync handler:

- reads auth context
- guards duplicate calls with an in-progress boolean
- calls the dedicated repository method
- updates `apiTabMeta`
- updates the typed list field in state
- updates the tab-specific `...ApiLastSyncedAt`
- emits failure toast text through `pendingToast` if needed

### 6.3 State behavior

`home_plan_state.dart` separates:

- generic UI data:
  - `plans`
  - `expandedPlanIds`
  - `addOns`
  - `selectedAddOnIds`
- per-tab UI status:
  - `dailyTabUiState`
  - `weeklyTabUiState`
  - `monthlyTabUiState`
  - `roamingTabUiState`
  - `roameasyTabUiState`
  - `addOnsTabUiState`
  - `mifiTabUiState`
  - `libertyGlobalTabUiState`
- typed API data:
  - `dailyApiPlans`
  - `weeklyApiPlans`
  - `monthlyApiPlans`
  - `roamingApiPlans`
  - `roamEasyApiPlans`
  - `mifiApiPlans`
  - `libertyGlobalApiPlans`
- sync metadata:
  - `apiTabMeta`
  - `dailyApiLastSyncedAt`
  - `weeklyApiLastSyncedAt`
  - `monthlyApiLastSyncedAt`
  - `roamingApiLastSyncedAt`
  - `roamEasyApiLastSyncedAt`
  - `mifiApiLastSyncedAt`
  - `libertyGlobalApiLastSyncedAt`

This split is intentional:

- old tabs can still use `plans`
- migrated tabs use typed API fields
- state remains explicit and easy to debug

## 7. Tab Status Summary

Current status of each main tab in `PlanScreen`:

| Tab | API Data Layer | UI Connected | Current Source in UI | Notes |
| --- | --- | --- | --- | --- |
| Daily | Yes | Yes | `state.dailyApiPlans` | API-backed card rendering is active |
| Weekly | Yes | Yes | `state.weeklyApiPlans` | API-backed card rendering is active |
| Monthly | Yes | Yes | `state.monthlyApiPlans` | API-backed card rendering is active |
| Roaming | Yes | Yes | `state.roamingApiPlans` | API-backed card rendering is active |
| RoamEasy | Yes | Yes | `state.roamEasyApiPlans` | API-backed card rendering is active |
| Add-ons | Separate flow | Yes | `state.addOns` | Uses `purchasePlanAddOns` UI pieces |
| MiFi | Yes | No | still old `state.plans` branch | Data layer ready, UI not migrated yet |
| Liberty Global | Yes | No | still old `state.plans` branch | Data layer ready, UI not migrated yet |

## 8. Exact Filter Rules Per Migrated Tab

These are the strict rules currently used in repository filtering.

### Daily

- `PlanType = P`
- `Frequency = D`

Repository method:

- `fetchDailyPlansFromApi(...)`

Model:

- `models/daily_plan_model.dart`

### Weekly

- `PlanType = P`
- `Frequency = W`

Repository method:

- `fetchWeeklyPlansFromApi(...)`

Model:

- `models/weekly_plan_model.dart`

### Monthly

- `PlanType = P`
- `Frequency = M`

Repository method:

- `fetchMonthlyPlansFromApi(...)`

Model:

- `models/monthly_plan_model.dart`

### Roaming

- `PlanType = A`
- `PlanGroup = roaming`

Repository method:

- `fetchRoamingPlansFromApi(...)`

Model:

- `models/roaming_plan_model.dart`

### RoamEasy

- `PlanType = A`
- `PlanGroup = roameasy`

Repository method:

- `fetchRoamEasyPlansFromApi(...)`

Model:

- `models/roameasy_plan_model.dart`

### MiFi

- `PlanType = P`
- `PlanGroup = mifi (30 day)`

Repository method:

- `fetchMifiPlansFromApi(...)`

Model:

- `models/mifi_plan_model.dart`

### Liberty Global

- `PlanType = A`
- `PlanGroup = liberty global`

Repository method:

- `fetchLibertyGlobalPlansFromApi(...)`

Model:

- `models/liberty_global_plan_model.dart`

## 9. Current UI Wiring Details

Main screen:

- `PlanScreen/view/home_plan_screen.dart`

Main list switch:

- `PlanScreen/widgets/home_plan_plans_list.dart`

Current UI behavior:

- Daily uses `HomePlanDailyPlanCard`
- Weekly uses `HomePlanWeeklyPlanCard`
- Monthly uses `HomePlanMonthlyPlanCard`
- Roaming uses `HomePlanRoamingPlanCard`
- RoamEasy uses `HomePlanRoamEasyPlanCard`
- MiFi still uses old `HomePlanMifiPlanCard` with generic `HomePlanModel`
- Liberty Global still uses old `HomePlanLibertyGlobalPlanCard` with generic `HomePlanModel`

This means:

- Roaming and RoamEasy are already visually migrated to real API cards.
- MiFi and Liberty Global are not yet visually migrated to their new dedicated models.

## 10. Purchase Flow Status

Purchase behavior is not fully consistent across all tabs.

### Daily / Weekly / Monthly

These tabs already display API data in the UI, but the current `purchase now` wiring is still mostly placeholder in `home_plan_screen.dart`.

Current behavior:

- plan cards render correctly
- purchase callback is not fully connected to the existing bottom sheet / full purchase journey

### Roaming / RoamEasy

These tabs already have a purchase-sheet adapter path in `home_plan_screen.dart`.

The pattern used there is:

- convert the dedicated typed model into a lightweight `HomePlanModel`
- pass that into the existing purchase bottom sheet flow

### MiFi / Liberty Global

Their data layers are ready, but their UI and purchase flow are not migrated yet.

## 11. Card-Level UI Notes

### Daily / Weekly / Monthly cards

These cards are the strongest reference if a future migration needs to follow an existing API-backed pattern.

Files:

- `widgets/daily_plan_card.dart`
- `widgets/weekly_plan_card.dart`
- `widgets/monthly_plan_card.dart`

Important behaviors:

- VAT-inclusive price pill is shown
- plan buckets are rendered from API data
- when there is only one bucket item, the bucket row can center
- description expands/collapses using `expandedPlanIds`

### Roaming card

File:

- `widgets/roaming_plan_card.dart`

Current behavior:

- API-backed
- price includes VAT
- currently shows only the first bucket item in the center

### RoamEasy card

File:

- `widgets/roameasy_plan_card.dart`

Current behavior:

- API-backed
- price includes VAT
- currently shows only the first bucket item in the center

### MiFi and Liberty Global cards

Files:

- `widgets/mifi_plan_card.dart`
- `widgets/liberty_global_plan_card.dart`

Current behavior:

- still old generic card rendering
- not yet connected to dedicated typed API models

## 12. Old Generic Path Still Exists

Important:

`home_plan_repository.dart` still contains:

- `fetchPlans({required HomePlanTab tab})`

That method returns old hardcoded `HomePlanModel` lists for several tabs.

Right now:

- Daily, Weekly, Monthly, Roaming, RoamEasy, MiFi, and Liberty Global still have old mock definitions inside that method
- but only MiFi and Liberty Global still depend on that generic path in UI
- the already migrated UI tabs no longer rely on those mock lists

This matters because a future cleanup can remove duplicated legacy data once MiFi and Liberty Global UI are migrated too.

## 13. Add-ons Tab Notes

Add-ons are not following the same dedicated plan-model API pattern as the main migrated tabs.

Relevant files:

- `widgets/home_plan_add_ons_tab_content.dart`
- `purchasePlanAddOns/...`

Current behavior:

- Add-ons have their own repository flow
- Add-ons tab reuses the UI components from `purchasePlanAddOns`
- bottom checkout bar appears from `home_plan_screen.dart`

## 14. Postpaid Side Notes

Postpaid is separate from the prepaid tabbed API migration work.

Relevant file:

- `PlanScreen/view/postpaid_roaming_screen.dart`

Also related:

- `PlanScreen/view/postpaid_add_on.dart`

Current status:

- looks more prototype / static compared to the prepaid `home_plan_screen.dart` flow
- was not part of the recent API migration work

## 15. Known Gaps And Safe Assumptions

### What is already stable

- Dedicated API data layer pattern for:
  - Daily
  - Weekly
  - Monthly
  - Roaming
  - RoamEasy
  - MiFi
  - Liberty Global
- Background JSON decoding and payload caching
- Per-tab loading/error state separation
- One-time toast side effects through bloc state

### What is still incomplete

- MiFi UI is not connected to `mifiApiPlans`
- Liberty Global UI is not connected to `libertyGlobalApiPlans`
- Daily / Weekly / Monthly purchase action is still mostly placeholder
- Old hardcoded `fetchPlans(...)` data still exists and is partially still used

### Safe assumption for future work

If a future task says:

- "integrate API for a new tab"

the correct pattern is:

1. create dedicated model
2. add repository filter + cache + debug flow
3. add event
4. add state list + timestamp
5. add bloc sync handler + scheduler + loading/failure wiring
6. connect UI afterward

That is the established pattern in this module now.

## 16. Recommended Files To Read First For Future Changes

If the next task is about API integration:

1. `PlanScreen/repository/home_plan_repository.dart`
2. `PlanScreen/bloc/home_plan_bloc.dart`
3. `PlanScreen/bloc/home_plan_state.dart`
4. `PlanScreen/bloc/home_plan_event.dart`
5. one already-migrated model such as `models/roameasy_plan_model.dart`

If the next task is about UI wiring:

1. `PlanScreen/widgets/home_plan_plans_list.dart`
2. `PlanScreen/view/home_plan_screen.dart`
3. one already-migrated card such as:
   - `widgets/monthly_plan_card.dart`
   - `widgets/roaming_plan_card.dart`
   - `widgets/roameasy_plan_card.dart`

If the next task is about purchase flow:

1. `PlanScreen/view/home_plan_screen.dart`
2. `PlanScreen/widgets/home_plan_purchase_sheet_launcher.dart`
3. `homePlanConfirmation/...`
4. `homeRoamingConfirmation/...`
5. `homePlansPaymentMethod/...`
6. `homePlanPurchaseReceipt/...`

## 17. Suggested Prompt For Future Codex Sessions

If you want a future Codex session to start with the right context, a good prompt is:

> Read `lib/app/Plans/README.md` first, then work on `lib/app/Plans/PlanScreen/...`

Or more specific:

> Read `lib/app/Plans/README.md` first. Follow the existing API-backed tab pattern in `PlanScreen` and do not change UI until data-layer integration is complete.

## 18. Short Summary

The `Plans` module now has a clear migration path inside `PlanScreen`:

- Daily, Weekly, Monthly, Roaming, and RoamEasy are already real-API-driven in both data layer and UI.
- MiFi and Liberty Global already have the same real-API data layer, but their UI is still pending migration.
- The old generic mock plan path still exists, but it is now mostly legacy and should be treated carefully during future cleanup.
