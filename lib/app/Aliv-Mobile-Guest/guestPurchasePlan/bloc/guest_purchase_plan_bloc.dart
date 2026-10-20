import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_on_model.dart'
    as prepaid;
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plans_repository.dart';

import '../models/add_on_model.dart';
import '../models/plan_model.dart';
import '../repository/guest_purchase_plan_repository.dart';
import 'guest_purchase_plan_event.dart';
import 'guest_purchase_plan_state.dart';

class GuestPurchasePlanBloc
    extends Bloc<GuestPurchasePlanEvent, GuestPurchasePlanState> {
  final GuestPurchasePlanRepository repository;

  GuestPurchasePlanBloc(this.repository)
    : super(GuestPurchasePlanState.initial()) {
    on<GuestPurchasePlanStarted>(_onStarted);
    on<GuestPurchasePlanTabChanged>(_onTabChanged);
    on<GuestPurchasePlanToggleExpanded>(_onToggleExpanded);

    // These 2 are UI action hooks (navigation handled in screen via listener if needed)
    on<GuestPurchasePlanViewDetailsPressed>(_onViewDetailsPressed);
    on<GuestPurchasePlanPurchaseNowPressed>(_onPurchaseNowPressed);

    // ✅ AddOns toggle
    on<GuestPurchasePlanToggleAddon>(_onToggleAddOns);

    // Primary plan the user tapped — feeds the red "will be" card and
    // the activate-now bottom-sheet decision tree.
    on<GuestPrimaryPlanSelected>(_onPrimaryPlanSelected);
  }

  Future<void> _onStarted(
    GuestPurchasePlanStarted event,
    Emitter<GuestPurchasePlanState> emit,
  ) async {
    // Fire catalog + /Guest/existingplans in parallel. Bundles populates
    // addOnsApiPrimaryPlans / secondaryPlans / standAlonePlans / addOns,
    // catalog populates plans for the current tab. Mirrors prepaid
    // PlansCubit._fetchAllPlans (plans + bundles concurrent).
    emit(state.copyWith(isLoadingBundles: true));

    unawaited(_loadBundles(emit));
    await _loadByTab(emit, tab: state.selectedTab);
  }

  Future<void> _onTabChanged(
    GuestPurchasePlanTabChanged event,
    Emitter<GuestPurchasePlanState> emit,
  ) async {
    // user tab change korle ekhane eshe selected tab load hoy
    emit(state.copyWith(selectedTab: event.tab, expandedPlanIds: {}));

    await _loadByTab(emit, tab: event.tab);
  }

  void _onToggleExpanded(
    GuestPurchasePlanToggleExpanded event,
    Emitter<GuestPurchasePlanState> emit,
  ) {
    final next = Set<String>.from(state.expandedPlanIds);
    if (next.contains(event.planId)) {
      next.remove(event.planId);
    } else {
      next.add(event.planId);
    }
    emit(state.copyWith(expandedPlanIds: next));
  }

  // optional handlers (kept for pattern consistency)
  void _onViewDetailsPressed(
    GuestPurchasePlanViewDetailsPressed event,
    Emitter<GuestPurchasePlanState> emit,
  ) {}

  void _onPurchaseNowPressed(
    GuestPurchasePlanPurchaseNowPressed event,
    Emitter<GuestPurchasePlanState> emit,
  ) {}

  // ✅ AddOns multi-select toggle
  void _onToggleAddOns(
    GuestPurchasePlanToggleAddon event,
    Emitter<GuestPurchasePlanState> emit,
  ) {
    final next = Set<String>.from(state.selectedAddOnIds);

    // event.addon -> AddOnModel (id)
    if (next.contains(event.addon.id)) {
      next.remove(event.addon.id); // uncheck
    } else {
      next.add(event.addon.id); // check
    }

    emit(state.copyWith(selectedAddOnIds: next));
  }

  void _onPrimaryPlanSelected(
    GuestPrimaryPlanSelected event,
    Emitter<GuestPurchasePlanState> emit,
  ) {
    emit(state.copyWith(selectedPrimaryPlan: event.plan));
  }

  /// Fetches /Guest/existingplans and emits the primary/secondary/
  /// stand-alone/add-ons slice. Runs concurrently with catalog loading.
  Future<void> _loadBundles(Emitter<GuestPurchasePlanState> emit) async {
    try {
      final AddOnsResult result = await repository.fetchExistingBundles();
      if (emit.isDone) return;
      emit(
        state.copyWith(
          addOnsApiPrimaryPlans: result.primaryPlans,
          secondaryPlans: result.secondaryPlans,
          standAlonePlans: result.standAlonePlans,
          addOns: result.addOns.map(_toGuestAddOn).toList(growable: false),
          isLoadingBundles: false,
        ),
      );
    } catch (e) {
      // Catalog is the primary UX for guest — a bundles error should not
      // flip the whole screen into failure. Silently drop to no-active-plan
      // state (mirrors prepaid: empty PrimaryPlans ⇒ no active plan card).
      if (emit.isDone) return;
      emit(state.copyWith(isLoadingBundles: false));
    }
  }

  static AddOnModel _toGuestAddOn(prepaid.HomePlanAddOnModel source) {
    return AddOnModel(
      id: source.id,
      title: source.title,
      label: source.label,
      value: source.value,
      price: source.price,
    );
  }

  // ✅ catalog loader — plans tab only. Add-ons tab reads state.addOns
  // (sourced from /Guest/existingplans by _loadBundles).
  Future<void> _loadByTab(
    Emitter<GuestPurchasePlanState> emit, {
    required PlanTab tab,
  }) async {
    try {
      emit(
        state.copyWith(
          status: GuestPurchasePlanStatus.loading,
          errorMessage: null,
        ),
      );

      if (tab == PlanTab.addOns) {
        // Add-ons are driven by /Guest/existingplans via _loadBundles.
        // Nothing to load here — just mark the tab loaded so the UI
        // paints with whatever addOns are already in state.
        emit(
          state.copyWith(
            status: GuestPurchasePlanStatus.loaded,
            plans: const [],
            expandedPlanIds: const {},
          ),
        );
        return;
      }

      // ✅ normal plans
      final List<GuestPlanDisplayModel> plans = await repository.fetchPlans(
        tab: tab,
      );
      emit(
        state.copyWith(status: GuestPurchasePlanStatus.loaded, plans: plans),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GuestPurchasePlanStatus.failure,
          errorMessage: 'Failed to load plans',
        ),
      );
    }
  }
}
