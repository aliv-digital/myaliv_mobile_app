import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
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
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/view/top_up_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/balance/models/balance_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/prepaid_balance_card.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/theme/theme.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_event.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/repository/home_plans_payment_method_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/view/home_plans_payment_method_view.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/view/widgets/payment_method_content.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/widgets/home_plans_payment_method_section.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/card_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/screens/payment_iframe_screen.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_bottom_payBar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Repository extends Mock implements HomePlansPaymentMethodRepository {}

class _Network extends Mock implements NetworkService {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Balance extends MockCubit<BalanceState> implements BalanceCubit {}

class _Plans extends MockCubit<PlansState> implements PlansCubit {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Cards extends MockCubit<SavedCardsState> implements SavedCardsCubit {}

class _Observer extends NavigatorObserver {
  int pushes = 0;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
  }
}

const _message =
    'insufficient fund in your wallet, please top up and try again.';
const _card = SavedCardModel(token: 'saved-token', number: '************1234');
const _items = [
  HomePlansPaymentSelectedItem(
    id: '123',
    label: 'primary plan',
    title: 'liberty100',
    subtitle: '30 days',
    price: 100,
    planType: HomePlansPaymentPlanType.primary,
  ),
];
const _charge = HomePlansSavedPaymentMethod(
  id: 'charge-account',
  brand: HomePlansCardBrand.unknown,
  ending: '',
  expiry: '',
  logoSvgAsset: '',
  isChargeToMyAccount: true,
);

BalanceState _balanceState(double amount) => BalanceState(
  status: BalanceStatus.loaded,
  balance: BalanceModel(
    walletBalance: amount,
    bonusBalance: 0,
    bonusDetails: const [],
    fetchedAt: DateTime(2026, 10, 12),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Repository repository;
  late _Network network;
  late _Devices devices;
  late _Balance balance;
  late _Plans plans;
  late _Account account;
  late _Cards cards;
  late _Observer observer;
  late HomePlansPaymentMethodBloc bloc;

  setUpAll(() async {
    registerFallbackValue(HomePlansSubscriberType.prepaid);
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  setUp(() {
    repository = _Repository();
    network = _Network();
    devices = _Devices();
    balance = _Balance();
    plans = _Plans();
    account = _Account();
    cards = _Cards();
    observer = _Observer();
    when(() => devices.state).thenReturn(DeviceLimitsState.initial());
    when(() => devices.loadDeviceLimits()).thenAnswer((_) async {});
    when(() => balance.state).thenReturn(_balanceState(33.92));
    when(() => plans.state).thenReturn(const PlansState());
    when(() => account.state).thenReturn(const AccountInfoState());
    when(() => cards.state).thenReturn(
      const SavedCardsState(status: SavedCardsStatus.success, cards: [_card]),
    );
    when(() => cards.fetchSavedCards()).thenAnswer((_) async {});
    when(
      () => repository.fetchPaymentMethods(
        subscriberType: any(named: 'subscriberType'),
      ),
    ).thenAnswer(
      (invocation) async =>
          invocation.namedArguments[#subscriberType] ==
              HomePlansSubscriberType.postpaid
          ? [_charge]
          : [],
    );
    when(
      () => repository.payFromWallet(
        amount: 120,
        selectedItems: _items,
        promoCodes: const [],
        bonuses: const [],
        forceNow: true,
        selectedBeginDate: null,
      ),
    ).thenAnswer((_) async => 101);
    when(
      () => repository.payWithSavedCard(
        amount: 120,
        cardToken: _card.token,
        selectedItems: _items,
        promoCodes: const [],
        bonuses: const [],
        forceNow: true,
        selectedBeginDate: null,
      ),
    ).thenAnswer((_) async => 102);
    when(
      () => repository.chargeToAccount(
        amount: 120,
        selectedItems: _items,
        promoCodes: const [],
        bonuses: const [],
        forceNow: true,
        selectedBeginDate: null,
      ),
    ).thenAnswer((_) async => 103);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<SavedCardsCubit>(cards);
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<NetworkService>(network);
    instance.registerSingleton<CardPaymentService>(
      CardPaymentService(networkService: network),
    );
    instance.registerSingleton<AnalyticsService>(AnalyticsService());
  });

  tearDown(() async {
    await bloc.close();
    await devices.close();
    await balance.close();
    await plans.close();
    await account.close();
    await cards.close();
    await instance.reset();
  });

  Future<GoRouter> pumpScreen(
    WidgetTester tester, {
    double width = 390,
    double wallet = 33.92,
    bool postpaid = false,
    bool showHomeBalanceCard = false,
    bool contentOnly = false,
  }) async {
    bloc = HomePlansPaymentMethodBloc(repository: repository);
    when(() => balance.state).thenReturn(_balanceState(wallet));
    when(() => account.state).thenReturn(
      AccountInfoState(
        accountInfo: AccountInfoModel(
          paymentOption: postpaid ? 'PostPay' : 'PrePay',
        ),
      ),
    );
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      observers: [observer],
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => showHomeBalanceCard
              ? const Scaffold(body: PrepaidBalanceCard())
              : contentOnly
              ? Scaffold(
                  body:
                      BlocBuilder<
                        HomePlansPaymentMethodBloc,
                        HomePlansPaymentMethodState
                      >(
                        builder: (_, state) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 29),
                          child: PaymentMethodContent(
                            state: state,
                            isLoading: false,
                          ),
                        ),
                      ),
                )
              : const HomePlansPaymentMethodView(),
        ),
        GoRoute(
          path: AppRoutes.topUpPrepaidScreen,
          builder: (_, _) => const TopUpPrepaidScreen(),
        ),
        GoRoute(
          path: AppRoutes.homePlanPurchaseReceiptScreen,
          builder: (_, _) => const Scaffold(body: Text('existing receipt')),
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
          BlocProvider<SavedCardsCubit>.value(value: cards),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    bloc.add(
      HomePlansPaymentMethodStarted(
        subscriberType: postpaid
            ? HomePlansSubscriberType.postpaid
            : HomePlansSubscriberType.prepaid,
        amount: 120,
        vatNote: 'VAT inclusive',
        phoneNumber: '242-801-1616',
        selectedItems: _items,
        forceNow: true,
      ),
    );
    await tester.pumpAndSettle();
    // From here every repository interaction must be an intentional payment.
    clearInteractions(repository);
    return router;
  }

  Future<void> selectWallet(WidgetTester tester) async {
    await tester.tap(find.text('pay from wallet'));
    await tester.pumpAndSettle();
  }

  for (final width in [360.0, 390.0, 430.0]) {
    testWidgets('BILL-015 inline above methods and blocks payment at $width', (
      tester,
    ) async {
      final router = await pumpScreen(tester, width: width);
      expect(find.text(_message), findsNothing);
      await selectWallet(tester);
      expect(find.text(_message), findsOneWidget);
      expect(find.text('add top-up'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      final banner = find
          .ancestor(of: find.text(_message), matching: find.byType(Container))
          .first;
      final decoration =
          tester.widget<Container>(banner).decoration! as BoxDecoration;
      expect(decoration.color, HomePlanTheme.warningBackground);
      expect(decoration.border, Border.all(color: HomePlanTheme.warningBorder));
      expect(decoration.borderRadius, BorderRadius.circular(8));
      expect(
        tester.getBottomLeft(banner).dy,
        lessThan(
          tester.getTopLeft(find.byType(HomePlansPaymentMethodSection)).dy,
        ),
      );
      expect(
        tester.getTopLeft(banner).dx,
        tester.getTopLeft(find.byType(HomePlansPaymentMethodSection)).dx,
      );
      expect(
        tester.widget<Icon>(find.byIcon(Icons.error_outline)).color,
        HomePlanTheme.warningText,
      );
      expect(
        tester.widget<Text>(find.text(_message)).style,
        HomePlanTheme.bottomSheetWarning,
      );
      final before = bloc.state;
      final pushes = observer.pushes;
      for (var attempt = 0; attempt < 2; attempt++) {
        await tester.tap(find.text('pay now'));
        await tester.pumpAndSettle();
        expect(bloc.state, before);
        expect(observer.pushes, pushes);
        expect(router.routeInformationProvider.value.uri.path, '/');
        expect(find.text('confirm payment'), findsNothing);
        expect(find.byType(PaymentIFrameScreen), findsNothing);
        expect(find.text('existing receipt'), findsNothing);
        verifyZeroInteractions(repository);
        verifyZeroInteractions(network);
      }
      final bar = tester.widget<DefaultBottomPayBar>(
        find.byType(DefaultBottomPayBar),
      );
      expect(bar.amountText, before.amountText);
      expect(bar.amountText, contains('120.00'));
      expect(find.text('VAT inclusive'), findsOneWidget);
      expect(bloc.state.amount, 120);
      expect(bloc.state.selectedItems, _items);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('BILL-015 banner and methods fit a narrow 320px layout', (
    tester,
  ) async {
    await pumpScreen(tester, width: 320, contentOnly: true);
    await selectWallet(tester);
    expect(find.text(_message), findsOneWidget);
    expect(find.text('add top-up'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('warning follows wallet selection and live balance updates', (
    tester,
  ) async {
    final updates = StreamController<BalanceState>.broadcast();
    addTearDown(updates.close);
    whenListen(balance, updates.stream, initialState: _balanceState(33.92));
    await pumpScreen(tester);
    await selectWallet(tester);
    expect(find.text(_message), findsOneWidget);
    await tester.tap(find.text('pay with card'));
    await tester.pumpAndSettle();
    expect(find.text(_message), findsNothing);
    await selectWallet(tester);
    expect(find.text(_message), findsOneWidget);
    updates.add(_balanceState(120));
    await tester.pumpAndSettle();
    expect(find.text(_message), findsNothing);
    updates.add(_balanceState(119.99));
    await tester.pumpAndSettle();
    expect(find.text(_message), findsOneWidget);
    verifyZeroInteractions(repository);
    verifyZeroInteractions(network);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final wallet in [120.0, 120.01]) {
    testWidgets(
      'wallet $wallet preserves confirmation and successful payment',
      (tester) async {
        await pumpScreen(tester, wallet: wallet);
        await selectWallet(tester);
        expect(find.text(_message), findsNothing);
        await tester.tap(find.text('pay now'));
        await tester.pumpAndSettle();
        expect(find.text('confirm payment'), findsOneWidget);
        verifyZeroInteractions(repository);
        await tester.tap(find.text('confirm payment'));
        await tester.pumpAndSettle();
        verify(
          () => repository.payFromWallet(
            amount: 120,
            selectedItems: _items,
            promoCodes: const [],
            bonuses: const [],
            forceNow: true,
            selectedBeginDate: null,
          ),
        ).called(1);
        expect(find.text('existing receipt'), findsOneWidget);
        expect(bloc.state.amount, 120);
        expect(bloc.state.vatNote, 'VAT inclusive');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  testWidgets('saved card remains payable with insufficient wallet', (
    tester,
  ) async {
    await pumpScreen(tester);
    await selectWallet(tester);
    await tester.tap(find.text(_card.displayLabel));
    await tester.pumpAndSettle();
    expect(find.text(_message), findsNothing);
    await tester.tap(find.text('pay now'));
    await tester.pumpAndSettle();
    expect(find.text('confirm payment'), findsOneWidget);
    await tester.tap(find.text('confirm payment'));
    await tester.pumpAndSettle();
    verify(
      () => repository.payWithSavedCard(
        amount: 120,
        cardToken: _card.token,
        selectedItems: _items,
        promoCodes: const [],
        bonuses: const [],
        forceNow: true,
        selectedBeginDate: null,
      ),
    ).called(1);
    expect(find.text('existing receipt'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('new card retains existing 3DS action despite wallet warning', (
    tester,
  ) async {
    when(
      () => network.request<dynamic>(
        Api.changeBundleDs3Url,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: null,
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: Api.changeBundleDs3Url),
        statusCode: 200,
        data: <String, dynamic>{},
      ),
    );
    await pumpScreen(tester);
    await selectWallet(tester);
    await tester.tap(find.text('pay with card'));
    await tester.pumpAndSettle();
    expect(find.text(_message), findsNothing);
    await tester.tap(find.text('pay now'));
    await tester.pumpAndSettle();
    expect(find.byType(PaymentIFrameScreen), findsOneWidget);
    final payment = tester.widget<PaymentIFrameScreen>(
      find.byType(PaymentIFrameScreen),
    );
    expect(payment.request.url, Api.changeBundleDs3Url);
    expect(payment.request.body['Bundle'], {
      'PrimaryPlans': [123],
      'SecondaryPlans': <int>[],
      'StandalonePlans': <int>[],
    });
    expect(payment.request.body['ForceNow'], true);
    expect(payment.request.skipAuth, false);
    verify(
      () => network.request<dynamic>(
        Api.changeBundleDs3Url,
        method: HttpMethod.post,
        data: payment.request.body,
        options: null,
      ),
    ).called(1);
    verifyZeroInteractions(repository);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Postpaid account charge is not gated by wallet funds', (
    tester,
  ) async {
    await pumpScreen(tester, postpaid: true, wallet: 0);
    expect(find.text('pay from wallet'), findsNothing);
    expect(find.text(_message), findsNothing);
    expect(find.text('add top-up'), findsNothing);
    await tester.tap(find.text('pay now'));
    await tester.pumpAndSettle();
    verify(
      () => repository.chargeToAccount(
        amount: 120,
        selectedItems: _items,
        promoCodes: const [],
        bonuses: const [],
        forceNow: true,
        selectedBeginDate: null,
      ),
    ).called(1);
    expect(find.text('existing receipt'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  for (final fromHome in [false, true]) {
    testWidgets(
      'add top-up uses production destination and stack (Home: $fromHome)',
      (tester) async {
        when(
          () => network.request<dynamic>(
            Api.topUpLimitLeft,
            method: HttpMethod.get,
          ),
        ).thenAnswer(
          (_) async => Response<dynamic>(
            requestOptions: RequestOptions(path: Api.topUpLimitLeft),
            statusCode: 200,
            data: {'LimitLeft': 500},
          ),
        );
        final router = await pumpScreen(tester, showHomeBalanceCard: fromHome);
        if (!fromHome) await selectWallet(tester);
        await tester.tap(find.text('add top-up'));
        await tester.pumpAndSettle();
        expect(
          GoRouterState.of(
            tester.element(find.byType(TopUpPrepaidScreen)),
          ).uri.path,
          AppRoutes.topUpPrepaidScreen,
        );
        expect(find.byType(TopUpPrepaidScreen), findsOneWidget);
        expect(
          tester
              .widget<TopUpPrepaidScreen>(find.byType(TopUpPrepaidScreen))
              .initialTab,
          0,
        );
        expect(router.canPop(), true);
        router.pop();
        await tester.pumpAndSettle();
        expect(router.routeInformationProvider.value.uri.path, '/');
        if (fromHome) {
          expect(find.byType(PrepaidBalanceCard), findsOneWidget);
        } else {
          expect(find.byType(HomePlansPaymentMethodView), findsOneWidget);
          expect(bloc.state.paymentMode, HomePlansPaymentMode.payFromWallet);
          expect(find.text(_message), findsOneWidget);
        }
        verifyZeroInteractions(repository);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }

  test(
    'existing Bloc guard still rejects bypassed insufficient confirmation',
    () async {
      bloc = HomePlansPaymentMethodBloc(repository: repository);
      bloc.add(
        const HomePlansPaymentMethodStarted(
          subscriberType: HomePlansSubscriberType.prepaid,
          amount: 120,
          selectedItems: _items,
          forceNow: true,
        ),
      );
      await bloc.stream.firstWhere(
        (state) => state.status == HomePlansPaymentMethodStatus.ready,
      );
      clearInteractions(repository);
      bloc.add(const HomePlansPayFromWalletPressed());
      await bloc.stream.firstWhere(
        (state) => state.paymentMode == HomePlansPaymentMode.payFromWallet,
      );
      bloc.add(const HomePlansPayFromWalletConfirmed(walletBalance: 33.92));
      await bloc.stream.firstWhere(
        (state) => state.walletWarningRequestId == 1,
      );
      expect(bloc.state.status, HomePlansPaymentMethodStatus.ready);
      expect(bloc.state.navTarget, HomePlansPaymentMethodNavTarget.none);
      verifyZeroInteractions(repository);
      verifyZeroInteractions(network);
    },
  );
}
