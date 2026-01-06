import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/guest_pay_bill_receipt_repository.dart';
import 'guest_pay_bill_receipt_event.dart';
import 'guest_pay_bill_receipt_state.dart';

class GuestPayBillReceiptBloc extends Bloc<GuestPayBillReceiptEvent, GuestPayBillReceiptState> {
  final GuestPayBillReceiptRepository repository;

  GuestPayBillReceiptBloc({required this.repository}) : super(GuestPayBillReceiptState.initial()) {
    on<GuestPayBillReceiptStarted>(_onStarted);
    on<GuestPayBillReceiptBackToHomePressed>(_onBackToHomePressed);
  }

  void _onStarted(GuestPayBillReceiptStarted event, Emitter<GuestPayBillReceiptState> emit) {
    emit(state.copyWith(data: event.data));
  }

  void _onBackToHomePressed(GuestPayBillReceiptBackToHomePressed event,Emitter<GuestPayBillReceiptState> emit) {
    emit(state.copyWith(backHomeRequestId: state.backHomeRequestId + 1));
  }
}
