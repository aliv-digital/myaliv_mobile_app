import 'package:equatable/equatable.dart';
import '../model/add_or_edit_cards_prepaid_models.dart';

enum AddOrEditCardsPrepaidLoadStatus { initial, loading, ready, failure }

enum AddOrEditCardsPrepaidNavTarget { none, addCard, home }

class AddOrEditCardsPrepaidState extends Equatable {
  final AddOrEditCardsPrepaidLoadStatus loadStatus;

  final List<SavedCard> cards;
  final Set<String> deletingIds;

  /// ✅ add new card save করলে লোডিং দেখানোর জন্য
  final bool savingNewCard;

  final String? errorMessage;
  final AddOrEditCardsPrepaidNavTarget navTarget;

  const AddOrEditCardsPrepaidState({
    required this.loadStatus,
    required this.cards,
    required this.deletingIds,
    required this.savingNewCard,
    required this.errorMessage,
    required this.navTarget,
  });

  factory AddOrEditCardsPrepaidState.initial() => const AddOrEditCardsPrepaidState(
    loadStatus: AddOrEditCardsPrepaidLoadStatus.initial,
    cards: [],
    deletingIds: {},
    savingNewCard: false,
    errorMessage: null,
    navTarget: AddOrEditCardsPrepaidNavTarget.none,
  );

  AddOrEditCardsPrepaidState copyWith({
    AddOrEditCardsPrepaidLoadStatus? loadStatus,
    List<SavedCard>? cards,
    Set<String>? deletingIds,
    bool? savingNewCard,
    String? errorMessage,
    AddOrEditCardsPrepaidNavTarget? navTarget,
    bool clearError = false,
  }) {
    return AddOrEditCardsPrepaidState(
      loadStatus: loadStatus ?? this.loadStatus,
      cards: cards ?? this.cards,
      deletingIds: deletingIds ?? this.deletingIds,
      savingNewCard: savingNewCard ?? this.savingNewCard,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      navTarget: navTarget ?? this.navTarget,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    cards,
    deletingIds,
    savingNewCard,
    errorMessage,
    navTarget,
  ];
}
