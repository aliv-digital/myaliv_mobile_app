import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/theme/theme.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/home_plan_purchase_sheet_launcher.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/roam_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/wallet_payment_activate_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Plans/homePlanConfirmation/models/home_plan_confirmation_models.dart';
import 'package:myaliv_mobile_app/app/Plans/mifiAltContact/model/mifi_alt_contact_route_args.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _MockPlansCubit extends MockCubit<PlansState> implements PlansCubit {}

class _MockAccountInfoCubit extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _MockDeviceLimitsCubit extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

void main() {
  late _MockPlansCubit plans;
  late _MockAccountInfoCubit account;
  late _MockDeviceLimitsCubit devices;
  late DateTime today;
  late DateTime currentEnd;
  late DateTime firstFutureEnd;
  late DateTime lastFutureEnd;

  setUp(() async {
    await instance.reset();
    plans = _MockPlansCubit();
    account = _MockAccountInfoCubit();
    devices = _MockDeviceLimitsCubit();
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    when(() => devices.state).thenReturn(DeviceLimitsState.initial());
    when(() => account.state).thenReturn(
      const AccountInfoState(
        accountInfo: AccountInfoModel(phoneNumber: '2425551234'),
      ),
    );
    final now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    currentEnd = today.add(const Duration(days: 7));
    firstFutureEnd = currentEnd.add(const Duration(days: 30));
    lastFutureEnd = firstFutureEnd.add(const Duration(days: 30));
  });

  tearDown(() async {
    await plans.close();
    await account.close();
    await devices.close();
    await instance.reset();
  });

  PlansState scheduledState() => PlansState(
    addOnsApiPrimaryPlans: [
      _plan(id: 'current', start: today, end: currentEnd),
      // Deliberately unsorted: the date must come from the last expiry.
      _plan(id: 'future2', start: firstFutureEnd, end: lastFutureEnd),
      _plan(id: 'future1', start: currentEnd, end: firstFutureEnd),
    ],
    standAlonePlans: [
      _plan(id: 'standalone', type: 'A', start: today, end: currentEnd),
    ],
  );

  Future<List<Object?>> openSheet(
    WidgetTester tester,
    PlansState state, {
    HomePlanTab selectedTab = HomePlanTab.monthly,
  }) async {
    when(() => plans.state).thenReturn(state);
    final routeExtras = <Object?>[];
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider<PlansCubit>.value(
            value: plans,
            child: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => unawaited(
                    showHomePlanPurchaseBottomSheet(
                      context: context,
                      selectedTab: selectedTab,
                      plan: const HomePlanModel(
                        id: 'liberty120',
                        title: 'liberty120',
                        subtitle: '30 days',
                        price: 120,
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
        ),
        for (final path in [
          AppRoutes.homePlanConfirmationScreen,
          AppRoutes.homePlanMifiAltContact,
        ])
          GoRoute(
            path: path,
            builder: (context, state) {
              routeExtras.add(state.extra);
              return const Scaffold(body: Text('next purchase step'));
            },
          ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('purchase now'));
    await tester.pumpAndSettle();
    return routeExtras;
  }

  for (final size in [const Size(360, 640), const Size(430, 932)]) {
    testWidgets('one dated action uses the last future expiry at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openSheet(tester, scheduledState());

      final dateText = DateFormat('MM-dd-yy').format(lastFutureEnd);
      expect(
        find.text(
          'you can activate your plan when your current plan ends on $dateText.',
        ),
        findsOneWidget,
      );
      expect(find.text('activate my new plan on $dateText'), findsOneWidget);
      expect(find.text('future plan'), findsNothing);
      expect(find.text('activate now'), findsNothing);
      expect(_scheduledButton(), findsOneWidget);
      final button = tester.widget<ElevatedButton>(_scheduledButton());
      expect(
        button.style!.backgroundColor!.resolve({}),
        HomePlanTheme.activateNowButton,
      );
      expect(tester.getSize(_scheduledButton()).width, size.width - 32);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('dated action passes the same date into future confirmation', (
    tester,
  ) async {
    final extras = await openSheet(tester, scheduledState());
    await tester.tap(_scheduledButton());
    await tester.pumpAndSettle();

    final args = extras.single as HomePlanConfirmationRouteArgs;
    expect(args.forceNow, isFalse);
    expect(args.isFuture, isTrue);
    expect(args.futurePlanStartDate, lastFutureEnd.toIso8601String());
    expect(args.primaryPlanId, 'liberty120');
    expect(args.primaryPlanPrice, 120);
    expect(args.flow, HomePlanConfirmationEntryFlow.skip);
  });

  testWidgets('a later standalone expiry controls both texts and navigation', (
    tester,
  ) async {
    final finalEnd = lastFutureEnd.add(const Duration(days: 10));
    final state = scheduledState().copyWith(
      standAlonePlans: [
        _plan(id: 'standalone', type: 'A', start: today, end: finalEnd),
      ],
    );
    final extras = await openSheet(tester, state);
    final dateText = DateFormat('MM-dd-yy').format(finalEnd);
    expect(find.text('activate my new plan on $dateText'), findsOneWidget);
    expect(
      find.textContaining('current plan ends on $dateText.'),
      findsOneWidget,
    );
    await tester.tap(_scheduledButton());
    await tester.pumpAndSettle();
    expect(
      (extras.single as HomePlanConfirmationRouteArgs).futurePlanStartDate,
      finalEnd.toIso8601String(),
    );
    // The primary-only rule used by other scenarios remains unchanged.
    expect(state.latestPrimaryPlanEndDate, lastFutureEnd);
  });

  test('final purchased expiry includes add-ons and ignores missing dates', () {
    final finalEnd = lastFutureEnd.add(const Duration(days: 15));
    final state = scheduledState().copyWith(
      secondaryPlans: [
        _plan(id: 'addon', type: 'S', start: today, end: finalEnd),
        _plan(id: 'missing-end'),
      ],
    );
    expect(state.latestPurchasedPlanEndDate, finalEnd);
    expect(state.latestPrimaryPlanEndDate, lastFutureEnd);
    expect(const PlansState().latestPurchasedPlanEndDate, isNull);
  });

  testWidgets('dated action keeps the existing bundles refresh guard', (
    tester,
  ) async {
    final extras = await openSheet(tester, scheduledState());
    when(
      () => plans.state,
    ).thenReturn(scheduledState().copyWith(isRefreshingBundles: true));
    await tester.tap(_scheduledButton());
    await tester.pumpAndSettle();

    expect(extras, isEmpty);
    expect(_scheduledButton(), findsOneWidget);
    expect(
      find.text('updating your plans, please try again in a moment'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('dated MiFi action preserves the future alternate-contact flow', (
    tester,
  ) async {
    final extras = await openSheet(
      tester,
      scheduledState(),
      selectedTab: HomePlanTab.mifi,
    );
    await tester.tap(_scheduledButton());
    await tester.pumpAndSettle();

    final args = extras.single as MifiAltContactRouteArgs;
    expect(args.forceNow, isFalse);
    expect(args.futurePlanStartDate, lastFutureEnd.toIso8601String());
  });

  testWidgets('active primary and future without standalone keep two actions', (
    tester,
  ) async {
    final state = scheduledState().copyWith(standAlonePlans: []);
    final extras = await openSheet(tester, state);
    expect(find.text('activate now'), findsOneWidget);
    expect(find.text('future plan'), findsOneWidget);
    expect(find.textContaining('activating now replaces'), findsOneWidget);
    await tester.tap(find.text('future plan'));
    await tester.pumpAndSettle();
    expect(
      (extras.single as HomePlanConfirmationRouteArgs).futurePlanStartDate,
      lastFutureEnd.toIso8601String(),
    );
  });

  testWidgets('no valid end date retains the existing undated choices', (
    tester,
  ) async {
    await openSheet(
      tester,
      PlansState(
        addOnsApiPrimaryPlans: [
          _plan(id: 'current', start: today),
          _plan(id: 'future', start: currentEnd),
        ],
        standAlonePlans: [_plan(id: 'standalone', type: 'A', start: today)],
      ),
    );
    expect(find.text('future plan'), findsOneWidget);
    expect(find.text('activate now'), findsOneWidget);
    expect(find.textContaining('activate my new plan on'), findsNothing);
  });

  testWidgets('roaming purchases retain their date-picker sheet', (
    tester,
  ) async {
    await openSheet(tester, scheduledState(), selectedTab: HomePlanTab.roaming);
    expect(find.byType(HomePlanRoamBottomSheet), findsOneWidget);
    expect(find.textContaining('activate my new plan on'), findsNothing);
  });
}

BasePlanModel _plan({
  required String id,
  String type = 'P',
  DateTime? start,
  DateTime? end,
}) => BasePlanModel.fromApiMap({
  'PlanID': id,
  'PlanType': type,
  'StartDate': start?.toUtc().toIso8601String() ?? '',
  'EndDate': end?.toUtc().toIso8601String() ?? '',
});

Finder _scheduledButton() => find.descendant(
  of: find.byType(HomePlanWalletPaymentActivateBottomSheet),
  matching: find.byType(ElevatedButton),
);
