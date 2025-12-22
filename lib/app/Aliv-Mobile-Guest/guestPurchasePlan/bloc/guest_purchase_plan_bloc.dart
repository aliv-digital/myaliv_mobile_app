import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/plan_model.dart';
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
  }

  Future<void> _onStarted(
      GuestPurchasePlanStarted event,
      Emitter<GuestPurchasePlanState> emit,
      ) async {
    await _loadPlans(emit, tab: state.selectedTab);
  }

  Future<void> _onTabChanged(
      GuestPurchasePlanTabChanged event,
      Emitter<GuestPurchasePlanState> emit,
      ) async {
    emit(state.copyWith(
      selectedTab: event.tab,
      expandedPlanIds: {},
    ));
    await _loadPlans(emit, tab: event.tab);
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

  Future<void> _loadPlans(Emitter<GuestPurchasePlanState> emit, {required PlanTab tab}) async {
    try {
      emit(state.copyWith(status: GuestPurchasePlanStatus.loading, errorMessage: null));
      final List<PlanModel> plans = await repository.fetchPlans(tab: tab);
      emit(state.copyWith(status: GuestPurchasePlanStatus.loaded, plans: plans));
    } catch (e) {
      emit(state.copyWith(status: GuestPurchasePlanStatus.failure, errorMessage: 'Failed to load plans'));
    }
  }
}
