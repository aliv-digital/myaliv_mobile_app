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
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/plan_purchase_context.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/home_plan_purchase_sheet_launcher.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/bloc/plan_purchase_plan_add_ons_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/bloc/plan_purchase_plan_add_ons_event.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/bloc/plan_purchase_plan_add_ons_state.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/model/plan_purchase_plan_add_ons_route_args.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/repository/plan_purchase_plan_add_ons_repository.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Plans extends MockCubit<PlansState> implements PlansCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

BasePlanModel _plan({
  String id = 'selected',
  String name = 'liberty70',
  List<String> addOns = const ['liberty data1', 'liberty70 data10'],
  int startsIn = -1,
  int endsIn = 7,
}) => BasePlanModel.fromApiMap({
  'PlanID': id,
  'PlanName': name,
  'PlanType': 'P',
  'PlanAmount': 70,
  'VATAmount': 7,
  'StartDate': DateTime.now().add(Duration(days: startsIn)).toIso8601String(),
  'EndDate': DateTime.now().add(Duration(days: endsIn)).toIso8601String(),
  'AvailableBoltOns': [
    for (final name in addOns)
      {
        'PlanID': name,
        'PlanName': name,
        'PlanType': 'S',
        'PlanAmount': 7.27,
        'VATAmount': 0.73,
        'PlanBuckets': [
          {'Name': 'Data', 'Amount': 1, 'Unit': 'GB'},
        ],
      },
  ],
});

