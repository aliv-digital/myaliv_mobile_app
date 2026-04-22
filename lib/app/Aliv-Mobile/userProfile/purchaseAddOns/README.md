# purchaseAddOns Trackpad

This folder is the isolated user-profile purchase add-ons flow.

## Goal

Show the same already-loaded add-ons data and the same add-ons UI used by `PlanScreen` > add-ons tab, while keeping all public classes and widgets named for `purchaseAddOns`.

## Source Flow Being Mirrored

1. `PlansCubit` is the single owner that loads plan and add-ons API data.
2. `PlansRepository.fetchAddOnsData()` still owns the canonical API parsing inside PlanScreen.
3. `PlansState` keeps the parsed primary plans, add-on tiles, and selected add-on ids.
4. `purchaseAddOns` reads that existing `PlansState` instead of calling the API again.
5. `PurchaseAddOnsRepository` only maps PlanScreen models into purchaseAddOns-named models.
6. `PurchaseAddOnsScreen` listens to `PlansCubit` so updates and selections stay in sync.

## Implementation Checklist

- [x] Trace the PlanScreen add-ons data and UI flow.
- [x] Create this README as the working trackpad.
- [x] Add purchaseAddOns models and repository mapping.
- [x] Update purchaseAddOns bloc/state to hydrate from existing `PlansCubit` data.
- [x] Copy `HomePlanAddOnsTabContent` into a purchaseAddOns-named widget.
- [x] Align purchaseAddOns tile/card widgets with the PlanScreen add-ons UI.
- [x] Wire `PurchaseAddOnsScreen` to the reused PlanScreen add-ons content.
- [x] Remove the duplicate add-ons API call from purchaseAddOns.
- [x] Run format and scoped analyzer checks.

## Notes

- The canonical API parsing remains in `PlansRepository`, but only `PlansCubit` should ask it for add-ons data.
- This folder converts PlanScreen models into purchaseAddOns models at the repository boundary to keep the UI classes locally named.
- Add-on selection is sent through `PlansCubit.toggleAddon()` first so the PlanScreen tab and this screen share the same selected ids.
