import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/guest_purchase_plan_receipt_repository.dart';
import 'guest_purchase_plan_receipt_event.dart';
import 'guest_purchase_plan_receipt_state.dart';



class GuestPurchasePlanReceiptBloc
    extends Bloc<GuestPurchasePlanReceiptEvent, GuestPurchasePlanReceiptState> {
  final GuestPurchasePlanReceiptRepository repository;

  GuestPurchasePlanReceiptBloc({required this.repository})
      : super(GuestPurchasePlanReceiptState.initial()) {
    on<GuestPurchasePlanReceiptStarted>(_onStarted);
    on<GuestPurchasePlanReceiptBackToHomePressed>(_onBackToHomePressed);
  }

  void _onStarted(
      GuestPurchasePlanReceiptStarted event,
      Emitter<GuestPurchasePlanReceiptState> emit,
      ) {
    emit(state.copyWith(data: event.data));
  }

  void _onBackToHomePressed(
      GuestPurchasePlanReceiptBackToHomePressed event,
      Emitter<GuestPurchasePlanReceiptState> emit,
      ) {
    emit(state.copyWith(backHomeRequestId: state.backHomeRequestId + 1));
  }
}
