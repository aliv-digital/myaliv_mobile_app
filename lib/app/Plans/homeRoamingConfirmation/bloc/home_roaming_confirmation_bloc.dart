import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/home_roaming_confirmation_models.dart';
import '../repository/home_roaming_confirmation_repository.dart';
import 'home_roaming_confirmation_event.dart';
import 'home_roaming_confirmation_state.dart';

class HomeRoamingConfirmationBloc
    extends Bloc<HomeRoamingConfirmationEvent, HomeRoamingConfirmationState> {
  final HomeRoamingConfirmationRepository repository;

  HomeRoamingConfirmationBloc({required this.repository})
      : super(HomeRoamingConfirmationState.initial()) {
    on<HomeRoamingConfirmationStarted>(_onStarted);
    on<HomeRoamingConfirmationRemoveItemPressed>(_onRemoveItem);
    on<HomeRoamingConfirmationTermsPressed>(_onTerms);
    on<HomeRoamingConfirmationTermsCheckboxToggled>(
      _onTermsCheckboxToggled,
    );
    on<HomeRoamingConfirmationPayNowPressed>(_onPayNow);
  }

  Future<void> _onStarted(
    HomeRoamingConfirmationStarted event,
    Emitter<HomeRoamingConfirmationState> emit,
  ) async {
    emit(state.copyWith(status: HomeRoamingConfirmationStatus.loading));

    try {
      final data = await repository.load(phoneNumber: event.phoneNumber);
      emit(state.copyWith(
        status: HomeRoamingConfirmationStatus.ready,
        data: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeRoamingConfirmationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onRemoveItem(
    HomeRoamingConfirmationRemoveItemPressed event,
    Emitter<HomeRoamingConfirmationState> emit,
  ) {
    final data = state.data;
    if (data == null) return;

    final updatedItems = data.items.where((x) => x.id != event.itemId).toList();

    final totals = HomeRoamingConfirmationPurchaseTotals(
      subTotal: updatedItems.fold<double>(0, (s, x) => s + x.price),
      vat: data.totals.vat,
    );

    emit(state.copyWith(
      data: HomeRoamingConfirmationData(
        phoneNumber: data.phoneNumber,
        headerTitle: data.headerTitle,
        beginsOnDateText: data.beginsOnDateText,
        items: updatedItems,
        totals: totals,
      ),
    ));
  }

  void _onTerms(
    HomeRoamingConfirmationTermsPressed event,
    Emitter<HomeRoamingConfirmationState> emit,
  ) {
    emit(state.copyWith(openTermsRequestId: state.openTermsRequestId + 1));
  }

  void _onTermsCheckboxToggled(
    HomeRoamingConfirmationTermsCheckboxToggled event,
    Emitter<HomeRoamingConfirmationState> emit,
  ) {
    emit(state.copyWith(isTermsChecked: event.isChecked));
  }

  void _onPayNow(
    HomeRoamingConfirmationPayNowPressed event,
    Emitter<HomeRoamingConfirmationState> emit,
  ) {
    if (!state.isTermsChecked) return;

    // Future: call API to create payment intent etc.
    emit(state.copyWith(payNowRequestId: state.payNowRequestId + 1));
  }
}
