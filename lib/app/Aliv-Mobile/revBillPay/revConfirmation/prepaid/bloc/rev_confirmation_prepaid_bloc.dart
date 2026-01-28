import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/rev_confirmation_prepaid_repository.dart';
import 'rev_confirmation_prepaid_event.dart';
import 'rev_confirmation_prepaid_state.dart';

class RevConfirmationPrepaidBloc
    extends Bloc<RevConfirmationPrepaidEvent, RevConfirmationPrepaidState> {
  final RevConfirmationPrepaidRepository repository;

  RevConfirmationPrepaidBloc({required this.repository})
      : super(RevConfirmationPrepaidState.initial()) {
    on<RevConfirmationStarted>(_onStarted);
    on<RevPromoCodeChanged>(_onPromoChanged);
    on<RevPromoApplyPressed>(_onApplyPromo);
    on<RevContinuePressed>(_onContinue);
    on<RevNavConsumed>(_onNavConsumed);
  }

  Future<void> _onStarted(
      RevConfirmationStarted event,
      Emitter<RevConfirmationPrepaidState> emit,
      ) async {
    final data = await repository.fetchConfirmation();

    emit(
      state.copyWith(
        customerName: data.customerName,
        service: data.service,
        accountNumber: data.accountNumber,
        subtotal: data.amount,
        vat: data.vat,
        discount: 0,
      ),
    );
  }

  void _onPromoChanged(
      RevPromoCodeChanged event,
      Emitter<RevConfirmationPrepaidState> emit,
      ) {
    emit(
      state.copyWith(
        promoCode: event.value,
        promoStatus: RevPromoStatus.idle,
        discount: 0, // reset discount when code changes
      ),
    );
  }

  Future<void> _onApplyPromo(
      RevPromoApplyPressed event,
      Emitter<RevConfirmationPrepaidState> emit,
      ) async {
    if (!state.canApplyPromo) return;

    emit(state.copyWith(promoStatus: RevPromoStatus.applying));

    final result = await repository.applyPromo(
      code: state.promoCode,
      subtotal: state.subtotal,
    );

    if (result.discount > 0) {
      emit(
        state.copyWith(
          discount: result.discount,
          promoStatus: RevPromoStatus.applied,
        ),
      );
    } else {
      emit(
        state.copyWith(
          discount: 0,
          promoStatus: RevPromoStatus.invalid,
        ),
      );
    }
  }

  void _onContinue(
      RevContinuePressed event,
      Emitter<RevConfirmationPrepaidState> emit,
      ) {
    emit(state.copyWith(navTarget: RevConfirmNavTarget.continueNext));
  }

  void _onNavConsumed(
      RevNavConsumed event,
      Emitter<RevConfirmationPrepaidState> emit,
      ) {
    emit(state.copyWith(navTarget: RevConfirmNavTarget.none));
  }
}
