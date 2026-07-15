import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/guest_pay_bill_confirm_models.dart';
import '../repository/guest_pay_bill_confirm_repository.dart';
import 'guest_pay_bill_confirm_event.dart';
import 'guest_pay_bill_confirm_state.dart';

class GuestPayBillConfirmBloc
    extends Bloc<GuestPayBillConfirmEvent, GuestPayBillConfirmState> {
  final GuestPayBillConfirmRepository repo;

  GuestPayBillConfirmBloc({
    required GuestPayBillConfirmArgs args,
    GuestPayBillConfirmRepository? repo,
  })  : repo = repo ?? GuestPayBillConfirmRepository(),
        super(GuestPayBillConfirmState.initial(args: args)) {
    on<GuestPayBillConfirmStarted>(_onStarted);
    on<GuestPayBillConfirmPayNowPressed>(_onPayNow);
    on<GuestPayBillConfirmTermsCheckboxToggled>(_onTermsCheckboxToggled);
  }

  Future<void> _onStarted(
    GuestPayBillConfirmStarted event,
    Emitter<GuestPayBillConfirmState> emit,
  ) async {
    emit(state.copyWith(
      loadStatus: GuestPayBillConfirmLoadStatus.loading,
      errorMessage: null,
    ));

    try {
      final vat = await repo.fetchVat(
        serviceName: state.args.serviceName,
        amount: state.args.amount,
      );

      emit(state.copyWith(
        loadStatus: GuestPayBillConfirmLoadStatus.ready,
        vat: vat,
      ));
    } catch (_) {
      emit(state.copyWith(
        loadStatus: GuestPayBillConfirmLoadStatus.failure,
        errorMessage: 'Failed to load payment info',
      ));
    }
  }

  Future<void> _onPayNow(
    GuestPayBillConfirmPayNowPressed event,
    Emitter<GuestPayBillConfirmState> emit,
  ) async {
    if (state.payStatus == GuestPayBillConfirmPayStatus.loading) return;
    if (!state.isTermsChecked) {
      emit(state.copyWith(
          errorMessage: 'Please check Terms & Conditions first.'));
      return;
    }

    emit(state.copyWith(
      payStatus: GuestPayBillConfirmPayStatus.loading,
      errorMessage: null,
    ));

    try {
      await repo.payNow(
        serviceName: state.args.serviceName,
        identifierValue: state.args.identifierValue,
        totalAmount: state.total,
      );

      await instance<AnalyticsService>().logBillPayment(
        amount: state.total,
        paymentMethod: 'card',
      );
      emit(state.copyWith(payStatus: GuestPayBillConfirmPayStatus.success));
    } catch (_) {
      emit(state.copyWith(
        payStatus: GuestPayBillConfirmPayStatus.failure,
        errorMessage: 'Payment failed. Try again.',
      ));
    }
  }

  void _onTermsCheckboxToggled(
    GuestPayBillConfirmTermsCheckboxToggled event,
    Emitter<GuestPayBillConfirmState> emit,
  ) {
    emit(state.copyWith(isTermsChecked: !state.isTermsChecked));
  }
}
