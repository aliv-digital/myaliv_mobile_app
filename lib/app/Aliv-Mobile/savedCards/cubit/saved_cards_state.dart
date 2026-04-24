import 'package:equatable/equatable.dart';
import '../models/saved_card_model.dart';

/// Status enum for saved cards operations.
enum SavedCardsStatus {
  initial,
  loading,
  success,
  failure,
}

/// State class for saved cards cubit.
class SavedCardsState extends Equatable {
  const SavedCardsState({
    this.status = SavedCardsStatus.initial,
    this.cards = const [],
    this.errorMessage,
    this.lastFetchedAt,
  });

  final SavedCardsStatus status;
  final List<SavedCardModel> cards;
  final String? errorMessage;
  final DateTime? lastFetchedAt;

  /// Factory constructor for initial state.
  factory SavedCardsState.initial() => const SavedCardsState();

  /// Returns true if there are saved cards.
  bool get hasCards => cards.isNotEmpty;

  /// Returns true if there are no saved cards.
  bool get isEmpty => cards.isEmpty;

  /// Returns true if currently loading.
  bool get isLoading => status == SavedCardsStatus.loading;

  /// Returns true if there was an error.
  bool get hasError => status == SavedCardsStatus.failure;

  /// Returns true if data was successfully loaded.
  bool get isSuccess => status == SavedCardsStatus.success;

  /// Check if the cache is stale based on TTL.
  /// Default TTL is 5 minutes since cards can change.
  bool isCacheStale({Duration ttl = const Duration(minutes: 5)}) {
    if (lastFetchedAt == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastFetchedAt!);
    return difference > ttl;
  }

  /// Creates a copy with the given fields replaced.
  SavedCardsState copyWith({
    SavedCardsStatus? status,
    List<SavedCardModel>? cards,
    String? errorMessage,
    DateTime? lastFetchedAt,
    bool clearError = false,
  }) {
    return SavedCardsState(
      status: status ?? this.status,
      cards: cards ?? this.cards,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
    );
  }

  @override
  List<Object?> get props => [status, cards, errorMessage, lastFetchedAt];
}
