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
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/plan_purchase_context.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/home_plan_purchase_sheet_launcher.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/bloc/home_plan_confirmation_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/bloc/home_plan_confirmation_event.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/view/home_plan_confirmation_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/widgets/terms_notice.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlansPaymentMethod/model/home_plans_payment_method_models.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/model/mifi_alt_contact_route_args.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/model/plan_purchase_plan_add_ons_route_args.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/view/plan_purchase_plan_add_ons_screen.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Plans extends MockCubit<PlansState> implements PlansCubit {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Network extends Mock implements NetworkService {}

void main() {
  late _Plans plans;
  late _Account account;
  late _Devices devices;
  late _Network network;
  PlanPurchasePlanAddOnsRouteArgs? addOns;
  HomePlanConfirmationRouteArgs? confirmation;
  HomePlansPaymentMethodRouteArgs? payment;

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
    plans = _Plans();
    account = _Account();
    devices = _Devices();
    network = _Network();
    addOns = null;
    confirmation = null;
    payment = null;
    when(
      () => devices.state,
    ).thenReturn(const DeviceLimitsState(status: DeviceLimitsStatus.loaded));
    when(() => devices.loadDeviceLimits()).thenAnswer((_) async {});
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<NetworkService>(network);
  });

  tearDown(() async {
    await plans.close();
    await account.close();
    await devices.close();
    await instance.reset();
  });

  Future<void> openSheet(
    WidgetTester tester, {
    bool active = true,
    bool prepaid = true,
    bool futureOnly = false,
    bool expired = false,
    String activeGroup = 'freedom (30 day)',
    HomePlanTab tab = HomePlanTab.monthly,
    String newType = 'P',
  }) async {
    final now = DateTime.now();
    final current = BasePlanModel.fromApiMap({
      'PlanID': 'current',
      'PlanName': 'existing plan',
      'PlanType': 'P',
      'PlanGroup': activeGroup,
      'StartDate': now
          .add(Duration(days: futureOnly ? 2 : -2))
          .toUtc()
          .toIso8601String(),
      'EndDate': now
          .add(Duration(days: expired ? -1 : 7))
          .toUtc()
          .toIso8601String(),
    });
    final selected = BasePlanModel.fromApiMap({
      'PlanID': '123',
      'PlanName': 'Liberty 70',
      'PlanType': newType,
      'PlanAmount': 70,
      'VATAmount': 7,
    });
    when(() => plans.state).thenReturn(
      PlansState(
        status: PlansStatus.success,
        addOnsApiPrimaryPlans: active ? [current] : [],
        monthlyApiPlans: [selected],
      ),
    );
    when(() => account.state).thenReturn(
      AccountInfoState(
        accountInfo: AccountInfoModel(
          paymentOption: prepaid ? 'PrePay' : 'PostPay',
          primaryPhoneNumber: '2428011616',
        ),
      ),
    );
    tester.view.physicalSize = const Size(390, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => unawaited(
                  showHomePlanPurchaseBottomSheet(
                    context: context,
                    selectedTab: tab,
                    selectedApiPlan: selected,
                    plan: const HomePlanModel(
                      id: '123',
                      title: 'Liberty 70',
                      subtitle: '30 days',
                      price: 77,
                      description: '',
                      benefits: [],
                    ),
                  ),
                ),
                child: const Text('buy plan'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.homePurchasePlanAddOns,
          builder: (_, state) {
            addOns = state.extra! as PlanPurchasePlanAddOnsRouteArgs;
            return PlanPurchasePlanAddOnsScreen(routeArgs: addOns);
          },
        ),
        GoRoute(
          path: AppRoutes.homePlanConfirmationScreen,
          builder: (_, state) {
            confirmation = state.extra! as HomePlanConfirmationRouteArgs;
            return HomePlanConfirmationScreen(args: confirmation!);
          },
        ),
        GoRoute(
          path: AppRoutes.homePlansPaymentMethodScreen,
          builder: (_, state) {
            payment = state.extra! as HomePlansPaymentMethodRouteArgs;
            return const Scaffold(body: Text('existing payment'));
          },
        ),
        GoRoute(
          path: AppRoutes.homePlanMifiAltContact,
          builder: (_, state) {
            expect(state.extra, isA<MifiAltContactRouteArgs>());
            return const Scaffold(body: Text('existing MiFi contact'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      BlocProvider<PlansCubit>.value(
        value: plans,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.tap(find.text('buy plan'));
    await tester.pumpAndSettle();
  }

  for (final action in ['skip', 'proceed']) {
    testWidgets('replacement context survives $action and confirmation edits', (
      tester,
    ) async {
      await openSheet(tester);
      await tester.tap(find.text('activate now'));
      await tester.pumpAndSettle();
      expect(
        addOns!.purchaseContext,
        PlanPurchaseContext.prepaidImmediatePrimaryReplacement,
      );
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
      expect(confirmation!.purchaseContext, addOns!.purchaseContext);
      final bloc = tester
          .element(find.byType(TermsNotice))
          .read<HomePlanConfirmationBloc>();
      bloc.add(const HomePlanConfirmationTermsCheckboxToggled(true));
      await tester.pumpAndSettle();
      await tester.tap(find.text('continue'));
      await tester.pumpAndSettle();
      expect(payment!.purchaseContext, confirmation!.purchaseContext);
      expect(payment!.selectedItems.single.title, 'Liberty 70');
      expect(payment!.forceNow, isTrue);
      expect(payment!.amount, 77);
      verifyZeroInteractions(network);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  for (final scenario in [
    'no current plan',
    'future only',
    'expired',
    'postpaid',
    'active MiFi',
    'non-primary',
  ]) {
    testWidgets('$scenario retains regular context on Activate Now', (
      tester,
    ) async {
      await openSheet(
        tester,
        active: scenario != 'no current plan',
        futureOnly: scenario == 'future only',
        expired: scenario == 'expired',
        prepaid: scenario != 'postpaid',
        activeGroup: scenario == 'active MiFi'
            ? 'mifi (30 day)'
            : 'freedom (30 day)',
        newType: scenario == 'non-primary' ? 'S' : 'P',
      );
      await tester.tap(find.text('activate now'));
      await tester.pumpAndSettle();
      expect(addOns!.purchaseContext, PlanPurchaseContext.regular);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets(
    'Future Plan does not carry replacement or cancellation feedback',
    (tester) async {
      await openSheet(tester);
      await tester.tap(find.text('future plan'));
      await tester.pumpAndSettle();
      expect(addOns, isNull);
      expect(confirmation!.purchaseContext, PlanPurchaseContext.regular);
      expect(confirmation!.forceNow, isFalse);
      expect(find.textContaining('was not added'), findsNothing);
      verifyZeroInteractions(network);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets('MiFi purchase retains its existing route and regular context', (
    tester,
  ) async {
    await openSheet(tester, tab: HomePlanTab.mifi);
    await tester.tap(find.text('activate now'));
    await tester.pumpAndSettle();
    expect(find.text('existing MiFi contact'), findsOneWidget);
    expect(addOns, isNull);
    expect(find.textContaining('was not added'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
