import 'dart:async';

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
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/view/auto_top_up_authorization_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/auto_topup/auto_topup_tab.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Cards extends MockCubit<SavedCardsState> implements SavedCardsCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

const _cardError = 'select a card to continue';
const _addCard = 'add a new card';
const _card = SavedCardModel(token: 'tok-1234', number: '************1234');

void main() {
  late _Cards cards;
  late _Devices devices;
  late _Account account;
  late StreamController<SavedCardsState> cardStates;
  var addCardVisits = 0;
  // A loading spinner never settles, so that case pumps fixed frames.
  var spinnerVisible = false;

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
    devices = _Devices();
    account = _Account();
    when(() => account.state).thenReturn(const AccountInfoState());
    cardStates = StreamController<SavedCardsState>.broadcast();
    addCardVisits = 0;
    spinnerVisible = false;
    when(() => cards.fetchSavedCards()).thenAnswer((_) async {});
    when(() => cards.refreshSavedCards()).thenAnswer((_) async {});
    whenListen(
      devices,
      const Stream<DeviceLimitsState>.empty(),
      initialState: DeviceLimitsState.initial(),
    );
    when(() => devices.loadDeviceLimits()).thenAnswer((_) async {});
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<AccountInfoCubit>(account);
  });

  tearDown(() async {
    await cardStates.close();
    await cards.close();
    await devices.close();
    await account.close();
    await instance.reset();
  });

  Future<void> settle(WidgetTester tester) => spinnerVisible
      ? tester.pump(const Duration(milliseconds: 300))
      : tester.pumpAndSettle();

  Future<void> pumpTab(WidgetTester tester, SavedCardsState initial) async {
    spinnerVisible = initial.status == SavedCardsStatus.loading;
    whenListen(cards, cardStates.stream, initialState: initial);
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const AutoTopupTab()),
        GoRoute(
          path: AppRoutes.addOrEditCardsPrepaidScreen,
          builder: (_, _) {
            addCardVisits++;
            return const Scaffold(body: Text('existing add card'));
          },
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
    await settle(tester);
  }

  Future<void> enterCustomAmount(WidgetTester tester, String value) async {
    await tester.enterText(
      find.byWidgetPredicate(
        (w) =>
            w is TextField && w.decoration?.hintText == 'enter a custom amount',
      ),
      value,
    );
    await settle(tester);
  }

  Future<void> apply(WidgetTester tester) async {
    await tester.ensureVisible(find.text('apply'));
    await tester.tap(find.text('apply'));
    await settle(tester);
  }

  const noCards = SavedCardsState(status: SavedCardsStatus.success);

  testWidgets('no card + apply shows ATOP-001 inline and does not submit', (
    tester,
  ) async {
    await pumpTab(tester, noCards);
    expect(find.text('no saved cards'), findsOneWidget);
    expect(find.text(_cardError), findsNothing);
    await enterCustomAmount(tester, '25');
    await apply(tester);
    expect(find.text(_cardError), findsOneWidget);
    expect(find.text(_addCard), findsOneWidget);
    expect(find.byType(AutoTopUpAuthorizationScreen), findsNothing);
    verifyNever(
      () => devices.updateBalanceThresholdSettings(
        balanceThreshold: any(named: 'balanceThreshold'),
        autoTopUpAmount: any(named: 'autoTopUpAmount'),
        cardToken: any(named: 'cardToken'),
      ),
    );
  });

  testWidgets('missing amount keeps its existing toast first', (tester) async {
    await pumpTab(tester, noCards);
    await tester.ensureVisible(find.text('apply'));
    await tester.tap(find.text('apply'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Please select or enter an amount'), findsOneWidget);
    expect(find.text(_cardError), findsNothing);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('add a new card reuses the existing add-card action', (
    tester,
  ) async {
    await pumpTab(tester, noCards);
    await enterCustomAmount(tester, '25');
    await apply(tester);
    await tester.tap(find.text(_addCard));
    await tester.pumpAndSettle();
    expect(find.text('existing add card'), findsOneWidget);
    expect(addCardVisits, 1);

    final context = tester.element(find.text('existing add card'));
    GoRouter.of(context).pop();
    await tester.pumpAndSettle();
    verify(() => cards.refreshSavedCards()).called(1);
  });

  testWidgets('a newly available card clears the error and apply continues', (
    tester,
  ) async {
    await pumpTab(tester, noCards);
    await enterCustomAmount(tester, '25');
    await apply(tester);
    expect(find.text(_cardError), findsOneWidget);

    // The shared dropdown auto-selects the first card once cards load.
    cardStates.add(
      const SavedCardsState(status: SavedCardsStatus.success, cards: [_card]),
    );
    await tester.pumpAndSettle();
    expect(find.text(_cardError), findsNothing);
    expect(find.text('card ending in 1234'), findsOneWidget);

    await apply(tester);
    final screen = tester.widget<AutoTopUpAuthorizationScreen>(
      find.byType(AutoTopUpAuthorizationScreen),
    );
    expect(screen.cardToken, 'tok-1234');
    expect(screen.autoTopUpAmount, 25);
  });

  testWidgets('saved cards are auto-selected, so apply is never blocked', (
    tester,
  ) async {
    await pumpTab(tester, const SavedCardsState());
    cardStates.add(
      const SavedCardsState(status: SavedCardsStatus.success, cards: [_card]),
    );
    await tester.pumpAndSettle();
    await enterCustomAmount(tester, '25');
    await apply(tester);
    expect(find.text(_cardError), findsNothing);
    expect(find.byType(AutoTopUpAuthorizationScreen), findsOneWidget);
  });

  for (final status in [SavedCardsStatus.loading, SavedCardsStatus.failure]) {
    testWidgets('${status.name} card list is not treated as no card', (
      tester,
    ) async {
      await pumpTab(tester, SavedCardsState(status: status));
      await enterCustomAmount(tester, '25');
      await apply(tester);
      expect(find.text(_cardError), findsNothing);
      expect(find.text(_addCard), findsNothing);
    });
  }
}
