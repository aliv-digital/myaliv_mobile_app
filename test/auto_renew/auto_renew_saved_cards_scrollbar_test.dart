import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/widgets/auto_renew_payment_method_section.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/widgets/auto_renew_saved_cards_list.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/resources/widgets/cards/saved_cards_radio_list.dart';

class _Cards extends MockCubit<SavedCardsState> implements SavedCardsCubit {}

List<SavedCardModel> _cards(int count) => List.generate(
  count,
  (index) => SavedCardModel(token: 'token-$index', number: '*${1000 + index}'),
);

void main() {
  late _Cards cards;
  final selectedTokens = <String?>[];

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    cards = _Cards();
    when(() => cards.fetchSavedCards()).thenAnswer((_) async {});
    instance.registerSingleton<SavedCardsCubit>(cards);
    selectedTokens.clear();
  });

  tearDown(() async {
    await cards.close();
    await instance.reset();
  });

  Future<void> pumpList(
    WidgetTester tester, {
    required int count,
    String? selectedToken,
    bool autoSelectFirst = false,
  }) async {
    when(() => cards.state).thenReturn(
      SavedCardsState(status: SavedCardsStatus.success, cards: _cards(count)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: BlocProvider<SavedCardsCubit>.value(
                value: cards,
                child: AutoRenewSavedCardsList(
                  selectedToken: selectedToken,
                  autoSelectFirst: autoSelectFirst,
                  onCardSelected: (card) => selectedTokens.add(card?.token),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'AutoRenewSavedCardsList shows no scrollbar when cards count is 4 or less',
    (tester) async {
      await pumpList(tester, count: 4);
      expect(find.byType(SavedCardsScrollbarThumb), findsNothing);
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(SavedCardRadioTile), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'AutoRenewSavedCardsList shows a compact scrollbar thumb starting from the top when count exceeds 4',
    (tester) async {
      await pumpList(tester, count: 6);
      expect(find.byType(SavedCardsScrollbarThumb), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);

      final thumbFinder = find.byKey(
        const ValueKey('saved_cards_scrollbar_thumb'),
      );
      expect(thumbFinder, findsOneWidget);

      final thumbSize = tester.getSize(thumbFinder);
      expect(thumbSize.height, 48.0);
      expect(thumbSize.width, 4.0);

      final listTopLeft = tester.getTopLeft(find.byType(ListView));
      final thumbTopLeft = tester.getTopLeft(thumbFinder);
      expect(thumbTopLeft.dy, closeTo(listTopLeft.dy, 0.5));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'AutoRenewPaymentMethodSection renders scrollbar thumb and allows scrolling and card selection',
    (tester) async {
      when(() => cards.state).thenReturn(
        SavedCardsState(status: SavedCardsStatus.success, cards: _cards(6)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BlocProvider<SavedCardsCubit>.value(
                  value: cards,
                  child: AutoRenewPaymentMethodSection(
                    selectedCard: null,
                    onCardSelected: (card) => selectedTokens.add(card?.token),
                    showWalletRow: false,
                    showNoAutoRenewRow: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final thumbFinder = find.byKey(
        const ValueKey('saved_cards_scrollbar_thumb'),
      );
      expect(thumbFinder, findsOneWidget);
      expect(tester.getSize(thumbFinder).height, 48.0);

      expect(find.text('card ending in 1005').hitTestable(), findsNothing);

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('card ending in 1005').hitTestable(), findsOneWidget);
      await tester.tap(find.text('card ending in 1005'));
      expect(selectedTokens, ['token-5']);
      expect(tester.takeException(), isNull);
    },
  );
}
