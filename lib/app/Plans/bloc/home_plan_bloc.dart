import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/plan_model.dart';
import '../models/add_on_model.dart';
import '../repository/home_plan_repository.dart';
import 'home_plan_event.dart';
import 'home_plan_state.dart';

class HomePlanBloc extends Bloc<HomePlanEvent, HomePlanState> {
  final HomePlanRepository repository;

  HomePlanBloc(this.repository) : super(HomePlanState.initial()) {
    on<HomePlanStarted>(_onStarted);
    on<HomePlanTabChanged>(_onTabChanged);
    on<HomePlanToggleExpanded>(_onToggleExpanded);

    // These 2 are UI action hooks (navigation handled in screen via listener if needed)
    on<HomePlanViewDetailsPressed>(_onViewDetailsPressed);
    on<HomePlanPurchaseNowPressed>(_onPurchaseNowPressed);

    // ✅ AddOns toggle
    on<HomePlanToggleAddon>(_onToggleAddOns);
  }

  Future<void> _onStarted(
    HomePlanStarted event,
    Emitter<HomePlanState> emit,
  ) async {
    await _loadByTab(emit, tab: state.selectedTab);
  }

  Future<void> _onTabChanged(
    HomePlanTabChanged event,
    Emitter<HomePlanState> emit,
  ) async {
    // user tab change korle ekhane eshe selected tab load hoy
    emit(state.copyWith(
      selectedTab: event.tab,
      expandedPlanIds: {},
      // ✅ tab change e addOns list clean (optional but safe)
      // AddOns tab e gele abar load হবে
      addOns: event.tab == HomePlanTab.addOns ? state.addOns : const [],
      // ✅ checked state preserve rakhte chaile eta remove korba na
      // ami safe ভাবে preserve রাখছি
    ));

    await _loadByTab(emit, tab: event.tab);
  }

  void _onToggleExpanded(
    HomePlanToggleExpanded event,
    Emitter<HomePlanState> emit,
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
    HomePlanViewDetailsPressed event,
    Emitter<HomePlanState> emit,
  ) {}

  void _onPurchaseNowPressed(
    HomePlanPurchaseNowPressed event,
    Emitter<HomePlanState> emit,
  ) {}

  // ✅ AddOns multi-select toggle
  void _onToggleAddOns(
    HomePlanToggleAddon event,
    Emitter<HomePlanState> emit,
  ) {
    final next = Set<String>.from(state.selectedAddOnIds);

    // event.addon -> HomePlanAddOnModel (id)
    if (next.contains(event.addon.id)) {
      next.remove(event.addon.id); // uncheck
    } else {
      next.add(event.addon.id); // check
    }

    emit(state.copyWith(selectedAddOnIds: next));
  }

  // ✅ one loader that handles both: plans + addOns
  Future<void> _loadByTab(
    Emitter<HomePlanState> emit, {
    required HomePlanTab tab,
  }) async {
    try {
      emit(state.copyWith(
        status: HomePlanStatus.loading,
        errorMessage: null,
      ));

      if (tab == HomePlanTab.addOns) {
        // ✅ load addOns instead of plans
        final List<HomePlanAddOnModel> addOns = await repository.fetchAddOns();
        emit(state.copyWith(
          status: HomePlanStatus.loaded,
          addOns: addOns,
          plans: const [], // keep clean
          expandedPlanIds: const {},
        ));
        return;
      }

      // ✅ normal plans
      final List<HomePlanModel> plans = await repository.fetchPlans(tab: tab);
      emit(state.copyWith(
        status: HomePlanStatus.loaded,
        plans: plans,
        addOns: const [], // keep clean
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomePlanStatus.failure,
        errorMessage: 'Failed to load plans',
      ));
    }
  }

  // ✅ kept your old method too (existing delete korini)
  Future<void> _loadPlans(
    Emitter<HomePlanState> emit, {
    required HomePlanTab tab,
  }) async {
    try {
      emit(state.copyWith(
        status: HomePlanStatus.loading,
        errorMessage: null,
      ));
      final List<HomePlanModel> plans = await repository.fetchPlans(tab: tab);
      emit(state.copyWith(
        status: HomePlanStatus.loaded,
        plans: plans,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomePlanStatus.failure,
        errorMessage: 'Failed to load plans',
      ));
    }
  }
}
