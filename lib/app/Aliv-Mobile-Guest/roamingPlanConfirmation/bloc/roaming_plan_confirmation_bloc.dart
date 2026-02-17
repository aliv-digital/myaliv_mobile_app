import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/roaming_plan_confirmation_models.dart';
import '../repository/roaming_plan_confirmation_repository.dart';
import 'roaming_plan_confirmation_event.dart';
import 'roaming_plan_confirmation_state.dart';

class RoamingPlanConfirmationBloc
    extends Bloc<RoamingPlanConfirmationEvent, RoamingPlanConfirmationState> {
  final RoamingPlanConfirmationRepository repository;

  RoamingPlanConfirmationBloc({required this.repository})
      : super(RoamingPlanConfirmationState.initial()) {
    on<RoamingPlanConfirmationStarted>(_onStarted);
    on<RoamingPlanConfirmationRemoveItemPressed>(_onRemoveItem);
    on<RoamingPlanConfirmationTermsPressed>(_onTerms);
    on<RoamingPlanConfirmationTermsCheckboxToggled>(
      _onTermsCheckboxToggled,
    );
    on<RoamingPlanConfirmationPayNowPressed>(_onPayNow);
  }

  Future<void> _onStarted(
    RoamingPlanConfirmationStarted event,
    Emitter<RoamingPlanConfirmationState> emit,
  ) async {
    emit(state.copyWith(status: RoamingPlanConfirmationStatus.loading));

    try {
      final data = await repository.load(phoneNumber: event.phoneNumber);
      emit(state.copyWith(
        status: RoamingPlanConfirmationStatus.ready,
        data: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RoamingPlanConfirmationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onRemoveItem(
    RoamingPlanConfirmationRemoveItemPressed event,
    Emitter<RoamingPlanConfirmationState> emit,
  ) {
    final data = state.data;
    if (data == null) return;

    final updatedItems = data.items.where((x) => x.id != event.itemId).toList();

    final totals = PurchaseTotals(
      subTotal: updatedItems.fold<double>(0, (s, x) => s + x.price),
      vat: data.totals.vat,
    );

    emit(state.copyWith(
      data: RoamingPlanConfirmationData(
        phoneNumber: data.phoneNumber,
        headerTitle: data.headerTitle,
        beginsOnDateText: data.beginsOnDateText,
        items: updatedItems,
        totals: totals,
      ),
    ));
  }

  void _onTerms(
    RoamingPlanConfirmationTermsPressed event,
    Emitter<RoamingPlanConfirmationState> emit,
  ) {
    emit(state.copyWith(openTermsRequestId: state.openTermsRequestId + 1));
  }

  void _onTermsCheckboxToggled(
    RoamingPlanConfirmationTermsCheckboxToggled event,
    Emitter<RoamingPlanConfirmationState> emit,
  ) {
    emit(state.copyWith(isTermsChecked: event.isChecked));
  }

  void _onPayNow(
    RoamingPlanConfirmationPayNowPressed event,
    Emitter<RoamingPlanConfirmationState> emit,
  ) {
    if (!state.isTermsChecked) return;

    // Future: call API to create payment intent etc.
    emit(state.copyWith(payNowRequestId: state.payNowRequestId + 1));
  }
}
