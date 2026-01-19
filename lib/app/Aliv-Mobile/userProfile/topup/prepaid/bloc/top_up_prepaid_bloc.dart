import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/top_up_prepaid_repository.dart';
import 'top_up_prepaid_event.dart';
import 'top_up_prepaid_state.dart';

class TopUpPrepaidBloc extends Bloc<TopUpPrepaidEvent, TopUpPrepaidState> {
  final TopUpPrepaidRepository repo;

  TopUpPrepaidBloc({TopUpPrepaidRepository? repo})
      : repo = repo ?? TopUpPrepaidRepository(),
        super(TopUpPrepaidState.initial()) {
    on<TopUpPrepaidStarted>(_onStarted);
    on<TopUpPrepaidTabChanged>(_onTabChanged);
    on<TopUpPrepaidAmountChanged>(_onAmountChanged);
    on<TopUpPrepaidTopUpPressed>(_onTopUpPressed);
  }

  Future<void> _onStarted(
      TopUpPrepaidStarted event,
      Emitter<TopUpPrepaidState> emit,
      ) async {
    emit(state.copyWith(loadStatus: TopUpPrepaidLoadStatus.loading, clearError: true));
    try {
      final balance = await repo.fetchCurrentBalance();
      emit(state.copyWith(loadStatus: TopUpPrepaidLoadStatus.ready, balance: balance));
    } catch (_) {
      emit(state.copyWith(loadStatus: TopUpPrepaidLoadStatus.failure, errorMessage: 'Failed to load data'));
    }
  }

  void _onTabChanged(
      TopUpPrepaidTabChanged event,
      Emitter<TopUpPrepaidState> emit,
      ) {
    // ✅ keep amount/balance, just update selected tab
    emit(state.copyWith(selectedTabIndex: event.index, clearError: true));
  }

  void _onAmountChanged(
      TopUpPrepaidAmountChanged event,
      Emitter<TopUpPrepaidState> emit,
      ) {
    emit(state.copyWith(amountText: event.value, clearError: true));
  }

  Future<void> _onTopUpPressed(
      TopUpPrepaidTopUpPressed event,
      Emitter<TopUpPrepaidState> emit,
      ) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(submitStatus: TopUpPrepaidSubmitStatus.loading, clearError: true));
    try {
      await repo.topUp(amount: state.amountValue);
      emit(state.copyWith(submitStatus: TopUpPrepaidSubmitStatus.success));
      // optional: reset amount after success
      emit(state.copyWith(submitStatus: TopUpPrepaidSubmitStatus.idle, amountText: '0.00'));
    } catch (_) {
      emit(state.copyWith(
        submitStatus: TopUpPrepaidSubmitStatus.failure,
        errorMessage: 'Top up failed. Try again.',
      ));
    }
  }
}
