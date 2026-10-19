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
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/models/user_profile_receipt_route_args.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/models/user_profile_receipt_variant.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/receipt/view/user_profile_receipt_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/bloc/pay_from_wallet/pay_from_wallet_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/repository/send_topup_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/pay_from_wallet.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/balance/models/balance_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/plan_purchase_context.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanPurchaseReceipt/bloc/home_plan_purchase_receipt_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanPurchaseReceipt/view/home_plan_purchase_receipt_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_event.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/repository/home_plans_payment_method_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/view/home_plans_payment_method_view.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/wallet_payment_success.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Repository extends Mock implements HomePlansPaymentMethodRepository {}

class _Network extends Mock implements NetworkService {}

class _Analytics extends Mock implements AnalyticsService {}

class _Auth extends Mock implements AuthManager {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Device extends Mock implements DeviceLimitsModel {}

class _Balance extends MockCubit<BalanceState> implements BalanceCubit {}

class _Cards extends MockCubit<SavedCardsState> implements SavedCardsCubit {}

class _Plans extends MockCubit<PlansState> implements PlansCubit {}

class _PlanBloc extends HomePlansPaymentMethodBloc {
  _PlanBloc(HomePlansPaymentMethodRepository repository)
    : super(repository: repository);

  void repeatSuccess() {
    emit(
      state.copyWith(
        navTarget: HomePlansPaymentMethodNavTarget.paid,
        errorMessage: 'duplicate emission',
      ),
    );
  }
}

class _TransferCubit extends PayFromWalletCubit {
  _TransferCubit(super.repository);

  @override
  Future<void> submitTransfer({
    required String toNumber,
    required double amount,
  }) async {
    await super.submitTransfer(toNumber: toNumber, amount: amount);
    if (!isClosed && state.isSuccess) {
      emit(state.copyWith(errorMessage: 'duplicate success emission'));
    }
  }
}

class _Observer extends NavigatorObserver {
  int pushes = 0;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes++;
  }
}

const _suffix = 'Your payment was successfully processed from your wallet.';
String _message(String name) => 'Thank you, $name! $_suffix';

