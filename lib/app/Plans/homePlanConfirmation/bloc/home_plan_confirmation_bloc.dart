import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/home_plan_confirmation_models.dart';
import '../repository/home_plan_confirmation_repository.dart';
import 'home_plan_confirmation_event.dart';
import 'home_plan_confirmation_state.dart';

class HomePlanConfirmationBloc
    extends Bloc<HomePlanConfirmationEvent, HomePlanConfirmationState> {
  final HomePlanConfirmationRepository repository;

  HomePlanConfirmationBloc({required this.repository})
      : super(HomePlanConfirmationState.initial()) {
    on<HomePlanConfirmationStarted>(_onStarted);
    on<HomePlanConfirmationRemoveItemPressed>(_onRemoveItem);
    on<HomePlanConfirmationTermsPressed>(_onTerms);
    on<HomePlanConfirmationTermsCheckboxToggled>(
      _onTermsCheckboxToggled,
    );
    on<HomePlanConfirmationPayNowPressed>(_onPayNow);
  }

  Future<void> _onStarted(
    HomePlanConfirmationStarted event,
    Emitter<HomePlanConfirmationState> emit,
  ) async {
    emit(state.copyWith(status: HomePlanConfirmationStatus.loading));

    try {
      final data = await repository.load(args: event.args);
      emit(state.copyWith(
        status: HomePlanConfirmationStatus.ready,
        data: data,
        isTermsChecked: event.args.defaultTermsChecked,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomePlanConfirmationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onRemoveItem(
    HomePlanConfirmationRemoveItemPressed event,
    Emitter<HomePlanConfirmationState> emit,
  ) {
    final data = state.data;
    if (data == null) return;

    final updatedItems = data.items.where((x) => x.id != event.itemId).toList();

    final totals = PurchaseTotals(
      subTotal: updatedItems.fold<double>(0, (s, x) => s + x.price),
      vat: data.totals.vat,
    );

    emit(state.copyWith(
      data: HomePlanConfirmationData(
        phoneNumber: data.phoneNumber,
        headerTitle: data.headerTitle,
        beginsOnDateText: data.beginsOnDateText,
        items: updatedItems,
        totals: totals,
      ),
    ));
  }

  void _onTerms(
    HomePlanConfirmationTermsPressed event,
    Emitter<HomePlanConfirmationState> emit,
  ) {
    emit(state.copyWith(openTermsRequestId: state.openTermsRequestId + 1));
  }

  void _onTermsCheckboxToggled(
    HomePlanConfirmationTermsCheckboxToggled event,
    Emitter<HomePlanConfirmationState> emit,
  ) {
    emit(state.copyWith(isTermsChecked: event.isChecked));
  }

  void _onPayNow(
    HomePlanConfirmationPayNowPressed event,
    Emitter<HomePlanConfirmationState> emit,
  ) {
    if (!state.isTermsChecked) return;

    // Future: call API to create payment intent etc.
    emit(state.copyWith(payNowRequestId: state.payNowRequestId + 1));
  }
}
