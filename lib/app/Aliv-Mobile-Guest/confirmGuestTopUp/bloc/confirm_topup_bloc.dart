import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/confirm_topup_repository.dart';
import 'confirm_topup_event.dart';
import 'confirm_topup_state.dart';

class GuestConfirmTopUpBloc
    extends Bloc<GuestConfirmTopUpEvent, GuestConfirmTopUpState> {
  final GuestConfirmTopUpRepository repository;

  GuestConfirmTopUpBloc({required this.repository})
      : super(GuestConfirmTopUpState.initial()) {
    on<GuestConfirmTopUpStarted>(_onStarted);
    on<GuestConfirmTopUpPayNowPressed>(_onPayNowPressed);
    on<GuestConfirmTopUpTermsPressed>(_onTermsPressed);
    on<GuestConfirmTopUpTermsCheckboxToggled>(_onTermsCheckboxToggled);
  }

  void _onTermsPressed(
    GuestConfirmTopUpTermsPressed event,
    Emitter<GuestConfirmTopUpState> emit,
  ) {
    emit(state.copyWith(termsRequestId: state.termsRequestId + 1));
  }

  void _onTermsCheckboxToggled(
    GuestConfirmTopUpTermsCheckboxToggled event,
    Emitter<GuestConfirmTopUpState> emit,
  ) {
    emit(state.copyWith(isTermsChecked: !state.isTermsChecked));
  }

  Future<void> _onStarted(
    GuestConfirmTopUpStarted event,
    Emitter<GuestConfirmTopUpState> emit,
  ) async {
    final subTotal = event.amount;
    final vat = 0.0; // design অনুযায়ী
    final total = subTotal + vat;

    emit(
      state.copyWith(
        status: GuestConfirmTopUpStatus.initial,
        phoneNumber: event.phoneNumber,
        subTotal: subTotal,
        vat: vat,
        total: total,
        errorMessage: null,
        isTermsChecked: false,
      ),
    );
  }

  Future<void> _onPayNowPressed(
    GuestConfirmTopUpPayNowPressed event,
    Emitter<GuestConfirmTopUpState> emit,
  ) async {
    if (state.status == GuestConfirmTopUpStatus.loading) return;

    emit(state.copyWith(
        status: GuestConfirmTopUpStatus.loading, errorMessage: null));

    try {
      await repository.payNow(
          phoneNumber: state.phoneNumber, amount: state.total);
      emit(state.copyWith(status: GuestConfirmTopUpStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: GuestConfirmTopUpStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
