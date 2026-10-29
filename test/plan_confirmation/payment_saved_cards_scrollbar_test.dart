import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/widgets/home_plans_payment_method_section.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/widgets/home_plans_payment_method_tile.dart';

class _Cards extends MockCubit<SavedCardsState> implements SavedCardsCubit {}

List<SavedCardModel> _cards(int count) => List.generate(
  count,
  (index) => SavedCardModel(token: 'token-$index', number: '*${1000 + index}'),
);

void main() {
  late _Cards cards;
  final selectedTokens = <String>[];
  final chargedAccounts = <String>[];
  var payWithCardCalls = 0;
  var walletCalls = 0;

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
    chargedAccounts.clear();
    payWithCardCalls = 0;
    walletCalls = 0;
  });

  tearDown(() async {
    await cards.close();
    await instance.reset();
  });

  Future<void> pumpSection(
    WidgetTester tester, {
    required int count,
    TargetPlatform platform = TargetPlatform.android,
    double width = 390,
    double textScale = 1,
    bool showOtherMethods = false,
    bool stubState = true,
  }) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    if (stubState) {
      when(() => cards.state).thenReturn(
        SavedCardsState(status: SavedCardsStatus.success, cards: _cards(count)),
      );
    }
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: platform),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: HomePlansPaymentMethodSection(
                methods: showOtherMethods
                    ? const [
                        HomePlansSavedPaymentMethod(
                          id: 'charge-account',
                          brand: HomePlansCardBrand.unknown,
                          ending: '',
                          expiry: '',
                          logoSvgAsset: '',
                          isChargeToMyAccount: true,
                        ),
                      ]
                    : const [],
                selectedId: 'token-0',
                paymentMode: HomePlansPaymentMode.card,
                onSelect: selectedTokens.add,
                onChargeToAccountSelect: chargedAccounts.add,
                onPayWithCard: () => payWithCardCalls++,
                showPayFromWallet: showOtherMethods,
                walletBalanceText: r'$200.00',
                onPayFromWallet: () => walletCalls++,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final count in [0, 1, 4, 5, 6]) {
      testWidgets('$platform shows a scrollbar only above four cards: $count', (
        tester,
      ) async {
        await pumpSection(tester, count: count, platform: platform);
        if (count <= 4) {
          expect(find.byType(Scrollbar), findsNothing);
          expect(find.byType(ListView), findsNothing);
          expect(find.byType(HomePlansPaymentMethodTile), findsNWidgets(count));
        } else {
          final bar = tester.widget<Scrollbar>(find.byType(Scrollbar));
          final list = tester.widget<ListView>(find.byType(ListView));
          expect(bar.thumbVisibility, isTrue);
          expect(bar.controller, same(list.controller));
          expect(list.primary, isFalse);
          expect(bar.controller!.position.maxScrollExtent, greaterThan(0));
          final tile = find.widgetWithText(
            HomePlansPaymentMethodTile,
            'card ending in 1000',
          );
          final rowHeight = tester.getSize(tile).height;
          final secondTile = find.widgetWithText(
            HomePlansPaymentMethodTile,
            'card ending in 1001',
          );
          final gap =
              tester.getTopLeft(secondTile).dy - tester.getBottomLeft(tile).dy;
          expect(
            tester.getSize(find.byType(Scrollbar)).height,
            closeTo(4 * rowHeight + 3 * gap, 0.1),
          );
          final last = find.text('card ending in ${999 + count}');
          expect(last.hitTestable(), findsNothing);
          final payPosition = tester.getCenter(find.text('pay with card'));
          await tester.drag(find.byType(ListView), const Offset(0, -500));
          await tester.pumpAndSettle();
          expect(last.hitTestable(), findsOneWidget);
          expect(tester.getCenter(find.text('pay with card')), payPosition);
          await tester.tap(last);
          expect(selectedTokens, ['token-${count - 1}']);
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'other payment actions remain outside the saved-card scroll area',
    (tester) async {
      await pumpSection(tester, count: 6, showOtherMethods: true);
      for (final label in [
        'charge to my account',
        'pay with card',
        'pay from wallet',
      ]) {
        expect(
          find.descendant(
            of: find.byType(Scrollbar),
            matching: find.text(label),
          ),
          findsNothing,
        );
      }
      await tester.tap(find.text('charge to my account'));
      await tester.tap(find.text('pay with card'));
      await tester.tap(find.text('pay from wallet'));
      expect(chargedAccounts, ['charge-account']);
      expect(payWithCardCalls, 1);
      expect(walletCalls, 1);
      expect(selectedTokens, isEmpty);
    },
  );

  for (final width in [320.0, 430.0]) {
    testWidgets(
      'saved cards remain scrollable at width $width and larger text',
      (tester) async {
        await pumpSection(tester, count: 6, width: width, textScale: 1.6);
        await tester.drag(find.byType(ListView), const Offset(0, -900));
        await tester.pumpAndSettle();
        expect(find.text('card ending in 1005').hitTestable(), findsOneWidget);
        await tester.tap(find.text('card ending in 1005'));
        expect(selectedTokens, ['token-5']);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('card updates toggle scrolling without controller errors', (
    tester,
  ) async {
    final changes = StreamController<SavedCardsState>();
    addTearDown(changes.close);
    whenListen(
      cards,
      changes.stream,
      initialState: SavedCardsState(
        status: SavedCardsStatus.success,
        cards: _cards(6),
      ),
    );
    await pumpSection(tester, count: 6, stubState: false);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    changes.add(
      SavedCardsState(status: SavedCardsStatus.success, cards: _cards(4)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Scrollbar), findsNothing);
    changes.add(
      SavedCardsState(status: SavedCardsStatus.success, cards: _cards(5)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });
}
