import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/guest_top_up_receipt_repository.dart';
import 'guest_top_up_receipt_event.dart';
import 'guest_top_up_receipt_state.dart';

class GuestTopUpReceiptBloc extends Bloc<GuestTopUpReceiptEvent, GuestTopUpReceiptState> {
  final GuestTopUpReceiptRepository repository;

  GuestTopUpReceiptBloc({required this.repository}) : super(GuestTopUpReceiptState.initial()) {
    on<GuestTopUpReceiptStarted>(_onStarted);
    on<GuestTopUpReceiptBackToHomePressed>(_onBackToHomePressed);
  }

  void _onStarted(
      GuestTopUpReceiptStarted event,
      Emitter<GuestTopUpReceiptState> emit,
      ) {
    emit(state.copyWith(data: event.data));
  }

  void _onBackToHomePressed(
      GuestTopUpReceiptBackToHomePressed event,
      Emitter<GuestTopUpReceiptState> emit,
      ) {
    emit(state.copyWith(backHomeRequestId: state.backHomeRequestId + 1));
  }
}
