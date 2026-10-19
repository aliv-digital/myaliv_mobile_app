// __PARKED_PURCHASE_ADD_ONS__
// Parked: superseded by PlanScreen widgets reused via PurchaseAddOnsScreen.
// Kept (commented-out) for reversibility; safe to delete after QA.
/*
import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/purchase_add_ons_repository.dart';
import 'purchase_add_ons_event.dart';
import 'purchase_add_ons_state.dart';

class PurchaseAddOnsBloc
    extends Bloc<PurchaseAddOnsEvent, PurchaseAddOnsState> {
  final PurchaseAddOnsRepository repository;

  PurchaseAddOnsBloc({required this.repository})
      : super(PurchaseAddOnsState.initial()) {
    on<PurchaseAddOnsStarted>(_onStarted);
    on<PurchaseAddOnsAutoRenewToggled>(_onAutoRenewToggled);
    on<PurchaseAddOnsSelectionToggled>(_onSelectionToggled);
    on<PurchaseAddOnsSkipPressed>(_onSkipPressed);
    on<PurchaseAddOnsProceedPressed>(_onProceedPressed);
  }

  void _onStarted(
    PurchaseAddOnsStarted event,
    Emitter<PurchaseAddOnsState> emit,
  ) {
    final result = repository.fromPlansState(event.plansState);

    emit(
      state.copyWith(
        status: PurchaseAddOnsStatus.ready,
        activePrimaryPlan: result.activePrimaryPlan,
        clearActivePrimaryPlan: result.activePrimaryPlan == null,
        addOns: result.addOns,
        selectedAddOnIds: result.selectedAddOnIds,
        errorMessage: null,
      ),
    );
  }

  void _onAutoRenewToggled(
    PurchaseAddOnsAutoRenewToggled event,
    Emitter<PurchaseAddOnsState> emit,
  ) {
    final plan = state.activePrimaryPlan;
    if (plan == null) return;

    emit(
      state.copyWith(
        activePrimaryPlan: plan.copyWith(autoRenew: event.value),
        errorMessage: state.errorMessage,
      ),
    );
  }

  void _onSelectionToggled(
    PurchaseAddOnsSelectionToggled event,
    Emitter<PurchaseAddOnsState> emit,
  ) {
    final updated = {...state.selectedAddOnIds};
    if (event.selected) {
      updated.add(event.addOnId);
    } else {
      updated.remove(event.addOnId);
    }
    emit(
      state.copyWith(
        selectedAddOnIds: updated,
        errorMessage: state.errorMessage,
      ),
    );
  }

  void _onSkipPressed(
    PurchaseAddOnsSkipPressed event,
    Emitter<PurchaseAddOnsState> emit,
  ) {
    emit(
      state.copyWith(
        skipRequestId: state.skipRequestId + 1,
        errorMessage: state.errorMessage,
      ),
    );
  }

  void _onProceedPressed(
    PurchaseAddOnsProceedPressed event,
    Emitter<PurchaseAddOnsState> emit,
  ) {
    emit(
      state.copyWith(
        proceedRequestId: state.proceedRequestId + 1,
        errorMessage: state.errorMessage,
      ),
    );
  }
}

*/
