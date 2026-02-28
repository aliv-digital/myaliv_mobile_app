import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/home_plan_purchase_receipt_repository.dart';
import 'home_plan_purchase_receipt_event.dart';
import 'home_plan_purchase_receipt_state.dart';

class HomePlanPurchaseReceiptBloc
    extends Bloc<HomePlanPurchaseReceiptEvent, HomePlanPurchaseReceiptState> {
  final HomePlanPurchaseReceiptRepository repository;

  HomePlanPurchaseReceiptBloc({required this.repository})
      : super(HomePlanPurchaseReceiptState.initial()) {
    on<HomePlanPurchaseReceiptStarted>(_onStarted);
    on<HomePlanPurchaseReceiptBackToHomePressed>(_onBackToHomePressed);
  }

  void _onStarted(
    HomePlanPurchaseReceiptStarted event,
    Emitter<HomePlanPurchaseReceiptState> emit,
  ) {
    emit(state.copyWith(data: event.data));
  }

  void _onBackToHomePressed(
    HomePlanPurchaseReceiptBackToHomePressed event,
    Emitter<HomePlanPurchaseReceiptState> emit,
  ) {
    emit(state.copyWith(backHomeRequestId: state.backHomeRequestId + 1));
  }
}
