import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/top_up_payment_prepaid_repository.dart';
import 'top_up_payment_prepaid_event.dart';
import 'top_up_payment_prepaid_state.dart';

class TopUpPaymentPrepaidBloc extends Bloc<TopUpPaymentPrepaidEvent, TopUpPaymentPrepaidState> {
  final TopUpPaymentPrepaidRepository repository;

  TopUpPaymentPrepaidBloc(this.repository) : super(TopUpPaymentPrepaidState.initial()) {
    on<TopUpPaymentStarted>(_onStarted);
    on<PaymentMethodSelected>(_onSelected);
    on<PayWithCardPressed>(_onPayWithCard);
    on<PayNowPressed>(_onPayNow);
  }

  Future<void> _onStarted(
      TopUpPaymentStarted event,
      Emitter<TopUpPaymentPrepaidState> emit,
      ) async {
    emit(state.copyWith(status: TopUpPaymentStatus.loading, errorMessage: null));

    try {
      final methodsFuture = repository.fetchPaymentMethods();
      final summaryFuture = repository.fetchSummary();

      final methods = await methodsFuture;          // List<PaymentMethod>
      final summary = await summaryFuture;          // PaymentSummary

      final defaultSelected = methods.isNotEmpty ? methods.first.id : null;

      emit(state.copyWith(
        status: TopUpPaymentStatus.ready,
        methods: methods,
        summary: summary,
        selectedMethodId: defaultSelected,
      ));
    } catch (e) {
      emit(state.copyWith(status: TopUpPaymentStatus.failure, errorMessage: e.toString()));
      emit(state.copyWith(status: TopUpPaymentStatus.ready));
    }
  }

  void _onSelected(PaymentMethodSelected event, Emitter<TopUpPaymentPrepaidState> emit) {
    emit(state.copyWith(selectedMethodId: event.paymentMethodId, errorMessage: null));
  }

  void _onPayWithCard(PayWithCardPressed event, Emitter<TopUpPaymentPrepaidState> emit) {
    // Navigation handled in UI (GoRouter / Navigator)
  }

  Future<void> _onPayNow(PayNowPressed event, Emitter<TopUpPaymentPrepaidState> emit) async {
    final selectedId = state.selectedMethodId;
    if (selectedId == null) return;

    emit(state.copyWith(status: TopUpPaymentStatus.paying, errorMessage: null));
    try {
      await repository.payNow(paymentMethodId: selectedId);
      emit(state.copyWith(status: TopUpPaymentStatus.success));
      emit(state.copyWith(status: TopUpPaymentStatus.ready));
    } catch (e) {
      emit(state.copyWith(status: TopUpPaymentStatus.failure, errorMessage: e.toString()));
      emit(state.copyWith(status: TopUpPaymentStatus.ready));
    }
  }
}
