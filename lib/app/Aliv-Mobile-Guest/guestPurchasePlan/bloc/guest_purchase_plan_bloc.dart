import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/plan_model.dart';
import '../models/add_on_model.dart';
import '../repository/guest_purchase_plan_repository.dart';
import 'guest_purchase_plan_event.dart';
import 'guest_purchase_plan_state.dart';

class GuestPurchasePlanBloc extends Bloc<GuestPurchasePlanEvent, GuestPurchasePlanState> {
  final GuestPurchasePlanRepository repository;

  GuestPurchasePlanBloc(this.repository) : super(GuestPurchasePlanState.initial()) {
    on<GuestPurchasePlanStarted>(_onStarted);
    on<GuestPurchasePlanTabChanged>(_onTabChanged);
    on<GuestPurchasePlanToggleExpanded>(_onToggleExpanded);

    // These 2 are UI action hooks (navigation handled in screen via listener if needed)
    on<GuestPurchasePlanViewDetailsPressed>(_onViewDetailsPressed);
    on<GuestPurchasePlanPurchaseNowPressed>(_onPurchaseNowPressed);

    // ✅ AddOns toggle
    on<GuestPurchasePlanToggleAddon>(_onToggleAddOns);
  }

  Future<void> _onStarted(GuestPurchasePlanStarted event, Emitter<GuestPurchasePlanState> emit,
      ) async {
    await _loadByTab(emit, tab: state.selectedTab);
  }

  Future<void> _onTabChanged(
      GuestPurchasePlanTabChanged event,
      Emitter<GuestPurchasePlanState> emit,
      ) async {
    // user tab change korle ekhane eshe selected tab load hoy
    emit(state.copyWith(
      selectedTab: event.tab,
      expandedPlanIds: {},
      // ✅ tab change e addOns list clean (optional but safe)
      // AddOns tab e gele abar load হবে
      addOns: event.tab == PlanTab.addOns ? state.addOns : const [],
      // ✅ checked state preserve rakhte chaile eta remove korba na
      // ami safe ভাবে preserve রাখছি
    ));

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

  // ✅ one loader that handles both: plans + addOns
  Future<void> _loadByTab(
      Emitter<GuestPurchasePlanState> emit, {
        required PlanTab tab,
      }) async {
    try {
      emit(state.copyWith(
        status: GuestPurchasePlanStatus.loading,
        errorMessage: null,
      ));

      if (tab == PlanTab.addOns) {
        // ✅ load addOns instead of plans
        final List<AddOnModel> addOns = await repository.fetchAddOns();
        emit(state.copyWith(
          status: GuestPurchasePlanStatus.loaded,
          addOns: addOns,
          plans: const [], // keep clean
          expandedPlanIds: const {},
        ));
        return;
      }

      // ✅ normal plans
      final List<PlanModel> plans = await repository.fetchPlans(tab: tab);
      emit(state.copyWith(
        status: GuestPurchasePlanStatus.loaded,
        plans: plans,
        addOns: const [], // keep clean
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GuestPurchasePlanStatus.failure,
        errorMessage: 'Failed to load plans',
      ));
    }
  }

  // ✅ kept your old method too (existing delete korini)
  Future<void> _loadPlans(
      Emitter<GuestPurchasePlanState> emit, {
        required PlanTab tab,
      }) async {
    try {
      emit(state.copyWith(
        status: GuestPurchasePlanStatus.loading,
        errorMessage: null,
      ));
      final List<PlanModel> plans = await repository.fetchPlans(tab: tab);
      emit(state.copyWith(
        status: GuestPurchasePlanStatus.loaded,
        plans: plans,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GuestPurchasePlanStatus.failure,
        errorMessage: 'Failed to load plans',
      ));
    }
  }
}