void main() {
  late _Plans plans;
  late _Account account;
  late _Devices devices;

  setUp(() {
    plans = _Plans();
    account = _Account();
    devices = _Devices();
    when(
      () => devices.state,
    ).thenReturn(const DeviceLimitsState(status: DeviceLimitsStatus.loaded));
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    when(() => account.state).thenReturn(
      const AccountInfoState(
        accountInfo: AccountInfoModel(
          paymentOption: 'PrePay',
          primaryPhoneNumber: '2425551234',
        ),
      ),
    );
    instance.registerSingleton<AccountInfoCubit>(account);
  });

  tearDown(() async {
    await plans.close();
    await account.close();
    await devices.close();
    await instance.reset();
  });

  Future<List<Object?>> openSheet(
    WidgetTester tester, {
    required PlansState state,
    required BasePlanModel selected,
    HomePlanTab tab = HomePlanTab.monthly,
    String action = 'activate now',
  }) async {
    when(() => plans.state).thenReturn(state);
    final extras = <Object?>[];
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
                    selectedApiPlan: selected,
                    selectedIndex: 2,
                    plan: HomePlanModel(
                      id: selected.planId,
                      title: selected.planName,
                      subtitle: '30 days',
                      price: 77,
                      description: '',
                      benefits: const [],
                    ),
                  ),
                ),
                child: const Text('buy'),
              ),
            ),
          ),
        ),
        for (final path in [
          AppRoutes.homePurchasePlanAddOns,
          AppRoutes.homePlanConfirmationScreen,
          AppRoutes.homePlanMifiAltContact,
          AppRoutes.homeRoamingConfirmation,
        ])
          GoRoute(
            path: path,
            builder: (_, state) {
              extras.add(state.extra);
              return Scaffold(body: Text(path));
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
    await tester.tap(find.text('buy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(action));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    return extras;
  }

  for (final tab in [
    HomePlanTab.daily,
    HomePlanTab.weekly,
    HomePlanTab.monthly,
  ]) {
    testWidgets(
      '$tab skips unlisted add-ons and preserves replacement context',
      (tester) async {
        final selected = _plan(addOns: ['freedom45 data1', 'liberty70 data10']);
        final extras = await openSheet(
          tester,
          state: PlansState(addOnsApiPrimaryPlans: [_plan(id: 'current')]),
          selected: selected,
          tab: tab,
        );
        final args = extras.single as HomePlanConfirmationRouteArgs;
        expect(
          args.purchaseContext,
          PlanPurchaseContext.prepaidImmediatePrimaryReplacement,
        );
        expect(args.primaryPlanId, selected.planId);
        expect(args.primaryPlanPrice, 70);
        expect(args.primaryPlanVatAmount, 7);
        expect(args.primaryPlanTypeCode, 'P');
        expect(args.phoneNumber, '2425551234');
        expect(args.forceNow, isTrue);
        expect(args.flow, HomePlanConfirmationEntryFlow.skip);
        expect(args.selectedAddOns, isEmpty);
      },
    );
  }

  testWidgets('qualifying selected-plan add-ons open the existing page', (
    tester,
  ) async {
    // The current plan has no matching add-ons. Purchase add-ons must instead
    // be taken from the plan the subscriber is buying.
    final current = _plan(id: 'current', addOns: ['freedom45 data1']);
    final selected = _plan();
    final extras = await openSheet(
      tester,
      state: PlansState(addOnsApiPrimaryPlans: [current]),
      selected: selected,
    );
    final args = extras.single as PlanPurchasePlanAddOnsRouteArgs;
    expect(args.selectedApiPlan, same(selected));
    expect(args.activePrimaryPlan, same(current));
    expect(args.selectedIndex, 2);
    expect(
      args.purchaseContext,
      PlanPurchaseContext.prepaidImmediatePrimaryReplacement,
    );
  });

  for (final scenario in [
    'no primary',
    'expired',
    'future',
    'no bolt-ons',
    'freedom5',
  ]) {
    testWidgets('$scenario bypasses the add-ons page', (tester) async {
      final current = switch (scenario) {
        'no primary' => <BasePlanModel>[],
        'expired' => [_plan(id: 'current', startsIn: -30, endsIn: -1)],
        'future' => [_plan(id: 'current', startsIn: 10, endsIn: 40)],
        _ => [_plan(id: 'current')],
      };
      final extras = await openSheet(
        tester,
        state: PlansState(addOnsApiPrimaryPlans: current),
        selected: _plan(
          name: scenario == 'freedom5' ? 'Freedom 5' : 'liberty70',
          addOns: scenario == 'no bolt-ons' ? [] : ['liberty data1'],
        ),
      );
      final args = extras.single as HomePlanConfirmationRouteArgs;
      expect(args.forceNow, isTrue);
      expect(args.selectedAddOns, isEmpty);
    });
  }

  testWidgets('future purchase skips add-ons even when names qualify', (
    tester,
  ) async {
    final extras = await openSheet(
      tester,
      state: PlansState(addOnsApiPrimaryPlans: [_plan(id: 'current')]),
      selected: _plan(),
      action: 'future plan',
    );
    final args = extras.single as HomePlanConfirmationRouteArgs;
    expect(args.forceNow, isFalse);
    expect(args.purchaseContext, PlanPurchaseContext.regular);
    expect(args.futurePlanStartDate, isNotEmpty);
  });

  test(
    'purchase mapping preserves filtered order, identifiers, prices and VAT',
    () {
      final selected = _plan(
        addOns: ['liberty70 data10', 'freedom data 10', 'liberty text100'],
      );
      final original = selected.toJson();
      final result = PlanPurchasePlanAddOnsRepository()
          .mapAvailableBoltOnsToAddOnItems(selected);
      expect(result.map((a) => a.id), ['freedom data 10', 'liberty text100']);
      expect(result.first.price, 7.27);
      expect(result.first.vatAmount, 0.73);
      expect(result.first.subtitleLabel, 'data balance');
      expect(result.first.subtitleValue, '1gb');
      expect(result.first.planTypeCode, 'S');
      expect(selected.toJson(), original);
    },
  );

  test(
    'purchase Bloc receives only filtered add-ons and preserves route context',
    () async {
      final bloc = PlanPurchasePlanAddOnsBloc(
        repository: PlanPurchasePlanAddOnsRepository(),
      );
      addTearDown(bloc.close);
      final args = PlanPurchasePlanAddOnsRouteArgs(
        selectedApiPlan: _plan(),
        activePrimaryPlan: _plan(id: 'current'),
        purchaseContext: PlanPurchaseContext.prepaidImmediatePrimaryReplacement,
      );
      final ready = bloc.stream.firstWhere(
        (state) => state.status == PlanPurchasePlanAddOnsStatus.ready,
      );
      bloc.add(PlanPurchasePlanAddOnsStarted(routeArgs: args));
      final state = await ready;
      expect(state.addOns.map((a) => a.title), ['liberty data1']);
      expect(state.routeArgs, same(args));
    },
  );
}
