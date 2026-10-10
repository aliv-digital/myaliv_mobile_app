import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/home_plan_purchase_sheet_launcher.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/roam_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/wallet_payment_activate_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/wallet_payment_activate_or_future_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/model/mifi_alt_contact_route_args.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Plans extends MockCubit<PlansState> implements PlansCubit {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

const _mifiWarning =
    'you already have an active mifi plan. buying this plan will replace it immediately.';
const _noPlanWarning =
    'you have no current plans, so your new plan will start immediately.';

void main() {
  late _Plans plans;
  late _Account account;
  late DateTime today;
  late DateTime currentEnd;
  MifiAltContactRouteArgs? altContact;
  Object? addOnsExtra;

  setUp(() {
    plans = _Plans();
    account = _Account();
    altContact = null;
    addOnsExtra = null;
    final now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    currentEnd = today.add(const Duration(days: 7));
    when(() => account.state).thenReturn(
      const AccountInfoState(
        accountInfo: AccountInfoModel(
          paymentOption: 'PrePay',
          primaryPhoneNumber: '2428011616',
        ),
      ),
    );
    instance.registerSingleton<AccountInfoCubit>(account);
  });

  tearDown(() async {
    await plans.close();
    await account.close();
    await instance.reset();
  });

  BasePlanModel activePlan({String group = 'mifi (30 day)', DateTime? start}) =>
      BasePlanModel.fromApiMap({
        'PlanID': 'current',
        'PlanType': 'P',
        'PlanGroup': group,
        'StartDate': (start ?? today.subtract(const Duration(days: 1)))
            .toUtc()
            .toIso8601String(),
        'EndDate': currentEnd.toUtc().toIso8601String(),
      });

  Future<void> openSheet(
    WidgetTester tester,
    PlansState state, {
    HomePlanTab tab = HomePlanTab.mifi,
  }) async {
    when(() => plans.state).thenReturn(state);
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
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
                    plan: const HomePlanModel(
                      id: 'mifi90',
                      title: 'mifi90',
                      subtitle: '30 days',
                      price: 90,
                      description: '',
                      benefits: [],
                    ),
                  ),
                ),
                child: const Text('purchase now'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.homePlanMifiAltContact,
          builder: (_, state) {
            altContact = state.extra! as MifiAltContactRouteArgs;
            return const Scaffold(body: Text('existing alt contact'));
          },
        ),
        GoRoute(
          path: AppRoutes.homePurchasePlanAddOns,
          builder: (_, state) {
            addOnsExtra = state.extra;
            return const Scaffold(body: Text('existing add-ons'));
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
    await tester.tap(find.text('purchase now'));
    await tester.pumpAndSettle();
  }

  testWidgets('no active plan keeps the existing immediate-start sheet', (
    tester,
  ) async {
    await openSheet(tester, const PlansState());
    expect(
      find.byType(HomePlanWalletPaymentActivateBottomSheet),
      findsOneWidget,
    );
    expect(find.text(_noPlanWarning), findsOneWidget);
    expect(find.text(_mifiWarning), findsNothing);
    expect(find.text('future plan'), findsNothing);

    await tester.tap(find.text('activate now'));
    await tester.pumpAndSettle();
    expect(find.text('existing alt contact'), findsOneWidget);
    expect(altContact!.forceNow, isTrue);
    expect(altContact!.futurePlanStartDate, '');
  });

  testWidgets('active MiFi plan shows MIFI-006 in the existing warning box', (
    tester,
  ) async {
    await openSheet(tester, PlansState(addOnsApiPrimaryPlans: [activePlan()]));
    final sheet = find.byType(HomePlanWalletPaymentActivateOrFutureBottomSheet);
    expect(sheet, findsOneWidget);
    expect(
      tester
          .widget<HomePlanWalletPaymentActivateOrFutureBottomSheet>(sheet)
          .warningText,
      _mifiWarning,
    );
    expect(find.text(_mifiWarning), findsOneWidget);
    expect(find.textContaining('activating now replaces'), findsNothing);
    expect(find.text(_noPlanWarning), findsNothing);
    expect(find.text('mifi90'), findsOneWidget);
    expect(find.text('activate now'), findsOneWidget);
    expect(find.text('future plan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('MIFI-006 activate now keeps the existing immediate action', (
    tester,
  ) async {
    await openSheet(tester, PlansState(addOnsApiPrimaryPlans: [activePlan()]));
    await tester.tap(find.text('activate now'));
    await tester.pumpAndSettle();
    expect(find.text('existing alt contact'), findsOneWidget);
    expect(altContact!.forceNow, isTrue);
    expect(altContact!.futurePlanStartDate, '');
  });

  testWidgets('MIFI-006 future plan keeps the existing scheduled action', (
    tester,
  ) async {
    await openSheet(tester, PlansState(addOnsApiPrimaryPlans: [activePlan()]));
    await tester.tap(find.text('future plan'));
    await tester.pumpAndSettle();
    expect(find.text('existing alt contact'), findsOneWidget);
    expect(altContact!.forceNow, isFalse);
    expect(
      DateTime.parse(
        altContact!.futurePlanStartDate,
      ).isAtSameMomentAs(currentEnd),
      isTrue,
    );
  });

  for (final group in ['freedom (7 day)', '']) {
    final label = group.isEmpty ? 'missing group' : 'non-MiFi';
    testWidgets('$label active plan keeps the generic MiFi-tab warning', (
      tester,
    ) async {
      await openSheet(
        tester,
        PlansState(addOnsApiPrimaryPlans: [activePlan(group: group)]),
      );
      expect(find.text(_mifiWarning), findsNothing);
      expect(
        find.textContaining('activating now replaces your current plan.'),
        findsOneWidget,
      );
    });
  }

  testWidgets('future-only MiFi plan is not treated as active', (tester) async {
    await openSheet(
      tester,
      PlansState(
        addOnsApiPrimaryPlans: [
          activePlan(start: today.add(const Duration(days: 2))),
        ],
      ),
    );
    expect(find.text(_mifiWarning), findsNothing);
  });

  testWidgets('monthly tab with an active MiFi plan is unchanged', (
    tester,
  ) async {
    await openSheet(
      tester,
      PlansState(addOnsApiPrimaryPlans: [activePlan()]),
      tab: HomePlanTab.monthly,
    );
    expect(find.text(_mifiWarning), findsNothing);
    expect(
      find.textContaining('activating now replaces your current plan.'),
      findsOneWidget,
    );
    await tester.tap(find.text('activate now'));
    await tester.pumpAndSettle();
    expect(find.text('existing add-ons'), findsOneWidget);
    expect(addOnsExtra, isNotNull);
    expect(altContact, isNull);
  });

  for (final tab in [
    HomePlanTab.roaming,
    HomePlanTab.roameasy,
    HomePlanTab.libertyGlobal,
  ]) {
    testWidgets('${tab.name} tab with an active MiFi plan is unchanged', (
      tester,
    ) async {
      await openSheet(
        tester,
        PlansState(addOnsApiPrimaryPlans: [activePlan()]),
        tab: tab,
      );
      expect(find.byType(HomePlanRoamBottomSheet), findsOneWidget);
      expect(find.text(_mifiWarning), findsNothing);
    });
  }
}
