import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/guest_purchase_plan_confirmation_models.dart';
import '../repository/guest_purchase_plan_confirmation_repository.dart';
import 'guest_purchase_plan_confirmation_event.dart';
import 'guest_purchase_plan_confirmation_state.dart';

class GuestPurchasePlanConfirmationBloc extends Bloc<
    GuestPurchasePlanConfirmationEvent, GuestPurchasePlanConfirmationState> {
  final GuestPurchasePlanConfirmationRepository repository;

  GuestPurchasePlanConfirmationBloc({required this.repository})
      : super(GuestPurchasePlanConfirmationState.initial()) {
    on<GuestPurchasePlanConfirmationStarted>(_onStarted);
    on<GuestPurchasePlanConfirmationRemoveItemPressed>(_onRemoveItem);
    on<GuestPurchasePlanConfirmationTermsPressed>(_onTerms);
    on<GuestPurchasePlanConfirmationPayNowPressed>(_onPayNow);
  }

  Future<void> _onStarted(
      GuestPurchasePlanConfirmationStarted event,
      Emitter<GuestPurchasePlanConfirmationState> emit,
      ) async {
    emit(state.copyWith(status: GuestPurchasePlanConfirmationStatus.loading));

    try {
      final data = await repository.load(phoneNumber: event.phoneNumber);
      emit(state.copyWith(
        status: GuestPurchasePlanConfirmationStatus.ready,
        data: data,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GuestPurchasePlanConfirmationStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onRemoveItem(
      GuestPurchasePlanConfirmationRemoveItemPressed event,
      Emitter<GuestPurchasePlanConfirmationState> emit,
      ) {
    final data = state.data;
    if (data == null) return;

    final updatedItems = data.items.where((x) => x.id != event.itemId).toList();

    final totals = PurchaseTotals(
      subTotal: updatedItems.fold<double>(0, (s, x) => s + x.price),
      vat: data.totals.vat,
    );

    emit(state.copyWith(
      data: GuestPurchasePlanConfirmationData(
        phoneNumber: data.phoneNumber,
        headerTitle: data.headerTitle,
        items: updatedItems,
        totals: totals,
      ),
    ));
  }

  void _onTerms(
      GuestPurchasePlanConfirmationTermsPressed event,
      Emitter<GuestPurchasePlanConfirmationState> emit,
      ) {
    emit(state.copyWith(openTermsRequestId: state.openTermsRequestId + 1));
  }

  void _onPayNow(
      GuestPurchasePlanConfirmationPayNowPressed event,
      Emitter<GuestPurchasePlanConfirmationState> emit,
      ) {
    // Future: call API to create payment intent etc.
    emit(state.copyWith(payNowRequestId: state.payNowRequestId + 1));
  }
}
