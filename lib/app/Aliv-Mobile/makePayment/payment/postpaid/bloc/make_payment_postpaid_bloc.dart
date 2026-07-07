import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/common/services/balance_currency_formatter_service.dart';

import '../repository/make_payment_postpaid_repository.dart';
import 'make_payment_postpaid_event.dart';
import 'make_payment_postpaid_state.dart';

class MakePaymentPostPaidBloc
    extends Bloc<MakePaymentPostPaidEvent, MakePaymentPostPaidState> {
  final MakePaymentPostPaidRepository repository;

  MakePaymentPostPaidBloc({required this.repository})
      : super(MakePaymentPostPaidState.initial()) {
    on<MakePaymentPostPaidStarted>(_onStarted);
    on<MpAmountOptionChanged>(_onAmountOptionChanged);
    on<MpCustomAmountChanged>(_onCustomAmountChanged);
    on<MpTermsToggled>(_onTermsToggled);
    on<MpPaymentMethodSelected>(_onMethodSelected);
    on<MpPayWithCardSelected>(_onPayWithCardSelected);
    on<MpPayNowPressed>(_onPayNow);
    on<MpPaySavedCardConfirmed>(_onPaySavedCardConfirmed);
    on<MpPayWithCardConfirmed>(_onPayWithCardConfirmed);
    on<MpNavConsumed>(_onNavConsumed);
  }

  Future<void> _onStarted(
    MakePaymentPostPaidStarted event,
    Emitter<MakePaymentPostPaidState> emit,
  ) async {
    final data = await repository.fetchPaymentData();
    final balanceState = instance<BalanceCubit>().state;
    final amount = BalanceCurrencyFormatterService.format(
      balanceState.walletBalance,
    );

    emit(
      state.copyWith(
        title: data.title,
        paymentDueAmount: amount,
        bottomAmount: amount,
        bottomSubtitle: data.bottomSubtitle,
      ),
    );
  }

  void _onAmountOptionChanged(
    MpAmountOptionChanged event,
    Emitter<MakePaymentPostPaidState> emit,
  ) {
    emit(state.copyWith(amountOption: event.option));
  }

  void _onCustomAmountChanged(
    MpCustomAmountChanged event,
    Emitter<MakePaymentPostPaidState> emit,
  ) {
    emit(state.copyWith(customAmount: event.value));
  }

  void _onTermsToggled(
    MpTermsToggled event,
    Emitter<MakePaymentPostPaidState> emit,
  ) {
    emit(state.copyWith(termsAccepted: event.value));
  }

  void _onMethodSelected(
    MpPaymentMethodSelected event,
    Emitter<MakePaymentPostPaidState> emit,
  ) {
    emit(
      state.copyWith(
        paymentMode: MpPaymentMode.card,
        selectedMethodToken: event.token,
      ),
    );
  }

  void _onPayWithCardSelected(
    MpPayWithCardSelected event,
    Emitter<MakePaymentPostPaidState> emit,
  ) {
    emit(state.copyWith(paymentMode: MpPaymentMode.payWithCard));
  }

  /// Legacy intent slot — the view now uses this only to gate whether
  /// the confirmation sheet should open (via `state.canPayNow`). The
  /// actual API call fires from [MpPaySavedCardConfirmed] /
  /// [MpPayWithCardConfirmed] once the sheet is confirmed.
  void _onPayNow(
    MpPayNowPressed event,
    Emitter<MakePaymentPostPaidState> emit,
  ) {
    if (!state.canPayNow) return;
    final target = state.paymentMode == MpPaymentMode.payWithCard
        ? MpNavTarget.addCard
        : MpNavTarget.next;
    emit(state.copyWith(navTarget: target));
  }

  Future<void> _onPaySavedCardConfirmed(
    MpPaySavedCardConfirmed event,
    Emitter<MakePaymentPostPaidState> emit,
  ) async {
    final token = state.selectedMethodToken?.trim() ?? '';
    if (token.isEmpty) {
      emit(
        state.copyWith(
          status: MpPaymentStatus.failure,
          errorMessage: 'Please select a saved card first.',
        ),
      );
      return;
    }

    await _submit(
      emit,
      () => repository.payWithSavedCard(
        amount: _amountToCharge(),
        cardToken: token,
      ),
      'Payment failed. Try again.',
    );
  }

  Future<void> _onPayWithCardConfirmed(
    MpPayWithCardConfirmed event,
    Emitter<MakePaymentPostPaidState> emit,
  ) async {
    // Stash the details so the success side-effect can forward them to
    // the receipt as `cardToSave` for the save-card affordance.
    emit(state.copyWith(lastNewCardDetails: event.details));
    await _submit(
      emit,
      () => repository.payWithNewCard(
        amount: _amountToCharge(),
        details: event.details,
      ),
      'Payment failed. Try again.',
    );
  }

  /// The amount actually posted to the server:
  /// - "other amount" + a parsable positive value → custom amount
  /// - otherwise → wallet balance from [BalanceCubit]
  ///
  /// Mirrors the view-side `_resolvePayAmount` used to render the bottom bar;
  /// keeping the source of truth in the bloc avoids a stale-amount race if
  /// balance refreshes between render and submit.
  double _amountToCharge() {
    if (state.amountOption == MpAmountOption.other) {
      final parsed = double.tryParse(state.customAmount.trim());
      if (parsed != null && parsed > 0) return parsed;
    }
    return instance<BalanceCubit>().state.walletBalance;
  }

  /// Shared submit → success/failure transition for both funding paths.
  /// Guards against double-submits, maps exceptions onto `errorMessage`,
  /// and arms the nav target on success so the view can push the receipt.
  Future<void> _submit(
    Emitter<MakePaymentPostPaidState> emit,
    Future<bool> Function() invoke,
    String failureFallback,
  ) async {
    if (state.status == MpPaymentStatus.paying) return;

    emit(
      state.copyWith(
        status: MpPaymentStatus.paying,
        clearErrorMessage: true,
      ),
    );

    try {
      final ok = await invoke();
      emit(
        state.copyWith(
          status: ok ? MpPaymentStatus.success : MpPaymentStatus.failure,
          navTarget: ok ? MpNavTarget.paid : MpNavTarget.none,
          errorMessage: ok ? null : failureFallback,
          clearErrorMessage: ok,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: MpPaymentStatus.failure,
          errorMessage: _cleanErrorMessage(error, fallback: failureFallback),
        ),
      );
    }
  }

  String _cleanErrorMessage(Object error, {required String fallback}) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    return message.isEmpty ? fallback : message;
  }

  void _onNavConsumed(
    MpNavConsumed event,
    Emitter<MakePaymentPostPaidState> emit,
  ) {
    emit(state.copyWith(navTarget: MpNavTarget.none));
  }
}
