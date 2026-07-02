import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/repository/saved_cards_repository.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';

void main() {
  const details = NewCardDetails(
    cardNumber: '4111111111111111',
    cardExpiration: '2030-12',
    cardSecurityCode: '456',
    cardHolderName: 'Demo Visa User',
  );
  const oldCard = SavedCardModel(token: 'old', number: '*1111');
  const newCard = SavedCardModel(token: 'new', number: '*2222');

  test('addCard posts once, force-refreshes, and exposes refreshed list',
      () async {
    final repository = _FakeSavedCardsRepository(cards: const [oldCard]);
    final cubit = SavedCardsCubit(repository: repository);
    await cubit.fetchSavedCards();
    repository.cards = const [oldCard, newCard];

    final added = await cubit.addCard(details);

    expect(added, isTrue);
    expect(repository.addCalls, 1);
    expect(repository.fetchCalls, 2);
    expect(cubit.state.cards, const [oldCard, newCard]);
    expect(cubit.state.isAddingCard, isFalse);
    expect(cubit.state.errorMessage, isNull);
    await cubit.close();
  });

  test('addCard blocks a duplicate submission while one is pending', () async {
    final addCompleter = Completer<String>();
    final repository = _FakeSavedCardsRepository(
      cards: const [oldCard],
      addCompleter: addCompleter,
    );
    final cubit = SavedCardsCubit(repository: repository);

    final first = cubit.addCard(details);
    await Future<void>.delayed(Duration.zero);
    final duplicate = await cubit.addCard(details);

    expect(duplicate, isFalse);
    expect(repository.addCalls, 1);
    expect(cubit.state.isAddingCard, isTrue);

    addCompleter.complete('new-token');
    await first;
    expect(cubit.state.isAddingCard, isFalse);
    await cubit.close();
  });

  test('addCard preserves existing cards when POST fails', () async {
    final repository = _FakeSavedCardsRepository(cards: const [oldCard]);
    final cubit = SavedCardsCubit(repository: repository);
    await cubit.fetchSavedCards();
    repository.addError = Exception('Add failed');

    final added = await cubit.addCard(details);

    expect(added, isFalse);
    expect(cubit.state.cards, const [oldCard]);
    expect(cubit.state.isAddingCard, isFalse);
    expect(cubit.state.errorMessage, contains('Add failed'));
    await cubit.close();
  });

  test('addCard preserves cards and reports refresh failure', () async {
    final repository = _FakeSavedCardsRepository(cards: const [oldCard]);
    final cubit = SavedCardsCubit(repository: repository);
    await cubit.fetchSavedCards();
    repository.fetchError = Exception('Refresh failed');

    final added = await cubit.addCard(details);

    expect(added, isFalse);
    expect(repository.addCalls, 1);
    expect(cubit.state.cards, const [oldCard]);
    expect(cubit.state.isAddingCard, isFalse);
    expect(cubit.state.errorMessage, contains('could not refresh'));
    await cubit.close();
  });
}

class _FakeSavedCardsRepository implements SavedCardsRepository {
  _FakeSavedCardsRepository({
    required this.cards,
    this.addCompleter,
  });

  List<SavedCardModel> cards;
  final Completer<String>? addCompleter;
  Object? addError;
  Object? fetchError;
  int addCalls = 0;
  int fetchCalls = 0;

  @override
  Future<String> addCard(NewCardDetails details) async {
    addCalls++;
    if (addError != null) throw addError!;
    if (addCompleter != null) return addCompleter!.future;
    return 'new-token';
  }

  @override
  Future<List<SavedCardModel>> fetchSavedCards() async {
    fetchCalls++;
    if (fetchError != null) throw fetchError!;
    return cards;
  }

  @override
  Future<void> deleteCard(String token) async {}

  @override
  Future<String?> fetchAutoPayToken() async => null;

  @override
  Future<String?> fetchAutoRenewToken() async => null;
}
