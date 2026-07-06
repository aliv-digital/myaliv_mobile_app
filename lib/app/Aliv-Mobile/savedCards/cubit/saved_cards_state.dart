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
    this.removingTokens = const {},
    this.isAddingCard = false,
    this.errorMessage,
    this.lastFetchedAt,
    this.autoPayToken,
    this.autoRenewToken,
  });

  final SavedCardsStatus status;
  final List<SavedCardModel> cards;
  final Set<String> removingTokens;
  final bool isAddingCard;
  final String? errorMessage;
  final DateTime? lastFetchedAt;

  /// Server-stored token for the postpaid auto-pay card. Null when unset.
  final String? autoPayToken;

  /// Server-stored token for the prepaid auto-renew card. Null when unset.
  final String? autoRenewToken;

  /// Factory constructor for initial state.
  factory SavedCardsState.initial() => const SavedCardsState();

  /// Returns true if the given card token is currently being removed.
  bool isRemoving(String token) => removingTokens.contains(token);

  /// Postpaid card matching the server's auto-pay token, or null.
  SavedCardModel? get postpaidSelectedCard => _matchToken(autoPayToken);

  /// Prepaid card matching the server's auto-renew token, or null.
  SavedCardModel? get prepaidSelectedCard => _matchToken(autoRenewToken);

  SavedCardModel? _matchToken(String? token) {
    if (token == null || token.isEmpty) return null;
    for (final c in cards) {
      if (c.token == token) return c;
    }
    return null;
  }

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
    Set<String>? removingTokens,
    bool? isAddingCard,
    String? errorMessage,
    DateTime? lastFetchedAt,
    String? autoPayToken,
    String? autoRenewToken,
    bool clearError = false,
    bool clearAutoPayToken = false,
    bool clearAutoRenewToken = false,
  }) {
    return SavedCardsState(
      status: status ?? this.status,
      cards: cards ?? this.cards,
      removingTokens: removingTokens ?? this.removingTokens,
      isAddingCard: isAddingCard ?? this.isAddingCard,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      autoPayToken:
          clearAutoPayToken ? null : (autoPayToken ?? this.autoPayToken),
      autoRenewToken: clearAutoRenewToken
          ? null
          : (autoRenewToken ?? this.autoRenewToken),
    );
  }

  @override
  List<Object?> get props => [
        status,
        cards,
        removingTokens,
        isAddingCard,
        errorMessage,
        lastFetchedAt,
        autoPayToken,
        autoRenewToken,
      ];
}
