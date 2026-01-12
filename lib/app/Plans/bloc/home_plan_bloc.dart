import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/home_plan_repository.dart';
import 'home_plan_event.dart';
import 'home_plan_state.dart';

class HomePlanBloc extends Bloc<HomePlanEvent, HomePlanState> {
  final HomePlanRepository repository;

  HomePlanBloc(this.repository) : super(HomePlanState.initial()) {
    on<HomePlanStarted>(_onStarted);
    on<HomePlanTabChanged>(_onTabChanged);
    on<HomePlanToggleExpanded>(_onToggleExpanded);

    // UI hooks (optional)
    on<HomePlanViewDetailsPressed>(_onViewDetailsPressed);
    on<HomePlanPurchaseNowPressed>(_onPurchaseNowPressed);

    // AddOns
    on<HomePlanToggleAddon>(_onToggleAddon);
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
    // reset expand on tab change
    emit(state.copyWith(
      selectedTab: event.tab,
      expandedPlanIds: <String>{},

      // keep UI clean on switching tabs
      plans: const [],
      addOns: const [],
      status: HomePlanStatus.loading,
      errorMessage: null,
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

  void _onViewDetailsPressed(
      HomePlanViewDetailsPressed event,
      Emitter<HomePlanState> emit,
      ) {
    // keep empty for now (screen listener can handle navigation)
  }

  void _onPurchaseNowPressed(
      HomePlanPurchaseNowPressed event,
      Emitter<HomePlanState> emit,
      ) {
    // keep empty for now (screen listener can handle navigation)
  }

  void _onToggleAddon(
      HomePlanToggleAddon event,
      Emitter<HomePlanState> emit,
      ) {
    final next = Set<String>.from(state.selectedAddOnIds);

    if (next.contains(event.addon.id)) {
      next.remove(event.addon.id);
    } else {
      next.add(event.addon.id);
    }

    emit(state.copyWith(selectedAddOnIds: next));
  }

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
        final addOns = await repository.fetchAddOns();

        emit(state.copyWith(
          status: HomePlanStatus.loaded,
          addOns: addOns,
          plans: const [],
          expandedPlanIds: <String>{},
        ));
        return;
      }

      final plans = await repository.fetchPlans(tab: tab);

      emit(state.copyWith(
        status: HomePlanStatus.loaded,
        plans: plans,
        addOns: const [],
      ));
    } catch (_) {
      emit(state.copyWith(
        status: HomePlanStatus.failure,
        errorMessage: 'Failed to load plans',
      ));
    }
  }
}
