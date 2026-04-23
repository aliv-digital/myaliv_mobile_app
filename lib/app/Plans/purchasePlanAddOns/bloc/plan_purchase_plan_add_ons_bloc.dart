import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/plan_purchase_add_on_models.dart';
import '../repository/plan_purchase_plan_add_ons_repository.dart';
import 'plan_purchase_plan_add_ons_event.dart';
import 'plan_purchase_plan_add_ons_state.dart';

class PlanPurchasePlanAddOnsBloc
    extends Bloc<PlanPurchasePlanAddOnsEvent, PlanPurchasePlanAddOnsState> {
  final PlanPurchasePlanAddOnsRepository repository;

  PlanPurchasePlanAddOnsBloc({required this.repository})
    : super(PlanPurchasePlanAddOnsState.initial()) {
    on<PlanPurchasePlanAddOnsStarted>(_onStarted);
    on<PlanPurchasePlanAddOnsAutoRenewToggled>(_onAutoRenewToggled);
    on<PlanPurchasePlanAddOnsSelectionToggled>(_onSelectionToggled);
    on<PlanPurchasePlanAddOnsSkipPressed>(_onSkipPressed);
    on<PlanPurchasePlanAddOnsProceedPressed>(_onProceedPressed);
  }

  Future<void> _onStarted(
    PlanPurchasePlanAddOnsStarted event,
    Emitter<PlanPurchasePlanAddOnsState> emit,
  ) async {
    // Prevent duplicate API calls if already loading
    if (state.status == PlanPurchasePlanAddOnsStatus.loading) {
      return;
    }

    emit(
      state.copyWith(
        status: PlanPurchasePlanAddOnsStatus.loading,
        routeArgs: event.routeArgs,
        errorMessage: null,
      ),
    );

    try {
      final selectedPlan = event.routeArgs?.selectedApiPlan;
      final selectedPlanAddOns = repository.mapAvailableBoltOnsToAddOnItems(
        selectedPlan,
      );

      // Loading in parallel makes UI faster (clean + readable).
      final results = await Future.wait([
        repository.fetchActivePlan(),
        repository.fetchFairUsePolicy(),
        if (selectedPlan == null)
          repository.fetchAddOns()
        else
          Future<List<PlanPurchaseAddOnItem>>.value(selectedPlanAddOns),
      ]);
      final activePlan = results[0] as PlanPurchaseActivePlanSummary;

      emit(
        state.copyWith(
          status: PlanPurchasePlanAddOnsStatus.ready,
          routeArgs: event.routeArgs,
          activePlan: activePlan,
          fairUsePolicy: results[1] as dynamic,
          addOns: results[2] as dynamic,
          autoRenew: selectedPlan?.autoRenew ?? activePlan.autoRenew,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PlanPurchasePlanAddOnsStatus.error,
          routeArgs: event.routeArgs,
          errorMessage: 'Failed to load add-ons',
        ),
      );
    }
  }

  void _onAutoRenewToggled(
    PlanPurchasePlanAddOnsAutoRenewToggled event,
    Emitter<PlanPurchasePlanAddOnsState> emit,
  ) {
    final plan = state.activePlan;
    if (plan == null) return;

    emit(
      state.copyWith(
        activePlan: plan.copyWith(autoRenew: event.value),
        autoRenew: event.value,
      ),
    );
  }

  void _onSelectionToggled(
    PlanPurchasePlanAddOnsSelectionToggled event,
    Emitter<PlanPurchasePlanAddOnsState> emit,
  ) {
    final updated = {...state.selectedAddOnIds};
    if (event.selected) {
      updated.add(event.addOnId);
    } else {
      updated.remove(event.addOnId);
    }
    emit(state.copyWith(selectedAddOnIds: updated));
  }

  void _onSkipPressed(
    PlanPurchasePlanAddOnsSkipPressed event,
    Emitter<PlanPurchasePlanAddOnsState> emit,
  ) {
    emit(state.copyWith(skipRequestId: state.skipRequestId + 1));
  }

  void _onProceedPressed(
    PlanPurchasePlanAddOnsProceedPressed event,
    Emitter<PlanPurchasePlanAddOnsState> emit,
  ) {
    emit(state.copyWith(proceedRequestId: state.proceedRequestId + 1));
  }
}
