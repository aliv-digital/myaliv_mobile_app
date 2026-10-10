import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/repository/auto_renew_auth_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/bloc/auto_renew_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/view/auto_renew_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Cards extends MockCubit<SavedCardsState> implements SavedCardsCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Balance extends MockCubit<BalanceState> implements BalanceCubit {}

class _Verification extends Mock implements CallLogsVerificationRepository {}

class _Auth extends Mock implements AuthManager {}

const _error = 'select a card or wallet to continue';
const _continue = 'use for auto renew';
const _card = SavedCardModel(token: 'tok-1234', number: '************1234');

void main() {
  late _Cards cards;
  late _Devices devices;
  late _Balance balance;
  late StreamController<SavedCardsState> cardStates;
  AutoRenewAuthArgs? auth;
  var addCardVisits = 0;

  setUpAll(() async {
    registerFallbackValue(UserType.prepaid);
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
    balance = _Balance();
    cardStates = StreamController<SavedCardsState>.broadcast();
    auth = null;
    addCardVisits = 0;
    when(
      () => cards.fetchSavedCards(
        forceRefresh: any(named: 'forceRefresh'),
        userType: any(named: 'userType'),
      ),
    ).thenAnswer((_) async {});
    whenListen(
      cards,
      cardStates.stream,
      initialState: const SavedCardsState(
        status: SavedCardsStatus.success,
        cards: [_card],
      ),
    );
    whenListen(
      devices,
      const Stream<DeviceLimitsState>.empty(),
      initialState: DeviceLimitsState.initial(),
    );
    when(() => devices.loadDeviceLimits()).thenAnswer((_) async {});
    when(() => balance.state).thenReturn(BalanceState.initial());
    instance.registerSingleton<SavedCardsCubit>(cards);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<BalanceCubit>(balance);
    // Built by the page's existing verification helper; unused here.
    instance.registerSingleton<CallLogsVerificationRepository>(_Verification());
    instance.registerSingleton<AuthManager>(_Auth());
  });

  tearDown(() async {
    await cardStates.close();
    await cards.close();
    await devices.close();
    await balance.close();
    await instance.reset();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const AutoRenewPrepaidScreen()),
        GoRoute(
          path: AppRoutes.autoRenewAuthPrepaidScreen,
          builder: (_, state) {
            auth = state.extra! as AutoRenewAuthArgs;
            return const Scaffold(body: Text('existing auth'));
          },
        ),
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
    final config = AppUiConfigCubit();
    addTearDown(config.close);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<BalanceCubit>.value(value: balance),
          BlocProvider<AppUiConfigCubit>.value(value: config),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapText(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapContinue(WidgetTester tester) =>
      tapText(tester, find.text(_continue));

  AutoRenewPrepaidBloc bloc(WidgetTester tester) =>
      tester.element(find.text(_continue)).read<AutoRenewPrepaidBloc>();

  testWidgets('arrives with no card or wallet selected', (tester) async {
    await pumpScreen(tester);
    final state = bloc(tester).state;
    expect(state.selectedCard, isNull);
    expect(state.isWalletSelected, isFalse);
    expect(state.canProceed, isFalse);
    expect(find.text(_error), findsNothing);
  });

  testWidgets('continue with nothing selected shows AREN-002 and stops', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tapContinue(tester);
    expect(find.text(_error), findsOneWidget);
    expect(auth, isNull);
    expect(addCardVisits, 0);
    verifyNever(() => devices.enableAutoRenewWallet(any()));
    verifyNever(() => devices.disableAutoRenew(any()));
  });

  testWidgets('selecting a saved card clears it and continues as before', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tapContinue(tester);
    expect(find.text(_error), findsOneWidget);

    await tapText(tester, find.textContaining('ending in 1234'));
    expect(find.text(_error), findsNothing);
    await tapContinue(tester);
    expect(find.text('existing auth'), findsOneWidget);
    expect(auth!.paymentMethod, AutoRenewPaymentMethodType.card);
    expect(auth!.cardToken, 'tok-1234');
  });

  testWidgets('selecting wallet clears it and runs the existing wallet path', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tapContinue(tester);
    await tapText(tester, find.text('pay from wallet'));
    expect(find.text(_error), findsNothing);
    expect(bloc(tester).state.isWalletSelected, isTrue);

    await tester.ensureVisible(find.text(_continue));
    await tester.tap(find.text(_continue));
    await tester.pump(const Duration(milliseconds: 300));
    // No device in this test, so the existing wallet guard answers.
    expect(find.text('Device info not available'), findsOneWidget);
    expect(find.text(_error), findsNothing);
    expect(auth, isNull);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('add-card entry stays as it is (not shown on this screen)', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.text('pay with card'), findsNothing);
    await tapContinue(tester);
    expect(addCardVisits, 0);
  });
}
