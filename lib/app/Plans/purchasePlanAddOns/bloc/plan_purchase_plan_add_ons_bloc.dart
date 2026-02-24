import 'package:flutter_bloc/flutter_bloc.dart';

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
    emit(state.copyWith(status: PlanPurchasePlanAddOnsStatus.loading, errorMessage: null));

    try {
      // Loading in parallel makes UI faster (clean + readable).
      final results = await Future.wait([
        repository.fetchActivePlan(),
        repository.fetchFairUsePolicy(),
        repository.fetchAddOns(),
      ]);

      emit(state.copyWith(
        status: PlanPurchasePlanAddOnsStatus.ready,
        activePlan: results[0] as dynamic,
        fairUsePolicy: results[1] as dynamic,
        addOns: results[2] as dynamic,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PlanPurchasePlanAddOnsStatus.error,
        errorMessage: 'Failed to load add-ons',
      ));
    }
  }

  void _onAutoRenewToggled(
      PlanPurchasePlanAddOnsAutoRenewToggled event,
      Emitter<PlanPurchasePlanAddOnsState> emit,
      ) {
    final plan = state.activePlan;
    if (plan == null) return;

    emit(state.copyWith(activePlan: plan.copyWith(autoRenew: event.value)));
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
