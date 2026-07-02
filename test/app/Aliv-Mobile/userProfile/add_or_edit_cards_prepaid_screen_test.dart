import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/repository/saved_cards_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/addOrEditCards/prepaid/view/add_or_edit_cards_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';

void main() {
  testWidgets('dismissing add-card sheet does not call the add API', (
    tester,
  ) async {
    final repository = _ScreenSavedCardsRepository();
    final cubit = SavedCardsCubit(repository: repository);
    await _pumpScreen(tester, cubit);

    await tester.tap(find.text('add a new card'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back).last);
    await tester.pumpAndSettle();

    expect(repository.addCalls, 0);
    await cubit.close();
  });

  testWidgets('saving valid details adds and refreshes the card list', (
    tester,
  ) async {
    final repository = _ScreenSavedCardsRepository();
    final cubit = SavedCardsCubit(repository: repository);
    await _pumpScreen(tester, cubit);

    await tester.tap(find.text('add a new card'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Demo Visa User');
    await tester.enterText(
      find.byType(TextField).at(1),
      '4111111111111111',
    );
    await tester.enterText(find.byType(TextField).at(2), '1230');
    await tester.enterText(find.byType(TextField).at(3), '456');
    await tester.pump();
    await tester.tap(find.text('save card'));
    await tester.pumpAndSettle();

    expect(repository.addCalls, 1);
    expect(repository.fetchCalls, 2);
    expect(cubit.state.cards.single.token, 'new-token');
    expect(find.text('card ending in 1111'), findsOneWidget);
    await cubit.close();
  });
}

Future<void> _pumpScreen(WidgetTester tester, SavedCardsCubit cubit) async {
  await tester.pumpWidget(
    BlocProvider.value(
      value: cubit,
      child: const MaterialApp(home: AddOrEditCardsPrepaidScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

class _ScreenSavedCardsRepository implements SavedCardsRepository {
  int addCalls = 0;
  int fetchCalls = 0;

  @override
  Future<String> addCard(NewCardDetails details) async {
    addCalls++;
    return 'new-token';
  }

  @override
  Future<List<SavedCardModel>> fetchSavedCards() async {
    fetchCalls++;
    if (addCalls == 0) return const <SavedCardModel>[];
    return const <SavedCardModel>[
      SavedCardModel(token: 'new-token', number: '*1111'),
    ];
  }

  @override
  Future<void> deleteCard(String token) async {}

  @override
  Future<String?> fetchAutoPayToken() async => null;

  @override
  Future<String?> fetchAutoRenewToken() async => null;
}
