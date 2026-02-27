import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/add_ons_confirmation_models.dart';
import '../repository/add_ons_confirmation_repository.dart';
import 'add_ons_confirmation_event.dart';
import 'add_ons_confirmation_state.dart';

class AddOnsConfirmationBloc
    extends Bloc<AddOnsConfirmationEvent, AddOnsConfirmationState> {
  final AddOnsConfirmationRepository repository;

  AddOnsConfirmationBloc({required this.repository})
      : super(AddOnsConfirmationState.initial()) {
    on<AddOnsConfirmationStarted>(_onStarted);
    on<AddOnsConfirmationRemoveItemPressed>(_onRemoveItem);
    on<AddOnsConfirmationTermsPressed>(_onTerms);
    on<AddOnsConfirmationTermsCheckboxToggled>(
      _onTermsCheckboxToggled,
    );
    on<AddOnsConfirmationPayNowPressed>(_onPayNow);
  }

  Future<void> _onStarted(
    AddOnsConfirmationStarted event,
    Emitter<AddOnsConfirmationState> emit,
  ) async {
    emit(state.copyWith(status: AddOnsConfirmationStatus.loading));

    try {
      final data = await repository.load(phoneNumber: event.phoneNumber);
      emit(state.copyWith(
        status: AddOnsConfirmationStatus.ready,
        data: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddOnsConfirmationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onRemoveItem(
    AddOnsConfirmationRemoveItemPressed event,
    Emitter<AddOnsConfirmationState> emit,
  ) {
    final data = state.data;
    if (data == null) return;

    final updatedItems = data.items.where((x) => x.id != event.itemId).toList();

    final totals = PurchaseTotals(
      subTotal: updatedItems.fold<double>(0, (s, x) => s + x.price),
      vat: data.totals.vat,
    );

    emit(state.copyWith(
      data: AddOnsConfirmationData(
        phoneNumber: data.phoneNumber,
        headerTitle: data.headerTitle,
        beginsOnDateText: data.beginsOnDateText,
        items: updatedItems,
        totals: totals,
      ),
    ));
  }

  void _onTerms(
    AddOnsConfirmationTermsPressed event,
    Emitter<AddOnsConfirmationState> emit,
  ) {
    emit(state.copyWith(openTermsRequestId: state.openTermsRequestId + 1));
  }

  void _onTermsCheckboxToggled(
    AddOnsConfirmationTermsCheckboxToggled event,
    Emitter<AddOnsConfirmationState> emit,
  ) {
    emit(state.copyWith(isTermsChecked: event.isChecked));
  }

  void _onPayNow(
    AddOnsConfirmationPayNowPressed event,
    Emitter<AddOnsConfirmationState> emit,
  ) {
    if (!state.isTermsChecked) return;

    // Future: call API to create payment intent etc.
    emit(state.copyWith(payNowRequestId: state.payNowRequestId + 1));
  }
}
