import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/payment_summary.dart';
import '../repository/top_up_payment_prepaid_repository.dart';
import 'top_up_payment_prepaid_event.dart';
import 'top_up_payment_prepaid_state.dart';

class TopUpPaymentPrepaidBloc
    extends Bloc<TopUpPaymentPrepaidEvent, TopUpPaymentPrepaidState> {
  final TopUpPaymentPrepaidRepository repository;

  TopUpPaymentPrepaidBloc(this.repository)
    : super(TopUpPaymentPrepaidState.initial()) {
    on<TopUpPaymentStarted>(_onStarted);
    on<PaymentMethodSelected>(_onSelected);
    on<PayWithCardPressed>(_onPayWithCard);
    on<PayNowPressed>(_onPayNow);
  }

  void _onStarted(
    TopUpPaymentStarted event,
    Emitter<TopUpPaymentPrepaidState> emit,
  ) {
    final amount = event.amount ?? 0.0;
    emit(
      state.copyWith(
        status: TopUpPaymentStatus.ready,
        summary: PaymentSummary(
          total: amount,
          recipientPhone: event.recipientPhone,
          vatInclusive: false,
        ),
      ),
    );
  }

  void _onSelected(
    PaymentMethodSelected event,
    Emitter<TopUpPaymentPrepaidState> emit,
  ) {
    emit(
      state.copyWith(
        paymentMode: TopUpPaymentMode.card,
        selectedMethodId: event.paymentMethodId,
      ),
    );
  }

  void _onPayWithCard(
    PayWithCardPressed event,
    Emitter<TopUpPaymentPrepaidState> emit,
  ) {
    emit(state.copyWith(paymentMode: TopUpPaymentMode.payWithCard));
  }

  Future<void> _onPayNow(
    PayNowPressed event,
    Emitter<TopUpPaymentPrepaidState> emit,
  ) async {
    final selectedId = state.selectedMethodId;
    if (selectedId == null) return;

    emit(state.copyWith(status: TopUpPaymentStatus.paying));
    try {
      await repository.payNow(paymentMethodId: selectedId);
      emit(state.copyWith(status: TopUpPaymentStatus.success));
      emit(state.copyWith(status: TopUpPaymentStatus.ready));
    } catch (e) {
      emit(
        state.copyWith(
          status: TopUpPaymentStatus.failure,
          errorMessage: e.toString(),
        ),
      );
      emit(state.copyWith(status: TopUpPaymentStatus.ready));
    }
  }
}
