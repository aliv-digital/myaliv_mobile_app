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
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_event.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/bloc/home_plans_payment_method_state.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/repository/home_plans_payment_method_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/view/home_plans_payment_method_view.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/view/services/payment_sheet_launcher.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Repository extends Mock implements HomePlansPaymentMethodRepository {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Balance extends MockCubit<BalanceState> implements BalanceCubit {}

class _Plans extends MockCubit<PlansState> implements PlansCubit {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Cards extends MockCubit<SavedCardsState> implements SavedCardsCubit {}

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Repository repository;
  late _Devices devices;
  late _Balance balance;
  late _Plans plans;
  late _Account account;
  late _Cards cards;
  late HomePlansPaymentMethodBloc bloc;
  late BasePlanModel purchasedPlan;
  late Completer<int?> payment;
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
    repository = _Repository();
    devices = _Devices();
    balance = _Balance();
    plans = _Plans();
    account = _Account();
    cards = _Cards();
    receipt = null;
    receiptVisits = 0;
    purchasedPlan = BasePlanModel.fromJson({
      'PlanID': 123,
      'PlanName': 'liberty100',
    });
    when(() => devices.state).thenReturn(DeviceLimitsState.initial());
    when(() => devices.loadDeviceLimits()).thenAnswer((_) async {});
    when(() => balance.state).thenReturn(BalanceState.initial());
    when(() => account.state).thenReturn(const AccountInfoState());
    when(() => cards.state).thenReturn(const SavedCardsState());
    when(() => cards.fetchSavedCards()).thenAnswer((_) async {});
    when(
      () => plans.state,
    ).thenReturn(PlansState(monthlyApiPlans: [purchasedPlan]));
    when(
      () => repository.fetchPaymentMethods(
        subscriberType: any(named: 'subscriberType'),
      ),
    ).thenAnswer((_) async => []);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<SavedCardsCubit>(cards);
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

  Future<void> pumpScreen(
    WidgetTester tester, {
    DateTime? startDate,
    bool forceNow = false,
    HomePlansSubscriberType subscriberType = HomePlansSubscriberType.prepaid,
    List<HomePlansPaymentSelectedItem> items = _items,
  }) async {
    bloc = HomePlansPaymentMethodBloc(repository: repository);
    payment = Completer<int?>();
    when(
      () => repository.payFromWallet(
        amount: 110,
        selectedItems: items,
        promoCodes: const [],
        bonuses: const [],
        forceNow: forceNow,
        selectedBeginDate: startDate,
      ),
    ).thenAnswer((_) => payment.future);
    when(
      () => repository.payWithSavedCard(
        amount: 110,
        cardToken: 'saved-token',
        selectedItems: items,
        promoCodes: const [],
        bonuses: const [],
        forceNow: forceNow,
        selectedBeginDate: startDate,
      ),
    ).thenAnswer((_) => payment.future);
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
        GoRoute(
          path: AppRoutes.homePlanPurchaseReceiptScreen,
          builder: (_, state) {
            receipt = state.extra! as Map<String, dynamic>;
            receiptVisits++;
            return Scaffold(
              body: Text(
                receipt!['isPaymentFailed'] == true
                    ? 'existing failure receipt'
                    : 'existing success receipt',
              ),
            );
          },
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
        selectedItems: items,
        forceNow: forceNow,
        selectedBeginDate: startDate,
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder scheduledToast() =>
      find.textContaining('your plan is scheduled to start on');

  Future<void> disposeScreen(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  for (final method in ['wallet', 'saved card', '3DS']) {
    testWidgets('future prepaid success via $method uses accepted start date', (
      tester,
    ) async {
      final start = DateTime(2099, 11, 23, 14, 45);
      await pumpScreen(tester, startDate: start);
      expect(scheduledToast(), findsNothing);
      if (method == '3DS') {
        bloc.add(const HomePlans3DSPayWithCardSucceeded(orderId: '456'));
      } else {
        if (method == 'wallet') {
          bloc.add(const HomePlansPayFromWalletConfirmed(walletBalance: 200));
        } else {
          bloc.add(const HomePlansPaymentMethodSelected('saved-token'));
          await tester.pump();
          bloc.add(const HomePlansPaySavedCardConfirmed());
        }
        await tester.pump();
        expect(bloc.state.status, HomePlansPaymentMethodStatus.submitting);
        expect(scheduledToast(), findsNothing);
        expect(receipt, isNull);
        payment.complete(456);
      }
      await tester.pumpAndSettle();
      expect(
        find.text('your plan is scheduled to start on 23-11-99'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.text('existing success receipt'), findsOneWidget);
      expect(receipt!['amount'], 110);
      expect(receipt!['phoneNumber'], '242-801-1616');
      expect(receipt!['orderId'], '456');
      expect(receipt!['selectedItems'], _items);
      expect(receipt!['rightType'], 'prepaid');
      expect(receiptVisits, 1);
      expect(bloc.state.navTarget, HomePlansPaymentMethodNavTarget.none);
      expect(bloc.state.selectedBeginDate, start);
      verify(
        () => plans.injectOptimisticPrimaryPlanChange(
          plan: purchasedPlan,
          addOns: const [],
          purchasedAt: start,
        ),
      ).called(1);
      if (method == 'wallet') {
        verify(
          () => repository.payFromWallet(
            amount: 110,
            selectedItems: _items,
            promoCodes: const [],
            bonuses: const [],
            forceNow: false,
            selectedBeginDate: start,
          ),
        ).called(1);
      }
      // Consuming the navigation event must not show the toast a second time.
      await tester.pump(const Duration(seconds: 4));
      expect(scheduledToast(), findsNothing);
      expect(receiptVisits, 1);
      await disposeScreen(tester);
    });
  }

  for (final scenario in [
    'immediate',
    'postpaid',
    'missing date',
    'past date',
    'no plan',
  ]) {
    testWidgets('$scenario success preserves receipt without PLAN-013', (
      tester,
    ) async {
      final start = scenario == 'missing date'
          ? null
          : scenario == 'past date'
          ? DateTime(2000, 1, 1)
          : DateTime(2099, 11, 23);
      await pumpScreen(
        tester,
        startDate: start,
        forceNow: scenario == 'immediate',
        subscriberType: scenario == 'postpaid'
            ? HomePlansSubscriberType.postpaid
            : HomePlansSubscriberType.prepaid,
        items: scenario == 'no plan' ? const [] : _items,
      );
      bloc.add(const HomePlans3DSPayWithCardSucceeded(orderId: '456'));
      await tester.pumpAndSettle();
      expect(scheduledToast(), findsNothing);
      expect(find.text('existing success receipt'), findsOneWidget);
      expect(receipt!['amount'], 110);
      expect(receipt!['orderId'], '456');
      expect(
        receipt!['rightType'],
        scenario == 'postpaid' ? 'postpaid' : 'prepaid',
      );
      expect(receiptVisits, 1);
      await disposeScreen(tester);
    });
  }

  testWidgets(
    'future payment rejected preserves failure receipt without success toast',
    (tester) async {
      await pumpScreen(tester, startDate: DateTime(2099, 11, 23));
      final failures = <HomePlansPaymentMethodState>[];
      final subscription = bloc.stream
          .where(
            (state) =>
                state.navTarget ==
                HomePlansPaymentMethodNavTarget.paymentFailed,
          )
          .listen(failures.add);
      addTearDown(subscription.cancel);
      bloc.add(const HomePlansPayFromWalletConfirmed(walletBalance: 200));
      await tester.pump();
      payment.completeError(Exception('Purchase rejected'));
      await tester.pumpAndSettle();
      expect(scheduledToast(), findsNothing);
      expect(find.text('existing failure receipt'), findsOneWidget);
      expect(receipt, {'isPaymentFailed': true, 'phoneNumber': '242-801-1616'});
      expect(failures.single.errorMessage, 'Purchase rejected');
      verifyNever(
        () => plans.injectOptimisticPrimaryPlanChange(
          plan: purchasedPlan,
          addOns: const [],
          purchasedAt: DateTime(2099, 11, 23),
        ),
      );
      await disposeScreen(tester);
    },
  );

  testWidgets(
    'cancelled wallet confirmation does not submit or show PLAN-013',
    (tester) async {
      await pumpScreen(tester, startDate: DateTime(2099, 11, 23));
      final context = tester.element(find.byType(HomePlansPaymentMethodView));
      final sheet = PaymentSheetLauncher.openWallet(
        context,
        walletBalance: 200,
        walletBalanceText: r'$ 200.00',
        amountText: r'$ 110.00',
      );
      await tester.pumpAndSettle();
      expect(find.text('confirm payment'), findsOneWidget);
      Navigator.of(context).pop();
      await sheet;
      await tester.pumpAndSettle();
      expect(bloc.state.status, HomePlansPaymentMethodStatus.ready);
      expect(scheduledToast(), findsNothing);
      expect(receipt, isNull);
      verifyNever(
        () => repository.payFromWallet(
          amount: 110,
          selectedItems: _items,
          promoCodes: const [],
          bonuses: const [],
          forceNow: false,
          selectedBeginDate: DateTime(2099, 11, 23),
        ),
      );
      await disposeScreen(tester);
    },
  );
}
