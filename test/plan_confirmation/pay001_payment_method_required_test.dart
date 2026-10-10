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
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/view/top_up_payment_screen.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_event.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/repository/home_plans_payment_method_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/view/home_plans_payment_method_view.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/top_up_payment_service.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class _Repository extends Mock implements HomePlansPaymentMethodRepository {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Balance extends MockCubit<BalanceState> implements BalanceCubit {}

class _BalanceState extends Mock implements BalanceState {}

class _Plans extends MockCubit<PlansState> implements PlansCubit {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Cards extends MockCubit<SavedCardsState> implements SavedCardsCubit {}

class _TopUpService extends Mock implements TopUpPaymentService {}

const _error = 'choose a payment method to continue';
const _realCard = SavedCardModel(token: 'tok-real', number: '************1234');

// The plan bloc's repository pre-selects this id; it is not a real saved card.
const _mockMethod = HomePlansSavedPaymentMethod(
  id: 'visa-1234',
  brand: HomePlansCardBrand.visa,
  ending: '1234',
  expiry: '06/2024',
  logoSvgAsset: '',
);

const _chargeToAccount = HomePlansSavedPaymentMethod(
  id: 'charge-account',
  brand: HomePlansCardBrand.unknown,
  ending: '',
  expiry: '',
  logoSvgAsset: '',
  isChargeToMyAccount: true,
);

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
  late _Repository repository;
  late _Devices devices;
  late _Balance balance;
  late _Plans plans;
  late _Account account;
  late _Cards cards;

  setUpAll(() async {
    registerFallbackValue(HomePlansSubscriberType.prepaid);
    await _loadFonts();
  });

  setUp(() {
    repository = _Repository();
    devices = _Devices();
    balance = _Balance();
    plans = _Plans();
    account = _Account();
    cards = _Cards();
    final balanceState = _BalanceState();
    when(() => balanceState.walletBalance).thenReturn(200);
    when(() => balance.state).thenReturn(balanceState);
    when(() => devices.state).thenReturn(DeviceLimitsState.initial());
    when(() => devices.loadDeviceLimits()).thenAnswer((_) async {});
    when(() => account.state).thenReturn(const AccountInfoState());
    when(() => plans.state).thenReturn(const PlansState());
    when(() => cards.fetchSavedCards()).thenAnswer((_) async {});
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<SavedCardsCubit>(cards);
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<AnalyticsService>(AnalyticsService());
  });

  tearDown(() async {
    await devices.close();
    await balance.close();
    await plans.close();
    await account.close();
    await cards.close();
    await instance.reset();
  });

  Future<void> settleToasts(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  group('PAY-001 plan payment screen', () {
    late HomePlansPaymentMethodBloc bloc;

    tearDown(() => bloc.close());

    Future<void> pumpPlanPayment(
      WidgetTester tester, {
      HomePlansSubscriberType subscriberType = HomePlansSubscriberType.prepaid,
      List<HomePlansSavedPaymentMethod> methods = const [_mockMethod],
      List<SavedCardModel> saved = const [_realCard],
    }) async {
      when(() => cards.state).thenReturn(
        SavedCardsState(status: SavedCardsStatus.success, cards: saved),
      );
      when(
        () => repository.fetchPaymentMethods(
          subscriberType: any(named: 'subscriberType'),
        ),
      ).thenAnswer((_) async => methods);
      bloc = HomePlansPaymentMethodBloc(repository: repository);
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const HomePlansPaymentMethodView(),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<HomePlansPaymentMethodBloc>.value(value: bloc),
            BlocProvider<BalanceCubit>.value(value: balance),
            BlocProvider<PlansCubit>.value(value: plans),
            BlocProvider<AccountInfoCubit>.value(value: account),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      bloc.add(
        HomePlansPaymentMethodStarted(
          subscriberType: subscriberType,
          phoneNumber: '242-801-1616',
          amount: 110,
          selectedItems: const [],
          forceNow: true,
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> payNow(WidgetTester tester) async {
      await tester.tap(find.text('pay now'));
      await tester.pumpAndSettle();
    }

    void expectNoPayment() {
      verifyNever(
        () => repository.payFromWallet(
          amount: any(named: 'amount'),
          selectedItems: any(named: 'selectedItems'),
          promoCodes: any(named: 'promoCodes'),
          bonuses: any(named: 'bonuses'),
          forceNow: any(named: 'forceNow'),
          selectedBeginDate: any(named: 'selectedBeginDate'),
        ),
      );
      verifyNever(
        () => repository.payWithSavedCard(
          amount: any(named: 'amount'),
          cardToken: any(named: 'cardToken'),
          selectedItems: any(named: 'selectedItems'),
          promoCodes: any(named: 'promoCodes'),
          bonuses: any(named: 'bonuses'),
          forceNow: any(named: 'forceNow'),
          selectedBeginDate: any(named: 'selectedBeginDate'),
        ),
      );
    }

    testWidgets('nothing usable selected + pay now shows PAY-001 inline', (
      tester,
    ) async {
      await pumpPlanPayment(tester);
      expect(find.text(_error), findsNothing);
      await payNow(tester);
      expect(find.text(_error), findsOneWidget);
      // No confirmation sheet opened, nothing paid.
      expect(find.text('confirm payment'), findsNothing);
      expectNoPayment();
    });

    testWidgets('selecting a real saved card clears it and continues', (
      tester,
    ) async {
      await pumpPlanPayment(tester);
      await payNow(tester);
      expect(find.text(_error), findsOneWidget);

      bloc.add(const HomePlansPaymentMethodSelected('tok-real'));
      await tester.pumpAndSettle();
      expect(find.text(_error), findsNothing);
      await payNow(tester);
      // The existing saved-card confirmation sheet opens.
      expect(find.text('confirm payment'), findsOneWidget);
      expect(find.textContaining('1234'), findsWidgets);
    });

    testWidgets('choosing pay from wallet clears it and opens the wallet', (
      tester,
    ) async {
      await pumpPlanPayment(tester);
      await payNow(tester);
      bloc.add(const HomePlansPayFromWalletPressed());
      await tester.pumpAndSettle();
      expect(find.text(_error), findsNothing);
      await payNow(tester);
      expect(find.text('confirm payment'), findsOneWidget);
    });

    testWidgets('postpaid charge-to-account default is valid (no PAY-001)', (
      tester,
    ) async {
      await pumpPlanPayment(
        tester,
        subscriberType: HomePlansSubscriberType.postpaid,
        methods: const [_chargeToAccount, _mockMethod],
      );
      when(
        () => repository.chargeToAccount(
          amount: any(named: 'amount'),
          selectedItems: any(named: 'selectedItems'),
          promoCodes: any(named: 'promoCodes'),
          bonuses: any(named: 'bonuses'),
          forceNow: any(named: 'forceNow'),
          selectedBeginDate: any(named: 'selectedBeginDate'),
        ),
      ).thenAnswer((_) async => null);
      await tester.tap(find.text('pay now'));
      await tester.pump();
      expect(find.text(_error), findsNothing);
      await settleToasts(tester);
    });
  });

  group('PAY-001 top-up payment screen', () {
    Future<void> pumpTopUpPayment(
      WidgetTester tester, {
      List<SavedCardModel> saved = const [],
    }) async {
      // Like the real cubit: loading first, then the loaded cards, which is
      // what triggers the section's existing auto-select listener.
      final cardStates = StreamController<SavedCardsState>.broadcast();
      addTearDown(cardStates.close);
      whenListen(
        cards,
        cardStates.stream,
        initialState: const SavedCardsState(status: SavedCardsStatus.loading),
      );
      instance.registerSingleton<TopUpPaymentService>(_TopUpService());
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final config = AppUiConfigCubit();
      addTearDown(config.close);
      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const TopUpPaymentScreen(amount: 25),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<SavedCardsCubit>.value(value: cards),
            BlocProvider<AppUiConfigCubit>.value(value: config),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
      cardStates.add(
        SavedCardsState(status: SavedCardsStatus.success, cards: saved),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('no saved card + pay now shows PAY-001 inline', (tester) async {
      await pumpTopUpPayment(tester);
      expect(find.text(_error), findsNothing);
      await tester.tap(find.text('pay now'));
      await tester.pumpAndSettle();
      expect(find.text(_error), findsOneWidget);
      expect(find.text('confirm payment'), findsNothing);
    });

    testWidgets('choosing pay with card clears it', (tester) async {
      await pumpTopUpPayment(tester);
      await tester.tap(find.text('pay now'));
      await tester.pumpAndSettle();
      expect(find.text(_error), findsOneWidget);
      await tester.tap(find.text('pay with card'));
      await tester.pumpAndSettle();
      expect(find.text(_error), findsNothing);
    });

    testWidgets('an auto-selected saved card pays as before', (tester) async {
      await pumpTopUpPayment(tester, saved: const [_realCard]);
      await tester.tap(find.text('pay now'));
      await tester.pumpAndSettle();
      expect(find.text(_error), findsNothing);
      // The existing saved-card confirmation sheet opens.
      expect(find.text('confirm payment'), findsOneWidget);
    });
  });
}
