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
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
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
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/view/services/payment_receipt_builder.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/view/services/payment_sheet_launcher.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';

class _Repository extends Mock implements HomePlansPaymentMethodRepository {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Balance extends MockCubit<BalanceState> implements BalanceCubit {}

class _Plans extends MockCubit<PlansState> implements PlansCubit {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Cards extends MockCubit<SavedCardsState> implements SavedCardsCubit {}

class _Analytics extends Mock implements AnalyticsService {}

const _replacement = PlanPurchaseContext.prepaidImmediatePrimaryReplacement;
const _original =
    'It will take a few moments for the plan to appear on the account.';

void main() {
  late _Repository repository;
  late _Devices devices;
  late _Balance balance;
  late _Plans plans;
  late AppUiConfigCubit config;
  late _Account account;
  late _Cards cards;
  late _Analytics analytics;
  late HomePlansPaymentMethodBloc bloc;
  late Completer<int?> payment;
  late List<HomePlansPaymentSelectedItem> items;
  late GoRouter router;
  Map<String, dynamic>? receipt;
  var receiptVisits = 0;

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
    config = AppUiConfigCubit();
    repository = _Repository();
    devices = _Devices();
    balance = _Balance();
    plans = _Plans();
    account = _Account();
    cards = _Cards();
    analytics = _Analytics();
    receipt = null;
    receiptVisits = 0;
    when(() => devices.state).thenReturn(DeviceLimitsState.initial());
    when(() => devices.loadDeviceLimits()).thenAnswer((_) async {});
    when(() => balance.state).thenReturn(BalanceState.initial());
    when(() => plans.state).thenReturn(const PlansState());
    when(() => plans.isClosed).thenReturn(false);
    when(() => plans.refreshBundlesOnly()).thenAnswer((_) async {});
    when(() => account.state).thenReturn(const AccountInfoState());
    when(() => cards.state).thenReturn(const SavedCardsState());
    when(() => cards.fetchSavedCards()).thenAnswer((_) async {});
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
    ).thenAnswer((_) => payment.future);
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
    ).thenAnswer((_) => payment.future);
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
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<SavedCardsCubit>(cards);
    instance.registerSingleton<AnalyticsService>(analytics);
  });

  tearDown(() async {
    router.dispose();
    await bloc.close();
    await devices.close();
    await balance.close();
    await plans.close();
    await config.close();
    await account.close();
    await cards.close();
    await instance.reset();
  });

  Future<void> openPayment(
    WidgetTester tester, {
    String title = 'Liberty 70',
    PlanPurchaseContext purchaseContext = _replacement,
    bool forceNow = true,
    HomePlansSubscriberType subscriberType = HomePlansSubscriberType.prepaid,
    HomePlansPaymentPlanType planType = HomePlansPaymentPlanType.primary,
  }) async {
    config.setUserType(
      subscriberType == HomePlansSubscriberType.postpaid
          ? UserType.postpaid
          : UserType.prepaid,
    );
    items = [
      HomePlansPaymentSelectedItem(
        id: '123',
        label: 'primary plan',
        title: title,
        subtitle: '',
        price: 70,
        planType: planType,
      ),
    ];
    payment = Completer<int?>();
    bloc = HomePlansPaymentMethodBloc(repository: repository);
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
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
          path: AppRoutes.home,
          builder: (_, _) => const Scaffold(body: Text('existing home')),
        ),
        GoRoute(
          path: AppRoutes.homePlansPaymentMethodScreen,
          builder: (_, _) => const HomePlansPaymentMethodView(),
        ),
        GoRoute(
          path: AppRoutes.homePlanPurchaseReceiptScreen,
          builder: (_, state) {
            receipt = state.extra! as Map<String, dynamic>;
            receiptVisits++;
            if (receipt!['isPaymentFailed'] == true) {
              return const Scaffold(body: Text('existing failure receipt'));
            }
            return HomePlanPurchaseReceiptScreen(
              phoneNumber: receipt!['phoneNumber'] as String,
              amount: receipt!['amount'] as double,
              dateText: receipt!['dateText'] as String,
              timeText: receipt!['timeText'] as String,
              paymentMethod: receipt!['paymentMethod'] as String,
              statusMessage: receipt!['statusMessage'] as String,
              leftType: receipt!['leftType'] as String,
              rightType: receipt!['rightType'] as String,
              orderId: receipt!['orderId'] as String?,
              details:
                  receipt!['details']
                      as List<HomePlanPurchaseReceiptDetailItem>,
            );
          },
        ),
      ],
    );
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AppUiConfigCubit>.value(value: config),
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
        phoneNumber: '2428011616',
        amount: 77,
        selectedItems: items,
        forceNow: forceNow,
        purchaseContext: purchaseContext,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('existing confirmation'));
    await tester.pumpAndSettle();
    expect(find.textContaining('was added successfully.'), findsNothing);
    expect(find.textContaining('was not added'), findsNothing);
  }

  void expectNoWalletPurchase() => verifyNever(
    () => repository.payFromWallet(
      amount: any(named: 'amount'),
      selectedItems: any(named: 'selectedItems'),
      promoCodes: any(named: 'promoCodes'),
      bonuses: any(named: 'bonuses'),
      forceNow: any(named: 'forceNow'),
      selectedBeginDate: any(named: 'selectedBeginDate'),
    ),
  );

  Future<void> disposeScreen(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  for (final method in ['wallet', 'saved card', '3DS']) {
    testWidgets(
      '$method replacement success updates actual receipt detail only',
      (tester) async {
        await openPayment(tester);
        if (method == '3DS') {
          bloc.add(const HomePlans3DSPayWithCardSucceeded(orderId: '456'));
        } else {
          if (method == 'wallet') {
            bloc.add(const HomePlansPayFromWalletConfirmed(walletBalance: 100));
          } else {
            bloc.add(const HomePlansPaymentMethodSelected('saved-token'));
            await tester.pump();
            bloc.add(const HomePlansPaySavedCardConfirmed());
          }
          await tester.pump();
          expect(bloc.state.status, HomePlansPaymentMethodStatus.submitting);
          expect(receipt, isNull);
          expect(
            find.text('Your Liberty 70 was added successfully.'),
            findsNothing,
          );
          payment.complete(456);
        }
        await tester.pump(const Duration(milliseconds: 500));
        expect(bloc.state.status, HomePlansPaymentMethodStatus.success);
        await tester.pumpAndSettle();
        expect(find.byType(HomePlanPurchaseReceiptScreen), findsOneWidget);
        expect(
          find.text('Your Liberty 70 was added successfully.'),
          findsOneWidget,
        );
        expect(find.text('Payment Success!'), findsOneWidget);
        expect(find.text(_original), findsNothing);
        expect(find.textContaining('was not added'), findsNothing);
        expect(receipt!['amount'], 77);
        expect(receipt!['selectedItems'], items);
        expect(receiptVisits, 1);
        // Returning through the payment route after success is not cancellation.
        router.pop();
        await tester.pumpAndSettle();
        router.pop();
        await tester.pumpAndSettle();
        expect(find.text('existing confirmation'), findsOneWidget);
        expect(find.textContaining('was not added'), findsNothing);
        await disposeScreen(tester);
        verify(() => plans.refreshBundlesOnly()).called(1);
      },
    );
  }

  testWidgets('a different purchased title is used without hardcoding', (
    tester,
  ) async {
    await openPayment(tester, title: 'Freedom 30');
    bloc.add(const HomePlans3DSPayWithCardSucceeded(orderId: '789'));
    await tester.pumpAndSettle();
    expect(
      find.text('Your Freedom 30 was added successfully.'),
      findsOneWidget,
    );
    expect(find.text('Your Liberty 70 was added successfully.'), findsNothing);
    await disposeScreen(tester);
  });

  for (final back in ['screen', 'system']) {
    testWidgets(
      '$back Back cancels once and retains the existing destination',
      (tester) async {
        await openPayment(tester, title: 'Freedom 30');
        if (back == 'screen') {
          tester.widget<DefaultAppBar>(find.byType(DefaultAppBar)).onBack!();
        } else {
          await tester.binding.handlePopRoute();
        }
        await tester.pumpAndSettle();
        expect(find.text('existing confirmation'), findsOneWidget);
        expect(find.text('Your Freedom 30 was not added'), findsOneWidget);
        expect(receipt, isNull);
        expect(bloc.state.status, HomePlansPaymentMethodStatus.ready);
        expectNoWalletPurchase();
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
        verifyZeroInteractions(analytics);
        verifyZeroInteractions(plans);
        verify(
          () => repository.fetchPaymentMethods(
            subscriberType: HomePlansSubscriberType.prepaid,
          ),
        ).called(1);
        verifyNoMoreInteractions(repository);
        // A later Back does not restart/duplicate the existing toast.
        await tester.pump(const Duration(seconds: 2));
        await tester.binding.handlePopRoute();
        await tester.pump(const Duration(seconds: 2));
        expect(find.textContaining('was not added'), findsNothing);
        await disposeScreen(tester);
      },
    );
  }

  testWidgets('pending wallet submission is not cancellation on Back', (
    tester,
  ) async {
    await openPayment(tester);
    bloc.add(const HomePlansPayFromWalletConfirmed(walletBalance: 100));
    await tester.pump();
    router.pop();
    await tester.pumpAndSettle();
    expect(find.textContaining('was not added'), findsNothing);
    expect(find.text('existing confirmation'), findsOneWidget);
    payment.complete(456);
    await tester.pumpAndSettle();
    expect(receipt, isNull);
    await disposeScreen(tester);
  });

  testWidgets('confirmed 3DS waiting for analytics is not cancellation', (
    tester,
  ) async {
    final analyticsDone = Completer<void>();
    when(
      () => analytics.logPlanPurchase(
        planId: any(named: 'planId'),
        planName: any(named: 'planName'),
        amount: any(named: 'amount'),
        paymentMethod: any(named: 'paymentMethod'),
      ),
    ).thenAnswer((_) => analyticsDone.future);
    await openPayment(tester);
    bloc.add(const HomePlans3DSPayWithCardSucceeded(orderId: '456'));
    await tester.pump();
    expect(bloc.state.hasConfirmed3DSPayment, isTrue);
    expect(receipt, isNull);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.textContaining('was not added'), findsNothing);
    analyticsDone.complete();
    await tester.pumpAndSettle();
    await disposeScreen(tester);
  });

  testWidgets('failed payment retains failure receipt and no cancellation', (
    tester,
  ) async {
    await openPayment(tester);
    bloc.add(const HomePlansPayFromWalletConfirmed(walletBalance: 100));
    await tester.pump();
    payment.completeError(Exception('Purchase rejected'));
    await tester.pumpAndSettle();
    expect(find.text('existing failure receipt'), findsOneWidget);
    expect(find.textContaining('was added successfully.'), findsNothing);
    expect(receipt!['isPaymentFailed'], isTrue);
    router.pop();
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();
    expect(find.textContaining('was not added'), findsNothing);
    await disposeScreen(tester);
  });

  testWidgets('insufficient wallet guard still blocks repository and receipt', (
    tester,
  ) async {
    await openPayment(tester);
    bloc.add(const HomePlansPayFromWalletConfirmed(walletBalance: 76));
    await tester.pumpAndSettle();
    expect(find.text('Insufficient wallet balance'), findsOneWidget);
    expect(receipt, isNull);
    expect(bloc.state.status, HomePlansPaymentMethodStatus.ready);
    expectNoWalletPurchase();
    await disposeScreen(tester);
  });

  testWidgets('wallet confirmation dismissal is not payment-screen Back', (
    tester,
  ) async {
    await openPayment(tester);
    final context = tester.element(find.byType(HomePlansPaymentMethodView));
    final sheet = PaymentSheetLauncher.openWallet(
      context,
      walletBalance: 100,
      walletBalanceText: r'$100.00',
      amountText: r'$77.00',
    );
    await tester.pumpAndSettle();
    Navigator.of(context).pop();
    await sheet;
    await tester.pumpAndSettle();
    expect(find.textContaining('was not added'), findsNothing);
    expectNoWalletPurchase();
    await disposeScreen(tester);
  });

  for (final category in [
    'regular primary',
    'scheduled',
    'add-on',
    'roaming',
    'MiFi',
    'postpaid',
  ]) {
    for (final outcome in ['success', 'Back']) {
      testWidgets('$category $outcome retains original presentation', (
        tester,
      ) async {
        await openPayment(
          tester,
          purchaseContext: category == 'MiFi' || category == 'regular primary'
              ? PlanPurchaseContext.regular
              : _replacement,
          forceNow: category != 'scheduled',
          subscriberType: category == 'postpaid'
              ? HomePlansSubscriberType.postpaid
              : HomePlansSubscriberType.prepaid,
          planType: category == 'add-on'
              ? HomePlansPaymentPlanType.secondary
              : category == 'roaming'
              ? HomePlansPaymentPlanType.standalone
              : HomePlansPaymentPlanType.primary,
        );
        if (outcome == 'success') {
          bloc.add(const HomePlans3DSPayWithCardSucceeded(orderId: '456'));
          await tester.pumpAndSettle();
          expect(find.text(_original), findsOneWidget);
          expect(find.text('Payment Success!'), findsOneWidget);
        } else {
          router.pop();
          await tester.pumpAndSettle();
          expect(find.text('existing confirmation'), findsOneWidget);
          expectNoWalletPurchase();
        }
        expect(find.textContaining('was added successfully.'), findsNothing);
        expect(find.textContaining('was not added'), findsNothing);
        await disposeScreen(tester);
      });
    }
  }

  testWidgets('Home navigation is unchanged and is not Back cancellation', (
    tester,
  ) async {
    await openPayment(tester);
    tester.widget<DefaultAppBar>(find.byType(DefaultAppBar)).onHomeTap!();
    await tester.pumpAndSettle();
    expect(find.text('existing home'), findsOneWidget);
    expect(find.textContaining('was not added'), findsNothing);
    expectNoWalletPurchase();
    await disposeScreen(tester);
  });

  testWidgets('repeated pop notification shows only one cancellation toast', (
    tester,
  ) async {
    await openPayment(tester);
    final pop = tester.widget<PopScope<Object?>>(
      find.byType(PopScope<Object?>),
    );
    router.pop();
    pop.onPopInvokedWithResult!(true, null);
    await tester.pumpAndSettle();
    expect(find.text('Your Liberty 70 was not added'), findsOneWidget);
    expectNoWalletPurchase();
    await disposeScreen(tester);
  });

  testWidgets('receipt builder preserves pre-success copy', (tester) async {
    await openPayment(tester);
    final context = tester.element(find.byType(HomePlansPaymentMethodView));
    expect(
      PaymentReceiptBuilder.build(context, bloc.state)['statusMessage'],
      _original,
    );
    await disposeScreen(tester);
  });
}
