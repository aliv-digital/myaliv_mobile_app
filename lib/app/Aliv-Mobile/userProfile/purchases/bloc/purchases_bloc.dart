import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/purchases_repository.dart';
import 'purchases_event.dart';
import 'purchases_state.dart';

class PurchasesBloc extends Bloc<PurchasesEvent, PurchasesState> {
  final PurchasesRepository repo;

  PurchasesBloc({required this.repo}) : super(PurchasesState.initial()) {
    on<PurchasesStarted>(_onStarted);
    on<PurchasesItemTapped>(_onItemTapped);
    on<PurchasesNavigationConsumed>(_onNavConsumed);
  }

  Future<void> _onStarted(
    PurchasesStarted event,
    Emitter<PurchasesState> emit,
  ) async {
    emit(state.copyWith(status: PurchasesLoadStatus.loading, clearError: true));

    try {
      final items = await repo.fetchMenuItems(isPrepaid: event.isPrepaid);
      emit(state.copyWith(status: PurchasesLoadStatus.ready, items: items));
    } catch (_) {
      emit(
        state.copyWith(
          status: PurchasesLoadStatus.failure,
          errorMessage: 'Failed to load purchases menu',
        ),
      );
    }
  }

  void _onItemTapped(PurchasesItemTapped event, Emitter<PurchasesState> emit) {
    // one-shot navigation signal
    emit(state.copyWith(navigateTo: event.action));
  }

  void _onNavConsumed(
    PurchasesNavigationConsumed event,
    Emitter<PurchasesState> emit,
  ) {
    emit(state.copyWith(clearNavigation: true));
  }
}
