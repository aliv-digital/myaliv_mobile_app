import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/confirm_top_up_prepaid_repository.dart';
import 'confirm_top_up_prepaid_event.dart';
import 'confirm_top_up_prepaid_state.dart';

class ConfirmTopUpPrepaidBloc extends Bloc<ConfirmTopUpPrepaidEvent, ConfirmTopUpPrepaidState> {
  final ConfirmTopUpPrepaidRepository repository;

  ConfirmTopUpPrepaidBloc(this.repository) : super(ConfirmTopUpPrepaidState.initial()) {
    on<ConfirmTopUpStarted>(_onStarted);
    on<PromoCodeChanged>(_onPromoChanged);
    on<PromoCodeApplied>(_onPromoApplied);
    on<ContinuePressed>(_onContinuePressed);
    on<TermsPressed>(_onTermsPressed);
  }

  Future<void> _onStarted(ConfirmTopUpStarted event, Emitter<ConfirmTopUpPrepaidState> emit) async {
    emit(state.copyWith(
      status: ConfirmTopUpStatus.loading,
      customerName: event.customerName,
      customerPhone: event.customerPhone,
      amount: event.amount,
      errorMessage: null,
    ));

    try {
      final breakdown = await repository.getInitialBreakdown(amount: event.amount);
      emit(state.copyWith(status: ConfirmTopUpStatus.ready, breakdown: breakdown));
    } catch (e) {
      emit(state.copyWith(status: ConfirmTopUpStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onPromoChanged(PromoCodeChanged event, Emitter<ConfirmTopUpPrepaidState> emit) {
    emit(state.copyWith(promoCode: event.promoCode, errorMessage: null));
  }

  Future<void> _onPromoApplied(PromoCodeApplied event, Emitter<ConfirmTopUpPrepaidState> emit) async {
    final promo = state.promoCode.trim();
    if (promo.isEmpty) return;

    emit(state.copyWith(status: ConfirmTopUpStatus.applyingPromo, errorMessage: null));

    try {
      final breakdown = await repository.applyPromoCode(amount: state.amount, promoCode: promo);
      emit(state.copyWith(
        status: ConfirmTopUpStatus.ready,
        breakdown: breakdown,
        appliedPromoCode: promo,
      ));
    } catch (e) {
      emit(state.copyWith(status: ConfirmTopUpStatus.ready, errorMessage: e.toString()));
    }
  }

  Future<void> _onContinuePressed(ContinuePressed event, Emitter<ConfirmTopUpPrepaidState> emit) async {
    emit(state.copyWith(status: ConfirmTopUpStatus.submitting, errorMessage: null));

    try {
      await repository.confirmTopUp(
        customerName: state.customerName,
        customerPhone: state.customerPhone,
        amount: state.amount,
        promoCode: state.appliedPromoCode,
      );
      emit(state.copyWith(status: ConfirmTopUpStatus.success));
      emit(state.copyWith(status: ConfirmTopUpStatus.ready)); // keep UI usable
    } catch (e) {
      emit(state.copyWith(status: ConfirmTopUpStatus.failure, errorMessage: e.toString()));
      emit(state.copyWith(status: ConfirmTopUpStatus.ready));
    }
  }

  void _onTermsPressed(TermsPressed event, Emitter<ConfirmTopUpPrepaidState> emit) {
    // Navigation should be handled by UI layer (GoRouter) using listener.
    // We keep this event to keep "intent" testable.
  }
}
