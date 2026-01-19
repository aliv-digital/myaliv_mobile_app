import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/top_up_prepaid_number_postpaid_repository.dart';
import 'top_up_prepaid_number_postpaid_event.dart';
import 'top_up_prepaid_number_postpaid_state.dart';

class TopUpPrepaidNumberPostPaidBloc
    extends Bloc<TopUpPrepaidNumberPostPaidEvent, TopUpPrepaidNumberPostPaidState> {
  final TopUpPrepaidNumberPostPaidRepository repo;

  TopUpPrepaidNumberPostPaidBloc({TopUpPrepaidNumberPostPaidRepository? repo})
      : repo = repo ?? TopUpPrepaidNumberPostPaidRepository(),
        super(TopUpPrepaidNumberPostPaidState.initial()) {
    on<TopUpPrepaidNumberPostPaidStarted>(_onStarted);
    on<TopUpPrepaidNumberPostPaidNumberChanged>(_onNumberChanged);
    on<TopUpPrepaidNumberPostPaidConfirmNumberChanged>(_onConfirmNumberChanged);
    on<TopUpPrepaidNumberPostPaidAmountChanged>(_onAmountChanged);
    on<TopUpPrepaidNumberPostPaidApplyPressed>(_onApplyPressed);
  }

  Future<void> _onStarted(
      TopUpPrepaidNumberPostPaidStarted event,
      Emitter<TopUpPrepaidNumberPostPaidState> emit,
      ) async {
    emit(state.copyWith(loadStatus: TopUpPrepaidNumberPostPaidLoadStatus.loading, clearError: true));
    // If you need initial data later, load here.
    await Future.delayed(const Duration(milliseconds: 150));
    emit(state.copyWith(loadStatus: TopUpPrepaidNumberPostPaidLoadStatus.ready));
  }

  void _onNumberChanged(
      TopUpPrepaidNumberPostPaidNumberChanged event,
      Emitter<TopUpPrepaidNumberPostPaidState> emit,
      ) {
    emit(state.copyWith(number: event.value, applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.idle, clearError: true));
  }

  void _onConfirmNumberChanged(
      TopUpPrepaidNumberPostPaidConfirmNumberChanged event,
      Emitter<TopUpPrepaidNumberPostPaidState> emit,
      ) {
    emit(state.copyWith(confirmNumber: event.value, applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.idle, clearError: true));
  }

  void _onAmountChanged(
      TopUpPrepaidNumberPostPaidAmountChanged event,
      Emitter<TopUpPrepaidNumberPostPaidState> emit,
      ) {
    emit(state.copyWith(amountText: event.value, applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.idle, clearError: true));
  }

  Future<void> _onApplyPressed(
      TopUpPrepaidNumberPostPaidApplyPressed event,
      Emitter<TopUpPrepaidNumberPostPaidState> emit,
      ) async {
    if (!state.canApply) return;

    emit(state.copyWith(applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.loading, clearError: true));

    try {
      await repo.applyTopUp(
        number: state.number.trim(),
        amount: state.amountValue,
      );

      emit(state.copyWith(applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.success));
    } catch (_) {
      emit(state.copyWith(
        applyStatus: TopUpPrepaidNumberPostPaidApplyStatus.failure,
        errorMessage: 'Failed to apply top up. Please try again.',
      ));
    }
  }
}