const _primary = HomePlansPaymentSelectedItem(
  id: '123',
  label: 'primary plan',
  title: 'Liberty 70',
  subtitle: '',
  price: 70,
  planType: HomePlansPaymentPlanType.primary,
);
const _addon = HomePlansPaymentSelectedItem(
  id: '124',
  label: 'add-on',
  title: 'Liberty Data 1',
  subtitle: '',
  price: 5,
  planType: HomePlansPaymentPlanType.secondary,
);
const _roaming = HomePlansPaymentSelectedItem(
  id: '125',
  label: 'plan',
  title: 'Roaming 7',
  subtitle: '',
  price: 30,
  planType: HomePlansPaymentPlanType.standalone,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Repository repository;
  late _Network network;
  late _Analytics analytics;
  late _Account account;
  late _Devices devices;
  late _Balance balance;
  late _Cards cards;
  late _Plans plans;
  late _Auth auth;
  late _Observer observer;
  late Completer<int?> planPayment;
  late Completer<Response<dynamic>> transfer;
  _PlanBloc? planBloc;
  GoRouter? router;
  WalletPaymentSuccess? planSuccess;
  UserProfileReceiptRouteArgs? transferArgs;

  setUpAll(() async {
    registerFallbackValue(HttpMethod.post);
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
    analytics = _Analytics();
    account = _Account();
    devices = _Devices();
    balance = _Balance();
    cards = _Cards();
    plans = _Plans();
    auth = _Auth();
    observer = _Observer();
    planPayment = Completer<int?>();
    transfer = Completer<Response<dynamic>>();
    planBloc = null;
    router = null;
    planSuccess = null;
    transferArgs = null;
    when(() => account.state).thenReturn(
      const AccountInfoState(
        status: AccountInfoStatus.success,
        accountInfo: AccountInfoModel(
          fName: 'John',
          lName: 'Doe',
          email: 'john@example.test',
          phoneNumber: '2428011616',
          paymentOption: 'PrePay',
        ),
      ),
    );
    when(() => devices.state).thenReturn(DeviceLimitsState.initial());
    when(() => devices.loadDeviceLimits()).thenAnswer((_) async {});
    when(() => balance.state).thenReturn(
      BalanceState(
        status: BalanceStatus.loaded,
        balance: BalanceModel(
          walletBalance: 1000,
          bonusBalance: 0,
          bonusDetails: const [],
          fetchedAt: DateTime(2026),
        ),
      ),
    );
    when(() => cards.state).thenReturn(const SavedCardsState());
    when(() => cards.fetchSavedCards()).thenAnswer((_) async {});
    when(() => plans.state).thenReturn(const PlansState());
    when(() => plans.isClosed).thenReturn(false);
    when(() => plans.refreshBundlesOnly()).thenAnswer((_) async {});
    when(() => auth.currentSession).thenReturn(
      TokenSession(
        accessToken: 'test-access',
        refreshToken: 'test-refresh',
        accessExpiresAt: DateTime(2030),
        refreshExpiresAt: DateTime(2031),
      ),
    );
    when(
      () => repository.fetchPaymentMethods(
        subscriberType: any(named: 'subscriberType'),
      ),
    ).thenAnswer((_) async => []);
    when(
      () => repository.payFromWallet(
        amount: any(named: 'amount'),
        selectedItems: any(named: 'selectedItems'),
        promoCodes: any(named: 'promoCodes'),
        bonuses: any(named: 'bonuses'),
        forceNow: any(named: 'forceNow'),
        selectedBeginDate: any(named: 'selectedBeginDate'),
      ),
    ).thenAnswer((_) => planPayment.future);
    when(
      () => repository.payWithSavedCard(
        amount: any(named: 'amount'),
        cardToken: any(named: 'cardToken'),
        selectedItems: any(named: 'selectedItems'),
        promoCodes: any(named: 'promoCodes'),
        bonuses: any(named: 'bonuses'),
        forceNow: any(named: 'forceNow'),
        selectedBeginDate: any(named: 'selectedBeginDate'),
      ),
    ).thenAnswer((_) => planPayment.future);
    when(
      () => repository.chargeToAccount(
        amount: any(named: 'amount'),
        selectedItems: any(named: 'selectedItems'),
        promoCodes: any(named: 'promoCodes'),
        bonuses: any(named: 'bonuses'),
        forceNow: any(named: 'forceNow'),
        selectedBeginDate: any(named: 'selectedBeginDate'),
      ),
    ).thenAnswer((_) => planPayment.future);
    when(
      () => analytics.logPlanPurchase(
        planId: any(named: 'planId'),
        planName: any(named: 'planName'),
        amount: any(named: 'amount'),
        paymentMethod: any(named: 'paymentMethod'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => analytics.logAddonPurchase(
        addonId: any(named: 'addonId'),
        addonName: any(named: 'addonName'),
        amount: any(named: 'amount'),
        paymentMethod: any(named: 'paymentMethod'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => analytics.logWalletFunding(
        amount: any(named: 'amount'),
        paymentMethod: any(named: 'paymentMethod'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => network.request<dynamic>(
        Api.orderTransferUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) => transfer.future);
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<SavedCardsCubit>(cards);
    instance.registerSingleton<AnalyticsService>(analytics);
    instance.registerSingleton<AuthManager>(auth);
    instance.registerSingleton<NetworkService>(network);
    instance.registerFactory<PayFromWalletCubit>(
      () => _TransferCubit(SendTopupRepository(networkService: network)),
    );
  });

  tearDown(() async {
    if (!planPayment.isCompleted) {
      planPayment.complete(null);
    }
    router?.dispose();
    await planBloc?.close();
    await account.close();
    await devices.close();
    await balance.close();
    await cards.close();
    await plans.close();
    await instance.reset();
  });

  Widget app(Widget child) => MultiBlocProvider(
    providers: [
      BlocProvider<AccountInfoCubit>.value(value: account),
      BlocProvider<BalanceCubit>.value(value: balance),
      BlocProvider<PlansCubit>.value(value: plans),
      if (planBloc != null)
        BlocProvider<HomePlansPaymentMethodBloc>.value(value: planBloc!),
    ],
    child: child,
  );

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  }

  void size(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> openPlan(
    WidgetTester tester, {
    List<HomePlansPaymentSelectedItem> items = const [_primary],
    bool forceNow = true,
    HomePlansSubscriberType subscriberType = HomePlansSubscriberType.prepaid,
  }) async {
    size(tester);
    planPayment = Completer<int?>();
    planBloc = _PlanBloc(repository);
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      observers: [observer],
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    context.push(AppRoutes.homePlansPaymentMethodScreen),
                child: const Text('existing confirmation'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.homePlansPaymentMethodScreen,
          builder: (_, _) => const HomePlansPaymentMethodView(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const Scaffold(body: Text('existing home')),
        ),
        GoRoute(
          path: AppRoutes.homePlanPurchaseReceiptScreen,
          builder: (_, state) {
            final extra = state.extra! as Map<String, dynamic>;
            if (extra['isPaymentFailed'] == true) {
              return const HomePlanPurchaseReceiptScreen(
                phoneNumber: '2428011616',
                amount: 0,
                dateText: '',
                timeText: '',
                isPaymentFailed: true,
              );
            }
            planSuccess =
                extra['walletPaymentSuccess'] as WalletPaymentSuccess?;
            return HomePlanPurchaseReceiptScreen(
              phoneNumber: extra['phoneNumber'] as String,
              amount: extra['amount'] as double,
              dateText: extra['dateText'] as String,
              timeText: extra['timeText'] as String,
              paymentMethod: extra['paymentMethod'] as String,
              statusMessage: extra['statusMessage'] as String,
              leftType: extra['leftType'] as String,
              rightType: extra['rightType'] as String,
              details:
                  extra['details'] as List<HomePlanPurchaseReceiptDetailItem>,
              walletPaymentSuccess: planSuccess,
            );
          },
        ),
      ],
    );
    await tester.pumpWidget(app(MaterialApp.router(routerConfig: router)));
    planBloc!.add(
      HomePlansPaymentMethodStarted(
        subscriberType: subscriberType,
        phoneNumber: '2428011616',
        amount: 77,
        selectedItems: items,
        forceNow: forceNow,
        selectedBeginDate: forceNow
            ? null
            : DateTime.now().add(const Duration(days: 10)),
        purchaseContext: PlanPurchaseContext.prepaidImmediatePrimaryReplacement,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('existing confirmation'));
    await tester.pumpAndSettle();
  }

  Future<void> confirmPlanWallet(WidgetTester tester) async {
    planBloc!.add(const HomePlansPayFromWalletPressed());
    await tester.pumpAndSettle();
    expect(find.textContaining(_suffix), findsNothing);
    await tester.tap(find.text('pay now'));
    await tester.pumpAndSettle();
    expect(find.textContaining(_suffix), findsNothing);
    await tester.tap(find.text('confirm payment'));
    await tester.pump();
    expect(planBloc!.state.status, HomePlansPaymentMethodStatus.submitting);
    expect(find.byType(HomePlanPurchaseReceiptScreen), findsNothing);
    expect(find.textContaining(_suffix), findsNothing);
  }

  void verifyOnePlanPayment() {
    verify(
      () => repository.payFromWallet(
        amount: 77,
        selectedItems: any(named: 'selectedItems'),
        promoCodes: const [],
        bonuses: const [],
        forceNow: any(named: 'forceNow'),
        selectedBeginDate: any(named: 'selectedBeginDate'),
      ),
    ).called(1);
    verifyNever(
      () => account.fetchAccountInfo(forceRefresh: any(named: 'forceRefresh')),
    );
    verifyZeroInteractions(network);
  }

  for (final variant in [
    (name: 'primary', items: const [_primary], now: true),
    (name: 'primary and add-on', items: const [_primary, _addon], now: true),
    (name: 'add-on', items: const [_addon], now: true),
    (name: 'scheduled primary', items: const [_primary], now: false),
    (name: 'roaming', items: const [_roaming], now: true),
    (name: 'scheduled roaming', items: const [_roaming], now: false),
  ]) {
    testWidgets('${variant.name} wallet success toasts only on receipt once', (
      tester,
    ) async {
      await openPlan(tester, items: variant.items, forceNow: variant.now);
      await confirmPlanWallet(tester);
      final before = observer.pushes;
      planPayment.complete(101);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(planBloc!.state.status, HomePlansPaymentMethodStatus.success);
      await tester.pumpAndSettle();
      expect(find.byType(HomePlanPurchaseReceiptScreen), findsOneWidget);
      expect(find.text(_message('John Doe')), findsOneWidget);
      expect(find.text('Payment Success!'), findsOneWidget);
      if (variant.now && variant.items.contains(_primary)) {
        expect(
          find.text('Your Liberty 70 was added successfully.'),
          findsOneWidget,
        );
      }
      expect(observer.pushes, before + 1);
      expect(planBloc!.state.walletPaymentSucceeded, isTrue);
      verifyOnePlanPayment();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.textContaining(_suffix), findsNothing);
      final receiptPushes = observer.pushes;
      planBloc!.repeatSuccess();
      await tester.pumpWidget(app(MaterialApp.router(routerConfig: router)));
      await tester.pumpAndSettle();
      expect(observer.pushes, receiptPushes);
      expect(find.textContaining(_suffix), findsNothing);
      verifyNoMoreInteractions(network);
      await finish(tester);
    });
  }

  for (final name in [null, '', '   ', 'User']) {
    testWidgets('plan wallet receipt uses lowercase user for name=$name', (
      tester,
    ) async {
      when(() => account.state).thenReturn(
        AccountInfoState(
          accountInfo: AccountInfoModel(
            fName: name ?? '',
            email: 'john@example.test',
            paymentOption: 'PrePay',
          ),
        ),
      );
      await openPlan(tester);
      await confirmPlanWallet(tester);
      planPayment.complete(null);
      await tester.pumpAndSettle();
      expect(find.text(_message('user')), findsOneWidget);
      expect(find.text(_message('john')), findsNothing);
      await finish(tester);
    });
  }

  testWidgets('a second confirmed wallet transaction receives its own toast', (
    tester,
  ) async {
    await openPlan(tester);
    await confirmPlanWallet(tester);
    planPayment.complete(101);
    await tester.pumpAndSettle();
    expect(find.text(_message('John Doe')), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    router!.pop();
    await tester.pumpAndSettle();
    planPayment = Completer<int?>();
    await confirmPlanWallet(tester);
    expect(planBloc!.state.walletPaymentSucceeded, isFalse);
    planPayment.complete(102);
    await tester.pumpAndSettle();
    expect(find.text(_message('John Doe')), findsOneWidget);
    verify(
      () => repository.payFromWallet(
        amount: 77,
        selectedItems: const [_primary],
        promoCodes: const [],
        bonuses: const [],
        forceNow: true,
        selectedBeginDate: null,
      ),
    ).called(2);
    verifyZeroInteractions(network);
    await finish(tester);
  });

  testWidgets(
    'changing a radio during a wallet request cannot lose wallet funding',
    (tester) async {
      await openPlan(tester);
      await confirmPlanWallet(tester);
      planBloc!.add(const HomePlansPaymentMethodSelected('saved-token'));
      await tester.pump();
      planPayment.complete(101);
      await tester.pumpAndSettle();
      expect(planBloc!.state.walletPaymentSucceeded, isTrue);
      expect(find.text(_message('John Doe')), findsOneWidget);
      verifyOnePlanPayment();
      await finish(tester);
    },
  );

  testWidgets(
    'wallet failure keeps existing failure receipt without success toast',
    (tester) async {
      await openPlan(tester);
      await confirmPlanWallet(tester);
      planPayment.completeError(Exception('wallet payment failed'));
      await tester.pumpAndSettle();
      expect(find.byType(HomePlanPurchaseReceiptScreen), findsOneWidget);
      expect(planBloc!.state.walletPaymentSucceeded, isFalse);
      expect(find.textContaining(_suffix), findsNothing);
      verifyOnePlanPayment();
      await finish(tester);
    },
  );

  testWidgets('insufficient wallet funds block payment and receipt', (
    tester,
  ) async {
    await openPlan(tester);
    planBloc!.add(const HomePlansPayFromWalletPressed());
    await tester.pumpAndSettle();
    planBloc!.add(const HomePlansPayFromWalletConfirmed(walletBalance: 1));
    await tester.pumpAndSettle();
    expect(find.text('Insufficient wallet balance'), findsOneWidget);
    expect(find.byType(HomePlanPurchaseReceiptScreen), findsNothing);
    expect(find.textContaining(_suffix), findsNothing);
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
    await finish(tester);
  });

  testWidgets('cancelled wallet confirmation retains Row 3 and never pays', (
    tester,
  ) async {
    await openPlan(tester);
    planBloc!.add(const HomePlansPayFromWalletPressed());
    await tester.pumpAndSettle();
    await tester.tap(find.text('pay now'));
    await tester.pumpAndSettle();
    rootNavigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    tester.widget<DefaultAppBar>(find.byType(DefaultAppBar)).onBack!();
    await tester.pumpAndSettle();
    expect(find.text('Your Liberty 70 was not added'), findsOneWidget);
    expect(find.textContaining(_suffix), findsNothing);
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
    await finish(tester);
  });

  for (final mode in ['saved card', '3DS', 'postpaid account']) {
    testWidgets(
      '$mode success cannot become wallet success from radio selection',
      (tester) async {
        await openPlan(
          tester,
          subscriberType: mode == 'postpaid account'
              ? HomePlansSubscriberType.postpaid
              : HomePlansSubscriberType.prepaid,
        );
        if (mode == '3DS') {
          planBloc!.add(const HomePlansPayFromWalletPressed());
          await tester.pump();
          planBloc!.add(const HomePlans3DSPayWithCardSucceeded(orderId: '101'));
        } else {
          if (mode == 'saved card') {
            planBloc!.add(const HomePlansPaymentMethodSelected('saved-token'));
            await tester.pump();
            planBloc!.add(const HomePlansPaySavedCardConfirmed());
          } else {
            planBloc!.add(const HomePlansChargeToAccountRequested());
          }
          await tester.pump();
          planBloc!.add(const HomePlansPayFromWalletPressed());
          await tester.pump();
          planPayment.complete(101);
        }
        await tester.pumpAndSettle();
        expect(find.byType(HomePlanPurchaseReceiptScreen), findsOneWidget);
        expect(planBloc!.state.walletPaymentSucceeded, isFalse);
        expect(planSuccess, isNull);
        expect(find.textContaining(_suffix), findsNothing);
        await finish(tester);
      },
    );
  }

  Future<void> openTransfer(WidgetTester tester) async {
    size(tester);
    transfer = Completer<Response<dynamic>>();
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      observers: [observer],
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const PayFromWalletSheet(
                    amount: 5,
                    phoneNumber: '2428017777',
                  ),
                ),
                child: const Text('existing transfer confirmation'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const Scaffold(body: Text('existing home')),
        ),
        GoRoute(
          path: AppRoutes.userProfileReceiptScreen,
          builder: (_, state) {
            transferArgs = state.extra! as UserProfileReceiptRouteArgs;
            return UserProfileReceiptScreen(args: transferArgs!);
          },
        ),
      ],
    );
    await tester.pumpWidget(app(MaterialApp.router(routerConfig: router)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('existing transfer confirmation'));
    await tester.pumpAndSettle();
    expect(find.textContaining(_suffix), findsNothing);
  }

  for (final name in [null, 'John Doe', '', '   ', 'User']) {
    testWidgets(
      'send wallet top-up receipt resolves name=$name and ignores duplicate success',
      (tester) async {
        when(() => account.state).thenReturn(
          AccountInfoState(
            accountInfo: name == null
                ? null
                : AccountInfoModel(
                    fName: name,
                    phoneNumber: '2428011616',
                    email: 'john@example.test',
                  ),
          ),
        );
        await openTransfer(tester);
        await tester.tap(find.text('confirm payment'));
        await tester.pump();
        expect(find.byType(UserProfileReceiptScreen), findsNothing);
        expect(find.textContaining(_suffix), findsNothing);
        final before = observer.pushes;
        transfer.complete(
          Response<dynamic>(
            requestOptions: RequestOptions(path: Api.orderTransferUrl),
            statusCode: 200,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(UserProfileReceiptScreen), findsOneWidget);
        expect(
          find.text(_message(name == 'John Doe' ? 'John Doe' : 'user')),
          findsOneWidget,
        );
        expect(find.text('Wallet Transfer Successful!'), findsOneWidget);
        expect(
          find.text('It may take a few moments before the order is processed.'),
          findsOneWidget,
        );
        expect(transferArgs!.recipientPhone, '2428017777');
        expect(transferArgs!.amount, 5);
        expect(observer.pushes, before + 1);
        verify(
          () => network.request<dynamic>(
            Api.orderTransferUrl,
            method: HttpMethod.post,
            data: {'ToNumber': '2428017777', 'Amount': 5.0},
          ),
        ).called(1);
        verifyNoMoreInteractions(network);
        verifyNever(
          () => account.fetchAccountInfo(
            forceRefresh: any(named: 'forceRefresh'),
          ),
        );
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
        await tester.pumpWidget(app(MaterialApp.router(routerConfig: router)));
        await tester.pumpAndSettle();
        expect(find.textContaining(_suffix), findsNothing);
        expect(observer.pushes, before + 1);
        verifyNoMoreInteractions(network);
        await tester.tap(find.text('back to home page'));
        await tester.pumpAndSettle();
        expect(find.text('existing home'), findsOneWidget);
        await finish(tester);
      },
    );
  }

  for (final cancelled in [false, true]) {
    testWidgets(
      'send wallet top-up ${cancelled ? 'cancelled' : 'failed'} has no success receipt',
      (tester) async {
        await openTransfer(tester);
        if (cancelled) {
          rootNavigatorKey.currentState!.pop();
          await tester.pumpAndSettle();
          verifyZeroInteractions(network);
        } else {
          await tester.tap(find.text('confirm payment'));
          await tester.pump();
          transfer.completeError(const SendTopupException('transfer rejected'));
          await tester.pumpAndSettle();
          expect(find.text('transfer rejected'), findsOneWidget);
          verify(
            () => network.request<dynamic>(
              Api.orderTransferUrl,
              method: HttpMethod.post,
              data: {'ToNumber': '2428017777', 'Amount': 5.0},
            ),
          ).called(1);
          verifyNoMoreInteractions(network);
        }
        expect(find.byType(UserProfileReceiptScreen), findsNothing);
        expect(find.textContaining(_suffix), findsNothing);
        await finish(tester);
      },
    );
  }

  for (final variant in [
    UserProfileReceiptVariant.standard,
    UserProfileReceiptVariant.walletTransfer,
  ]) {
    for (final method in ['wallet', 'credit card']) {
      testWidgets(
        'unmarked receipt variant=$variant method=$method never thanks wallet',
        (tester) async {
          size(tester);
          await tester.pumpWidget(
            app(
              MaterialApp(
                navigatorKey: rootNavigatorKey,
                home: UserProfileReceiptScreen(
                  args: UserProfileReceiptRouteArgs(
                    amount: 5,
                    variant: variant,
                    paymentMethod: method,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.textContaining(_suffix), findsNothing);
          expect(find.text('Payment Success!'), findsOneWidget);
          expect(
            find.text(UserProfileReceiptRouteArgs.topUpPendingMessage),
            findsOneWidget,
          );
          verifyZeroInteractions(network);
          await finish(tester);
        },
      );
    }
  }

  for (final args in [
    UserProfileReceiptRouteArgs(
      amount: 5,
      paymentMethod: 'wallet',
      walletPaymentSuccess: WalletPaymentSuccess(accountName: 'John Doe'),
    ),
    UserProfileReceiptRouteArgs(
      amount: 5,
      paymentMethod: 'credit card',
      variant: UserProfileReceiptVariant.walletTransfer,
      walletPaymentSuccess: WalletPaymentSuccess(accountName: 'John Doe'),
    ),
  ]) {
    testWidgets(
      'typed wallet context cannot opt unrelated receipt into wallet toast: ${args.variant}/${args.paymentMethod}',
      (tester) async {
        size(tester);
        await tester.pumpWidget(
          app(
            MaterialApp(
              navigatorKey: rootNavigatorKey,
              home: UserProfileReceiptScreen(args: args),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining(_suffix), findsNothing);
        await finish(tester);
      },
    );
  }

  test(
    'wallet username trims personal names and uses Home device fallback',
    () {
      expect(
        resolveWalletPaymentUserName(
          accountName: '  John Doe  ',
          deviceName: 'Jane',
        ),
        'John Doe',
      );
      expect(
        resolveWalletPaymentUserName(
          accountName: ' ',
          deviceName: ' Jane Smith ',
        ),
        'Jane Smith',
      );
      expect(
        resolveWalletPaymentUserName(accountName: 'User', deviceName: 'Jane'),
        'Jane',
      );
      final device = _Device();
      when(() => device.fName).thenReturn('Jane');
      when(() => device.lName).thenReturn('Smith');
      when(() => devices.state).thenReturn(
        DeviceLimitsState(
          status: DeviceLimitsStatus.loaded,
          allDeviceLimits: [device],
        ),
      );
      expect(
        WalletPaymentSuccess.fromCurrentUser(
          account: const AccountInfoState(),
        ).userName,
        'Jane Smith',
      );
      verifyNever(
        () =>
            account.fetchAccountInfo(forceRefresh: any(named: 'forceRefresh')),
      );
    },
  );

  for (final name in [
    null,
    '',
    ' ',
    'User',
    'USER',
    'null',
    '[user name]',
    'unknown',
    'unknown user',
    'null null',
  ]) {
    test('unusable wallet name $name has exact lowercase user fallback', () {
      expect(WalletPaymentSuccess(accountName: name).message, _message('user'));
    });
  }

  testWidgets(
    'same completed transaction cannot toast on remount; a new one can',
    (tester) async {
      final success = WalletPaymentSuccess(accountName: 'John Doe');
      Widget receipt(WalletPaymentSuccess value, Key key) => MaterialApp(
        navigatorKey: rootNavigatorKey,
        home: WalletPaymentSuccessReceipt(
          key: key,
          success: value,
          child: const Scaffold(body: Text('receipt')),
        ),
      );
      await tester.pumpWidget(receipt(success, const ValueKey(1)));
      await tester.pump();
      expect(find.text(_message('John Doe')), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.pumpWidget(receipt(success, const ValueKey(2)));
      await tester.pump();
      expect(find.textContaining(_suffix), findsNothing);
      await tester.pumpWidget(
        receipt(
          WalletPaymentSuccess(accountName: 'John Doe'),
          const ValueKey(2),
        ),
      );
      await tester.pump();
      expect(find.text(_message('John Doe')), findsOneWidget);
      await finish(tester);
    },
  );
}
