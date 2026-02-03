import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/make_payment_confirmation_postpaid_repository.dart';
import 'make_payment_confirmation_postpaid_event.dart';
import 'make_payment_confirmation_postpaid_state.dart';

class MakePaymentConfirmationPostPaidBloc extends Bloc<
    MakePaymentConfirmationPostPaidEvent, MakePaymentConfirmationPostPaidState> {
  final MakePaymentConfirmationPostPaidRepository repository;

  MakePaymentConfirmationPostPaidBloc({required this.repository})
      : super(MakePaymentConfirmationPostPaidState.initial()) {
    on<MakePaymentConfirmationPostPaidStarted>(_onStarted);
    on<MakePaymentPromoCodeChanged>(_onPromoChanged);
    on<MakePaymentPromoApplyPressed>(_onApplyPromo);
    on<MakePaymentContinuePressed>(_onContinue);
    on<MakePaymentNavConsumed>(_onNavConsumed);
  }

  Future<void> _onStarted(
    MakePaymentConfirmationPostPaidStarted event,
    Emitter<MakePaymentConfirmationPostPaidState> emit,
  ) async {
    final data = await repository.fetchConfirmation();

    emit(
      state.copyWith(
        title: data.title,
        customerName: data.customerName,
        accountNumber: data.accountNumber,
        headerLabel: data.headerLabel,
        amountPill: data.amountPill,
        subtotal: data.subtotal,
        vat: data.vat,
        total: data.total,
        bottomSubtitle: data.bottomSubtitle,
        bottomAmount: data.bottomAmount,
      ),
    );
  }

  void _onPromoChanged(
    MakePaymentPromoCodeChanged event,
    Emitter<MakePaymentConfirmationPostPaidState> emit,
  ) {
    final trimmed = event.value.trim();
    emit(
      state.copyWith(
        promoCode: event.value,
        canApplyPromo: trimmed.isNotEmpty,
      ),
    );
  }

  Future<void> _onApplyPromo(
    MakePaymentPromoApplyPressed event,
    Emitter<MakePaymentConfirmationPostPaidState> emit,
  ) async {
    if (!state.canApplyPromo) return;
    await repository.applyPromo(code: state.promoCode.trim());
  }

  void _onContinue(
    MakePaymentContinuePressed event,
    Emitter<MakePaymentConfirmationPostPaidState> emit,
  ) {
    emit(state.copyWith(navTarget: MakePaymentConfirmationNavTarget.next));
  }

  void _onNavConsumed(
    MakePaymentNavConsumed event,
    Emitter<MakePaymentConfirmationPostPaidState> emit,
  ) {
    emit(state.copyWith(navTarget: MakePaymentConfirmationNavTarget.none));
  }
}
