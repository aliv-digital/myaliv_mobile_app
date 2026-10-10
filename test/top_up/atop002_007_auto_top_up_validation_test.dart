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
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/logic/auto_top_up_validation.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/view/auto_top_up_authorization_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/auto_topup/auto_topup_tab.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Cards extends MockCubit<SavedCardsState> implements SavedCardsCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _DeviceState extends Mock implements DeviceLimitsState {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

const _threshold = r'amount must be above $10.00 and below $100.00';
const _noAmount = 'choose a top-up amount or enter a custom amount';
const _min = r'the minimum top-up amount is $5.00';
const _max = r'the maximum top-up amount is $100.00';
const _cardError = 'select a card to continue';
const _started = 'auto top-up successfully started';
const _updated =
    "We're working on it! Auto top-up takes a few minutes to update. Thank you for your patience.";
const _card = SavedCardModel(token: 'tok-1234', number: '************1234');

Future<void> _loadFonts() async {
  await (FontLoader('CircularPro')
        ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
        ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
      .load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
}

void main() {
  group('Auto Top-up rules', () {
    for (final value in [5.0, 10.0, 100.0, 150.0]) {
      test('ATOP-002 threshold $value is invalid', () {
        expect(validateAutoTopUpThreshold(value), _threshold);
      });
    }
    for (final value in [10.01, 25.0, 50.0, 99.99]) {
      test('ATOP-002 threshold $value is valid', () {
        expect(validateAutoTopUpThreshold(value), isNull);
      });
    }

    test('ATOP-003 no preset and no custom amount', () {
      expect(
        validateAutoTopUpAmount(customAmount: null, presetAmount: null),
        _noAmount,
      );
    });

    test('a preset amount is valid and has no custom limits', () {
      expect(
        validateAutoTopUpAmount(customAmount: null, presetAmount: 10),
        isNull,
      );
    });

    for (final value in [0.0, 1.0, 4.99]) {
      test('ATOP-004 custom $value is below the minimum', () {
        expect(
          validateAutoTopUpAmount(customAmount: value, presetAmount: null),
          _min,
        );
      });
    }
    for (final value in [5.0, 10.0, 50.0, 100.0]) {
      test('custom $value is valid', () {
        expect(
          validateAutoTopUpAmount(customAmount: value, presetAmount: null),
          isNull,
        );
      });
    }
    for (final value in [100.01, 150.0]) {
      test('ATOP-005 custom $value is above the maximum', () {
        expect(
          validateAutoTopUpAmount(customAmount: value, presetAmount: null),
          _max,
        );
      });
    }

    test('a custom amount takes priority over a preset', () {
      expect(
        validateAutoTopUpAmount(customAmount: 150, presetAmount: 10),
        _max,
      );
    });
  });

  group('Auto Top-up tab', () {
    late _Cards cards;
    late _Devices devices;
    late _Account account;
    late StreamController<SavedCardsState> cardStates;

    setUpAll(_loadFonts);

    setUp(() {
      cards = _Cards();
      devices = _Devices();
      account = _Account();
      cardStates = StreamController<SavedCardsState>.broadcast();
      when(() => cards.fetchSavedCards()).thenAnswer((_) async {});
      when(() => cards.refreshSavedCards()).thenAnswer((_) async {});
      whenListen(
        devices,
        const Stream<DeviceLimitsState>.empty(),
        initialState: DeviceLimitsState.initial(),
      );
      when(() => devices.loadDeviceLimits()).thenAnswer((_) async {});
      when(() => account.state).thenReturn(const AccountInfoState());
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

    Future<void> pumpTab(
      WidgetTester tester, {
      List<SavedCardModel> saved = const [_card],
    }) async {
      whenListen(
        cards,
        cardStates.stream,
        initialState: const SavedCardsState(),
      );
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        routes: [GoRoute(path: '/', builder: (_, _) => const AutoTopupTab())],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        BlocProvider<SavedCardsCubit>.value(
          value: cards,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      // The shared dropdown auto-selects the first saved card.
      cardStates.add(
        SavedCardsState(status: SavedCardsStatus.success, cards: saved),
      );
      await tester.pumpAndSettle();
    }

    Finder field(String hint) => find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == hint,
    );

    Future<void> enter(WidgetTester tester, String hint, String value) async {
      await tester.enterText(field(hint), value);
      await tester.pumpAndSettle();
    }

    Future<void> threshold(WidgetTester tester, String value) =>
        enter(tester, 'enter threshold amount', value);

    Future<void> custom(WidgetTester tester, String value) =>
        enter(tester, 'enter a custom amount', value);

    Future<void> apply(WidgetTester tester) async {
      await tester.ensureVisible(find.text('apply'));
      await tester.tap(find.text('apply'));
      await tester.pumpAndSettle();
    }

    Color? helperColor(WidgetTester tester) =>
        tester.widget<Text>(find.text(_threshold)).style?.color;

    void expectNotSubmitted() =>
        expect(find.byType(AutoTopUpAuthorizationScreen), findsNothing);

    AutoTopUpAuthorizationScreen submitted(WidgetTester tester) =>
        tester.widget<AutoTopUpAuthorizationScreen>(
          find.byType(AutoTopUpAuthorizationScreen),
        );

    testWidgets('ATOP-002 helper shows the fixed range before any input', (
      tester,
    ) async {
      await pumpTab(tester);
      expect(find.text(_threshold), findsOneWidget);
      expect(helperColor(tester), const Color(0xFF707070));
    });

    for (final value in ['', '5', '10', '100', '150']) {
      testWidgets('ATOP-002 threshold "$value" blocks apply inline', (
        tester,
      ) async {
        await pumpTab(tester);
        await threshold(tester, value);
        await custom(tester, '25');
        await apply(tester);
        expect(find.text(_threshold), findsOneWidget);
        expect(helperColor(tester), isNot(const Color(0xFF707070)));
        expect(find.text(_noAmount), findsNothing);
        expectNotSubmitted();
      });
    }

    for (final value in ['11', '50', '99']) {
      testWidgets('ATOP-002 threshold $value continues the existing flow', (
        tester,
      ) async {
        await pumpTab(tester);
        await threshold(tester, value);
        await custom(tester, '25');
        await apply(tester);
        final screen = submitted(tester);
        expect(screen.balanceThreshold, double.parse(value));
        expect(screen.autoTopUpAmount, 25);
        expect(screen.cardToken, 'tok-1234');
      });
    }

    testWidgets('ATOP-002 error clears when the threshold is edited', (
      tester,
    ) async {
      await pumpTab(tester);
      await threshold(tester, '10');
      await apply(tester);
      expect(helperColor(tester), isNot(const Color(0xFF707070)));
      await threshold(tester, '20');
      expect(helperColor(tester), const Color(0xFF707070));
    });

    testWidgets('ATOP-003 no amount blocks apply inline', (tester) async {
      await pumpTab(tester);
      await threshold(tester, '20');
      await apply(tester);
      expect(find.text(_noAmount), findsOneWidget);
      expect(find.text('Please select or enter an amount'), findsNothing);
      expectNotSubmitted();
    });

    testWidgets('ATOP-003 selecting a preset clears it and continues', (
      tester,
    ) async {
      await pumpTab(tester);
      await threshold(tester, '20');
      await apply(tester);
      expect(find.text(_noAmount), findsOneWidget);
      await tester.ensureVisible(find.text(r'$ 15.00'));
      await tester.tap(find.text(r'$ 15.00'));
      await tester.pumpAndSettle();
      expect(find.text(_noAmount), findsNothing);
      await apply(tester);
      expect(submitted(tester).autoTopUpAmount, 15);
    });

    testWidgets('ATOP-003 entering a custom amount clears it', (tester) async {
      await pumpTab(tester);
      await threshold(tester, '20');
      await apply(tester);
      await custom(tester, '40');
      expect(find.text(_noAmount), findsNothing);
      await apply(tester);
      expect(submitted(tester).autoTopUpAmount, 40);
    });

    for (final (value, message) in [
      ('1', _min),
      ('4', _min),
      ('101', _max),
      ('150', _max),
    ]) {
      testWidgets('custom $value shows only its range error', (tester) async {
        await pumpTab(tester);
        await threshold(tester, '20');
        await custom(tester, value);
        await apply(tester);
        expect(find.text(message), findsOneWidget);
        for (final other in [_min, _max, _noAmount]) {
          if (other != message) expect(find.text(other), findsNothing);
        }
        expectNotSubmitted();
      });
    }

    for (final value in ['5', '100']) {
      testWidgets('custom boundary $value is valid', (tester) async {
        await pumpTab(tester);
        await threshold(tester, '20');
        await custom(tester, value);
        await apply(tester);
        expect(submitted(tester).autoTopUpAmount, double.parse(value));
      });
    }

    testWidgets('fixing a custom range error clears it and continues', (
      tester,
    ) async {
      await pumpTab(tester);
      await threshold(tester, '20');
      await custom(tester, '150');
      await apply(tester);
      expect(find.text(_max), findsOneWidget);
      await custom(tester, '100');
      expect(find.text(_max), findsNothing);
      await apply(tester);
      expect(submitted(tester).autoTopUpAmount, 100);
    });

    testWidgets('ATOP-001 card check still runs after valid amounts', (
      tester,
    ) async {
      await pumpTab(tester, saved: const []);
      await threshold(tester, '20');
      await custom(tester, '25');
      await apply(tester);
      expect(find.text(_cardError), findsOneWidget);
      expect(find.text('add a new card'), findsOneWidget);
      expect(find.text(_threshold), findsOneWidget);
      expect(helperColor(tester), const Color(0xFF707070));
      expectNotSubmitted();
    });
  });

  group('ATOP-007 authorization success', () {
    late _Devices devices;
    late _DeviceState deviceState;
    late _Account account;

    setUpAll(_loadFonts);

    setUp(() {
      devices = _Devices();
      deviceState = _DeviceState();
      account = _Account();
      when(() => deviceState.fullName).thenReturn(null);
      when(() => devices.state).thenReturn(deviceState);
      when(() => account.state).thenReturn(const AccountInfoState());
      instance.registerSingleton<DeviceLimitsCubit>(devices);
      instance.registerSingleton<AccountInfoCubit>(account);
    });

    tearDown(() async {
      await devices.close();
      await account.close();
      await instance.reset();
    });

    Future<void> submit(
      WidgetTester tester, {
      required bool alreadyConfigured,
      required bool succeeds,
      String name = 'User',
    }) async {
      when(() => deviceState.hasAutoTopUp).thenReturn(alreadyConfigured);
      when(
        () => devices.updateBalanceThresholdSettings(
          balanceThreshold: any(named: 'balanceThreshold'),
          autoTopUpAmount: any(named: 'autoTopUpAmount'),
          cardToken: any(named: 'cardToken'),
        ),
      ).thenAnswer((_) async => succeeds);
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const AutoTopUpAuthorizationScreen(
              balanceThreshold: 20,
              autoTopUpAmount: 25,
              cardToken: 'tok-1234',
              cardLastDigits: '1234',
            ),
          ),
          GoRoute(
            path: AppRoutes.home,
            builder: (_, _) => const Scaffold(body: Text('home')),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), name);
      await tester.ensureVisible(find.text('submit'));
      await tester.tap(find.text('submit'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    Future<void> finish(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    }

    testWidgets('new activation shows the started toast after success', (
      tester,
    ) async {
      await submit(tester, alreadyConfigured: false, succeeds: true);
      expect(find.text(_started), findsOneWidget);
      expect(find.text(_updated), findsNothing);
      verify(
        () => devices.updateBalanceThresholdSettings(
          balanceThreshold: 20,
          autoTopUpAmount: 25,
          cardToken: 'tok-1234',
        ),
      ).called(1);
      await finish(tester);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('updating existing auto top-up keeps its current toast', (
      tester,
    ) async {
      await submit(tester, alreadyConfigured: true, succeeds: true);
      expect(find.text(_updated), findsOneWidget);
      expect(find.text(_started), findsNothing);
      await finish(tester);
    });

    testWidgets('failed activation shows no success toast', (tester) async {
      await submit(tester, alreadyConfigured: false, succeeds: false);
      expect(find.text(_started), findsNothing);
      expect(
        find.text('Failed to update settings. Please try again.'),
        findsOneWidget,
      );
      await finish(tester);
      expect(find.text('home'), findsNothing);
    });

    testWidgets('name mismatch submits nothing and shows no success', (
      tester,
    ) async {
      await submit(
        tester,
        alreadyConfigured: false,
        succeeds: true,
        name: 'Someone',
      );
      expect(find.text(_started), findsNothing);
      verifyNever(
        () => devices.updateBalanceThresholdSettings(
          balanceThreshold: any(named: 'balanceThreshold'),
          autoTopUpAmount: any(named: 'autoTopUpAmount'),
          cardToken: any(named: 'cardToken'),
        ),
      );
      await finish(tester);
    });
  });
}
