import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/saved_card_model.dart';
import '../repository/saved_cards_exception.dart';
import '../repository/saved_cards_repository.dart';
import 'saved_cards_state.dart';

/// Cubit for managing saved credit cards state.
///
/// This is a global singleton that can be accessed anywhere in the app
/// via GetIt (`instance<SavedCardsCubit>()`) or via BlocProvider.
///
/// Features:
/// - Fetches saved cards from the API
/// - Caches data with a 5-minute TTL
/// - Provides loading, success, and failure states
class SavedCardsCubit extends Cubit<SavedCardsState> {
  SavedCardsCubit({
    required SavedCardsRepository repository,
  })  : _repository = repository,
        super(SavedCardsState.initial());

  final SavedCardsRepository _repository;

  /// Fetches saved cards from the API.
  ///
  /// Uses cached data if available and not stale (5-minute TTL).
  /// Set [forceRefresh] to true to bypass the cache.
  Future<void> fetchSavedCards({bool forceRefresh = false}) async {
    // Use cache if available and not stale
    if (!forceRefresh && state.hasCards && !state.isCacheStale()) {
      if (kDebugMode) {
        debugPrint('SavedCardsCubit: Using cached cards data');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('SavedCardsCubit: Fetching saved cards from server');
    }

    _safeEmit(state.copyWith(
      status: SavedCardsStatus.loading,
      clearError: true,
    ));

    try {
      final cards = await _repository.fetchSavedCards();

      _safeEmit(state.copyWith(
        status: SavedCardsStatus.success,
        cards: cards,
        lastFetchedAt: DateTime.now(),
      ));

      if (kDebugMode) {
        debugPrint('SavedCardsCubit: Fetched ${cards.length} cards');
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);

      if (kDebugMode) {
        debugPrint('SavedCardsCubit: Error fetching cards - $errorMessage');
      }

      _safeEmit(state.copyWith(
        status: SavedCardsStatus.failure,
        errorMessage: errorMessage,
      ));
    }
  }

  /// Refreshes saved cards by forcing a fetch from the API.
  Future<void> refreshSavedCards() async {
    await fetchSavedCards(forceRefresh: true);
  }

  /// Removes a saved card optimistically.
  ///
  /// 1. Removes the card from local state immediately (no refetch).
  /// 2. Calls the DELETE endpoint.
  /// 3. On success: clears the per-token spinner and leaves the list as-is.
  /// 4. On failure: re-inserts the card at its original index and surfaces
  ///    an [errorMessage] without flipping [status] to failure, so existing
  ///    list/error UIs are unaffected.
  Future<void> removeCard(String token) async {
    if (token.isEmpty) return;
    if (state.removingTokens.contains(token)) return;

    final originalCards = state.cards;
    final originalIndex = originalCards.indexWhere((c) => c.token == token);
    if (originalIndex == -1) return;
    final card = originalCards[originalIndex];

    final optimisticCards = List<SavedCardModel>.from(originalCards)
      ..removeAt(originalIndex);

    _safeEmit(state.copyWith(
      cards: optimisticCards,
      removingTokens: {...state.removingTokens, token},
      clearError: true,
    ));

    try {
      await _repository.deleteCard(token);

      _safeEmit(state.copyWith(
        removingTokens: {...state.removingTokens}..remove(token),
      ));

      if (kDebugMode) {
        debugPrint('SavedCardsCubit: Removed card $token');
      }
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);

      if (kDebugMode) {
        debugPrint('SavedCardsCubit: Failed to remove card - $errorMessage');
      }

      final rolledBack = List<SavedCardModel>.from(state.cards);
      final insertAt = originalIndex.clamp(0, rolledBack.length);
      rolledBack.insert(insertAt, card);

      _safeEmit(state.copyWith(
        cards: rolledBack,
        removingTokens: {...state.removingTokens}..remove(token),
        errorMessage: errorMessage,
      ));
    }
  }

  /// Clears the saved cards state.
  /// Call this on logout.
  void clearCards() {
    if (kDebugMode) {
      debugPrint('SavedCardsCubit: Clearing cards');
    }
    _safeEmit(SavedCardsState.initial());
  }

  /// Safely emits a new state only if the cubit is not closed.
  void _safeEmit(SavedCardsState newState) {
    if (!isClosed) {
      emit(newState);
    }
  }

  /// Extracts error message from exception.
  String _extractErrorMessage(dynamic e) {
    if (e is SavedCardsException) {
      return e.serverMessage ?? e.toString().replaceFirst('SavedCardsException: ', '');
    }
    if (e is Exception) {
      return e.toString().replaceFirst('Exception: ', '');
    }
    return e.toString();
  }
}
