import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';

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
    on<MpPayNowPressed>(_onPayNow);
    on<MpNavConsumed>(_onNavConsumed);
  }

  Future<void> _onStarted(
    MakePaymentPostPaidStarted event,
    Emitter<MakePaymentPostPaidState> emit,
  ) async {
    final data = await repository.fetchPaymentData();
    final balanceState = instance<BalanceCubit>().state;
    final amount = '\$ ${balanceState.walletBalanceFormatted}';

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
    emit(state.copyWith(selectedMethodToken: event.token));
  }

  void _onPayNow(
    MpPayNowPressed event,
    Emitter<MakePaymentPostPaidState> emit,
  ) {
    if (!state.canPayNow) return;
    emit(state.copyWith(navTarget: MpNavTarget.next));
  }

  void _onNavConsumed(
    MpNavConsumed event,
    Emitter<MakePaymentPostPaidState> emit,
  ) {
    emit(state.copyWith(navTarget: MpNavTarget.none));
  }
}
