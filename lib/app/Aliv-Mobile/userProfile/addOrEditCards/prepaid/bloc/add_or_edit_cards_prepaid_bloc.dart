import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/add_or_edit_cards_prepaid_repository.dart';
import 'add_or_edit_cards_prepaid_event.dart';
import 'add_or_edit_cards_prepaid_state.dart';

class AddOrEditCardsPrepaidBloc
    extends Bloc<AddOrEditCardsPrepaidEvent, AddOrEditCardsPrepaidState> {
  final AddOrEditCardsPrepaidRepository repo;

  AddOrEditCardsPrepaidBloc({AddOrEditCardsPrepaidRepository? repo})
      : repo = repo ?? AddOrEditCardsPrepaidRepository(),
        super(AddOrEditCardsPrepaidState.initial()) {
    on<AddOrEditCardsPrepaidStarted>(_onStarted);
    on<AddOrEditCardsPrepaidDeletePressed>(_onDeletePressed);
    on<AddOrEditCardsPrepaidAddNewCardPressed>(_onAddNewPressed);
    on<AddOrEditCardsPrepaidSaveCardPressed>(_onSaveCardPressed); // ✅ FIX
    on<AddOrEditCardsPrepaidHomePressed>(_onHomePressed);
    on<AddOrEditCardsPrepaidNavigationConsumed>(_onNavConsumed);
  }

  Future<void> _onStarted(
      AddOrEditCardsPrepaidStarted event,
      Emitter<AddOrEditCardsPrepaidState> emit,
      ) async {
    emit(state.copyWith(
      loadStatus: AddOrEditCardsPrepaidLoadStatus.loading,
      clearError: true,
    ));

    try {
      final cards = await repo.fetchSavedCards();
      emit(state.copyWith(
        loadStatus: AddOrEditCardsPrepaidLoadStatus.ready,
        cards: cards,
      ));
    } catch (_) {
      emit(state.copyWith(
        loadStatus: AddOrEditCardsPrepaidLoadStatus.failure,
        errorMessage: 'Failed to load cards',
      ));
    }
  }

  Future<void> _onDeletePressed(
      AddOrEditCardsPrepaidDeletePressed event,
      Emitter<AddOrEditCardsPrepaidState> emit,
      ) async {
    if (state.deletingIds.contains(event.cardId)) return;

    emit(state.copyWith(
      deletingIds: {...state.deletingIds, event.cardId},
      clearError: true,
    ));

    try {
      await repo.deleteCard(event.cardId);

      final updated = state.cards.where((c) => c.id != event.cardId).toList();
      final afterDelete = {...state.deletingIds}..remove(event.cardId);

      emit(state.copyWith(cards: updated, deletingIds: afterDelete));
    } catch (_) {
      final afterDelete = {...state.deletingIds}..remove(event.cardId);
      emit(state.copyWith(
        deletingIds: afterDelete,
        errorMessage: 'Failed to delete card',
      ));
    }
  }

  void _onAddNewPressed(
      AddOrEditCardsPrepaidAddNewCardPressed event,
      Emitter<AddOrEditCardsPrepaidState> emit,
      ) {
    /// UI Listener এই navTarget দেখে BottomSheet খুলবে
    emit(state.copyWith(
      navTarget: AddOrEditCardsPrepaidNavTarget.addCard,
      clearError: true,
    ));
  }

  Future<void> _onSaveCardPressed(
      AddOrEditCardsPrepaidSaveCardPressed event,
      Emitter<AddOrEditCardsPrepaidState> emit,
      ) async {
    if (state.savingNewCard) return;

    emit(state.copyWith(savingNewCard: true, clearError: true));

    try {
      final newCard = await repo.saveCard(month: event.month, year: event.year);
      final updated = [...state.cards, newCard];

      emit(state.copyWith(cards: updated, savingNewCard: false));
    } catch (_) {
      emit(state.copyWith(
        savingNewCard: false,
        errorMessage: 'Failed to save card',
      ));
    }
  }

  void _onHomePressed(
      AddOrEditCardsPrepaidHomePressed event,
      Emitter<AddOrEditCardsPrepaidState> emit,
      ) {
    emit(state.copyWith(
      navTarget: AddOrEditCardsPrepaidNavTarget.home,
      clearError: true,
    ));
  }

  void _onNavConsumed(
      AddOrEditCardsPrepaidNavigationConsumed event,
      Emitter<AddOrEditCardsPrepaidState> emit,
      ) {
    if (state.navTarget == AddOrEditCardsPrepaidNavTarget.none) return;
    emit(state.copyWith(navTarget: AddOrEditCardsPrepaidNavTarget.none));
  }
}
