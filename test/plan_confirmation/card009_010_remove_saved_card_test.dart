import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/addOrEditCards/prepaid/view/add_or_edit_cards_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/addOrEditCards/prepaid/widgets/saved_card_tile.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class _Cards extends MockCubit<SavedCardsState> implements SavedCardsCubit {}

const _question = 'are you sure you want to remove \nyour saved card?';
const _success = 'your card has been successfully removed';
const _card = SavedCardModel(token: 'tok-1234', number: '************1234');

void main() {
  late _Cards cards;
  late SavedCardsState current;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  setUp(() {
    cards = _Cards();
    current = const SavedCardsState(
      status: SavedCardsStatus.success,
      cards: [_card],
    );
    when(() => cards.state).thenAnswer((_) => current);
    when(() => cards.fetchSavedCards()).thenAnswer((_) async {});
  });

  tearDown(() => cards.close());

  Future<void> openRemove(WidgetTester tester, {bool succeeds = true}) async {
    when(() => cards.removeCard(any())).thenAnswer((_) async {
      // Mirrors the cubit: failure rolls back and sets an error message.
      if (!succeeds) {
        current = const SavedCardsState(
          status: SavedCardsStatus.success,
          cards: [_card],
          errorMessage: 'Failed to remove card',
        );
      }
    });
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const AddOrEditCardsPrepaidScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      BlocProvider<SavedCardsCubit>.value(
        value: cards,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    // The tile's delete icon invokes this callback.
    tester.widget<SavedCardTile>(find.byType(SavedCardTile)).onDelete();
    await tester.pumpAndSettle();
  }

  Future<void> settleToasts(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  testWidgets('CARD-009 delete shows the confirmation with ok and cancel', (
    tester,
  ) async {
    await openRemove(tester);
    expect(find.text(_question), findsOneWidget);
    expect(find.text('ok'), findsOneWidget);
    expect(find.text('cancel'), findsOneWidget);
    expect(find.text(_success), findsNothing);
    verifyNever(() => cards.removeCard(any()));
  });

  testWidgets('CARD-009 cancel dismisses only', (tester) async {
    await openRemove(tester);
    await tester.tap(find.text('cancel'));
    await tester.pumpAndSettle();
    expect(find.text(_question), findsNothing);
    expect(find.text(_success), findsNothing);
    expect(find.byType(SavedCardTile), findsOneWidget);
    verifyNever(() => cards.removeCard(any()));
  });

  testWidgets('CARD-010 ok removes the card, then shows the success toast', (
    tester,
  ) async {
    await openRemove(tester);
    await tester.tap(find.text('ok'));
    await tester.pump(const Duration(milliseconds: 500));
    verify(() => cards.removeCard('tok-1234')).called(1);
    expect(find.text(_success), findsOneWidget);
    expect(
      find.text('your card has been saved successfully removed'),
      findsNothing,
    );
    await settleToasts(tester);
  });

  testWidgets('CARD-010 failed removal shows no success toast', (tester) async {
    await openRemove(tester, succeeds: false);
    await tester.tap(find.text('ok'));
    await tester.pump(const Duration(milliseconds: 500));
    verify(() => cards.removeCard('tok-1234')).called(1);
    expect(find.text(_success), findsNothing);
    await settleToasts(tester);
  });
}
