import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/purchase_prepaid_repository.dart';
import 'purchase_prepaid_event.dart';
import 'purchase_prepaid_state.dart';

class PurchasePrepaidBloc
    extends Bloc<PurchasePrepaidEvent, PurchasePrepaidState> {
  final PurchasePrepaidRepository repo;

  PurchasePrepaidBloc({required this.repo})
      : super(PurchasePrepaidState.initial()) {
    on<PurchasePrepaidStarted>(_onStarted);
    on<PurchasePrepaidItemTapped>(_onItemTapped);
    on<PurchasePrepaidNavigationConsumed>(_onNavConsumed);
  }

  Future<void> _onStarted(
      PurchasePrepaidStarted event, Emitter<PurchasePrepaidState> emit) async {
    emit(state.copyWith(
        status: PurchasePrepaidLoadStatus.loading, clearError: true));

    try {
      final items = await repo.fetchMenuItems(isPrepaid: event.isPrepaid);
      emit(state.copyWith(
        status: PurchasePrepaidLoadStatus.ready,
        items: items,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: PurchasePrepaidLoadStatus.failure,
        errorMessage: 'Failed to load purchases menu',
      ));
    }
  }

  void _onItemTapped(
    PurchasePrepaidItemTapped event,
    Emitter<PurchasePrepaidState> emit,
  ) {
    // one-shot navigation signal
    emit(state.copyWith(navigateTo: event.action));
  }

  void _onNavConsumed(PurchasePrepaidNavigationConsumed event,
      Emitter<PurchasePrepaidState> emit) {
    emit(state.copyWith(clearNavigation: true));
  }
}
