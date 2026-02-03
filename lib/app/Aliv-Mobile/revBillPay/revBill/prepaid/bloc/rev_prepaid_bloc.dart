import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/rev_prepaid_repository.dart';
import 'rev_prepaid_event.dart';
import 'rev_prepaid_state.dart';

class RevPrepaidBloc extends Bloc<RevPrepaidEvent, RevPrepaidState> {
  final RevPrepaidRepository repository;

  RevPrepaidBloc({required this.repository}) : super(RevPrepaidState.initial()) {
    on<RevPrepaidStarted>(_onStarted);
    on<RevAccountNumberChanged>(_onAccountChanged);
    on<RevNameChanged>(_onNameChanged);
    on<RevAmountChanged>(_onAmountChanged);
    on<RevSubmitPressed>(_onSubmit);
    on<RevProceedPressed>(_onProceed);
    on<RevNavigationConsumed>(_onNavConsumed);
  }

  void _onStarted(RevPrepaidStarted event, Emitter<RevPrepaidState> emit) {
    emit(state.copyWith(clearError: true));
  }

  void _onAccountChanged(RevAccountNumberChanged event, Emitter<RevPrepaidState> emit) {
    emit(
      state.copyWith(
        accountNumber: event.value,
        clearAccountData: true,
        clearError: true,
      ),
    );
  }

  void _onNameChanged(RevNameChanged event, Emitter<RevPrepaidState> emit) {
    emit(
      state.copyWith(
        name: event.value,
        clearAccountData: true,
        clearError: true,
      ),
    );
  }

  void _onAmountChanged(RevAmountChanged event, Emitter<RevPrepaidState> emit) {
    final parsed = _parseMoney(event.rawText, fallback: state.amount);
    emit(state.copyWith(amount: parsed, clearError: true));
  }

  Future<void> _onSubmit(RevSubmitPressed event, Emitter<RevPrepaidState> emit) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(submitting: true, clearError: true));

    try {
      final info = await repository.fetchAccountInfo(
        accountNumber: state.accountNumber.trim(),
        name: state.name.trim(),
      );

      emit(
        state.copyWith(
          submitting: false,
          accountStatus: info.status,
          accountBalance: info.balance,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          submitting: false,
          errorMessage: 'Failed to fetch account info',
          clearAccountData: true,
        ),
      );
    }
  }

  void _onProceed(RevProceedPressed event, Emitter<RevPrepaidState> emit) {
    if (!state.canProceed) return;
    emit(state.copyWith(navTarget: RevNavTarget.proceed));
  }

  void _onNavConsumed(RevNavigationConsumed event, Emitter<RevPrepaidState> emit) {
    emit(state.copyWith(navTarget: RevNavTarget.none));
  }

  double _parseMoney(String raw, {required double fallback}) {
    final cleaned = raw.replaceAll('\$', '').replaceAll(' ', '').trim();
    final v = double.tryParse(cleaned);
    return v ?? fallback;
  }
}
