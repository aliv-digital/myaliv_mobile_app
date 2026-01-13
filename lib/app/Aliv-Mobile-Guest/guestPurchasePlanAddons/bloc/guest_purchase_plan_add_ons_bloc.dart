import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/guest_purchase_plan_add_ons_repository.dart';
import 'guest_purchase_plan_add_ons_event.dart';
import 'guest_purchase_plan_add_ons_state.dart';

class GuestPurchasePlanAddOnsBloc
    extends Bloc<GuestPurchasePlanAddOnsEvent, GuestPurchasePlanAddOnsState> {
  final GuestPurchasePlanAddOnsRepository repository;

  GuestPurchasePlanAddOnsBloc({required this.repository})
      : super(GuestPurchasePlanAddOnsState.initial()) {
    on<GuestPurchasePlanAddOnsStarted>(_onStarted);
    on<GuestPurchasePlanAddOnsAutoRenewToggled>(_onAutoRenewToggled);
    on<GuestPurchasePlanAddOnsSelectionToggled>(_onSelectionToggled);
    on<GuestPurchasePlanAddOnsSkipPressed>(_onSkipPressed);
    on<GuestPurchasePlanAddOnsProceedPressed>(_onProceedPressed);
  }

  Future<void> _onStarted(
      GuestPurchasePlanAddOnsStarted event,
      Emitter<GuestPurchasePlanAddOnsState> emit,
      ) async {
    emit(state.copyWith(status: GuestPurchasePlanAddOnsStatus.loading, errorMessage: null));

    try {
      // Loading in parallel makes UI faster (clean + readable).
      final results = await Future.wait([
        repository.fetchActivePlan(),
        repository.fetchFairUsePolicy(),
        repository.fetchAddOns(),
      ]);

      emit(state.copyWith(
        status: GuestPurchasePlanAddOnsStatus.ready,
        activePlan: results[0] as dynamic,
        fairUsePolicy: results[1] as dynamic,
        addOns: results[2] as dynamic,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GuestPurchasePlanAddOnsStatus.error,
        errorMessage: 'Failed to load add-ons',
      ));
    }
  }

  void _onAutoRenewToggled(
      GuestPurchasePlanAddOnsAutoRenewToggled event,
      Emitter<GuestPurchasePlanAddOnsState> emit,
      ) {
    final plan = state.activePlan;
    if (plan == null) return;

    emit(state.copyWith(activePlan: plan.copyWith(autoRenew: event.value)));
  }

  void _onSelectionToggled(
      GuestPurchasePlanAddOnsSelectionToggled event,
      Emitter<GuestPurchasePlanAddOnsState> emit,
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
      GuestPurchasePlanAddOnsSkipPressed event,
      Emitter<GuestPurchasePlanAddOnsState> emit,
      ) {
    emit(state.copyWith(skipRequestId: state.skipRequestId + 1));
  }

  void _onProceedPressed(
      GuestPurchasePlanAddOnsProceedPressed event,
      Emitter<GuestPurchasePlanAddOnsState> emit,
      ) {
    emit(state.copyWith(proceedRequestId: state.proceedRequestId + 1));
  }
}
