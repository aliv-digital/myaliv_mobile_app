import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/view/top_up_payment_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/widgets/top_up_payment_saved_cards_section.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/balance/models/balance_model.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/card_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/top_up_payment_service.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/cards/saved_cards_radio_list.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Cards extends MockCubit<SavedCardsState> implements SavedCardsCubit {}

class _Balance extends MockCubit<BalanceState> implements BalanceCubit {}

class _TopUpService extends Mock implements TopUpPaymentService {}

class _CardService extends Mock implements CardPaymentService {}

List<SavedCardModel> _cards(int count) => List.generate(
  count,
  (index) => SavedCardModel(token: 'token-$index', number: '*${1000 + index}'),
);

void main() {
  late _Cards cards;
  late _Account account;
  late _Balance balance;
  late _TopUpService topUp;
  late _CardService cardService;
  final selectedTokens = <String>[];

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    cards = _Cards();
    account = _Account();
    balance = _Balance();
    topUp = _TopUpService();
    cardService = _CardService();

    when(() => cards.fetchSavedCards()).thenAnswer((_) async {});
    when(() => account.state).thenReturn(
      const AccountInfoState(
        accountInfo: AccountInfoModel(primaryPhoneNumber: '2428011616'),
      ),
    );
    when(() => balance.state).thenReturn(
      BalanceState(
        status: BalanceStatus.loaded,
        balance: BalanceModel(
          walletBalance: 20,
          bonusBalance: 0,
          bonusDetails: const [],
          fetchedAt: DateTime(2026, 1, 1),
        ),
      ),
    );

    instance.registerSingleton<SavedCardsCubit>(cards);
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<BalanceCubit>(balance);
    instance.registerSingleton<TopUpPaymentService>(topUp);
    instance.registerSingleton<CardPaymentService>(cardService);

    selectedTokens.clear();
  });

  tearDown(() async {
    await cards.close();
    await account.close();
    await balance.close();
    await instance.reset();
  });

  Future<void> pumpSection(
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
                child: TopUpPaymentSavedCardsSection(
                  selectedToken: selectedToken,
                  autoSelectFirst: autoSelectFirst,
                  onCardSelected: (card) => selectedTokens.add(card.token),
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
    'shows no scrollbar and no ListView when cards count is 4 or less',
    (tester) async {
      await pumpSection(tester, count: 4);
      expect(find.byType(SavedCardsScrollbarThumb), findsNothing);
      expect(find.byType(ListView), findsNothing);
      expect(find.byType(SavedCardRadioTile), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'shows a scrollbar thumb with compact height 48 starting from the top',
    (tester) async {
      await pumpSection(tester, count: 6);
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
    'allows scrolling with thumb and selecting cards in the scroll area',
    (tester) async {
      await pumpSection(tester, count: 6);
      final thumbFinder = find.byKey(
        const ValueKey('saved_cards_scrollbar_thumb'),
      );
      final initialThumbDy = tester.getTopLeft(thumbFinder).dy;

      expect(find.text('card ending in 1005').hitTestable(), findsNothing);

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      final scrolledThumbDy = tester.getTopLeft(thumbFinder).dy;
      expect(scrolledThumbDy, greaterThan(initialThumbDy));

      expect(find.text('card ending in 1005').hitTestable(), findsOneWidget);
      await tester.tap(find.text('card ending in 1005'));
      expect(selectedTokens, ['token-5']);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'TopUpPaymentScreen shows compact scrollbar thumb starting from top for saved cards',
    (tester) async {
      when(() => cards.state).thenReturn(
        SavedCardsState(status: SavedCardsStatus.success, cards: _cards(6)),
      );

      final config = AppUiConfigCubit(
        initialConfig: const HomeUiConfig(
          userType: UserType.prepaid,
          hasActivePlan: true,
          isFuturePlan: false,
        ),
      );
      addTearDown(config.close);

      final router = GoRouter(
        initialLocation: AppRoutes.topUpPaymentPrepaidScreen,
        routes: [
          GoRoute(
            path: AppRoutes.topUpPaymentPrepaidScreen,
            builder: (_, _) => const TopUpPaymentScreen(amount: 10),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AppUiConfigCubit>.value(value: config),
            BlocProvider<SavedCardsCubit>.value(value: cards),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      final thumbFinder = find.byKey(
        const ValueKey('saved_cards_scrollbar_thumb'),
      );
      expect(thumbFinder, findsOneWidget);
      expect(tester.getSize(thumbFinder).height, 48.0);

      final listTopLeft = tester.getTopLeft(find.byType(ListView));
      final thumbTopLeft = tester.getTopLeft(thumbFinder);
      expect(thumbTopLeft.dy, closeTo(listTopLeft.dy, 0.5));

      expect(find.text('pay with card'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
