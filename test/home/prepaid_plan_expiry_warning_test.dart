import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan_card_postpaid.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan_card_skeleton.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan_card_with_data.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/theme/theme.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _MockPlansCubit extends MockCubit<PlansState> implements PlansCubit {}

class _MockDeviceLimitsCubit extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _MockPlan extends Mock implements BasePlanModel {}

BasePlanModel _plan({
  required DateTime end,
  DateTime? start,
  String name = 'liberty120',
}) => BasePlanModel.fromApiMap({
  'PlanID': '1',
  'PlanName': name,
  'PlanType': 'P',
  'StartDate': (start ?? DateTime.now().subtract(const Duration(days: 7)))
      .toUtc()
      .toIso8601String(),
  'EndDate': end.toUtc().toIso8601String(),
});

Finder get _warning => find.textContaining('renew to stay connected.');
Finder get _expiredWarning =>
    find.textContaining('renew or buy a new plan to keep using data.');

void _expectWarningAppearance(
  WidgetTester tester, {
  required Finder message,
  required String actionText,
  required double width,
}) {
  final banner = find
      .ancestor(
        of: message,
        matching: find.byWidgetPredicate(
          (widget) => widget is Container && widget.decoration is BoxDecoration,
        ),
      )
      .first;
  final container = tester.widget<Container>(banner);
  final decoration = container.decoration! as BoxDecoration;
  expect(decoration.color, Colors.white);
  expect(decoration.border, Border.all(color: HomePlanTheme.warningBorder));
  expect(decoration.borderRadius, BorderRadius.circular(8));
  expect(container.padding, const EdgeInsets.all(10));
  final messageStyle = tester.widget<Text>(message).style!;
  expect(messageStyle.color, ColorManager.primaryRedFF0000);
  expect(messageStyle.fontFamily, 'CircularPro');
  expect(messageStyle.fontSize, 12);
  expect(messageStyle.height, 1.3);
  final icon = find.byIcon(Icons.error_outline);
  expect(icon, findsOneWidget);
  expect(tester.widget<Icon>(icon).size, 16);
  expect(tester.getTopLeft(icon).dx, tester.getTopLeft(banner).dx + 11);
  expect(tester.getTopLeft(message).dx - tester.getTopLeft(icon).dx, 26);
  final link = find.descendant(of: banner, matching: find.text(actionText));
  expect(tester.widget<Text>(link).style?.decoration, TextDecoration.underline);
  expect(tester.widget<Text>(link).style?.color, ColorManager.primaryRedFF0000);
  expect(tester.widget<Text>(link).style?.fontSize, 12);
  expect(tester.getTopLeft(link).dx, tester.getTopLeft(message).dx);
  final arrow = find.byIcon(Icons.arrow_forward);
  expect(tester.widget<Icon>(arrow).size, 12);
  expect(tester.getTopLeft(arrow).dx - tester.getTopRight(link).dx, 8);
  expect(tester.getTopLeft(banner), const Offset(24, 16));
  expect(tester.getSize(banner).width, width - 48);
  expect(
    tester.getTopLeft(find.byType(ClipRRect).first).dy -
        tester.getBottomLeft(banner).dy,
    20,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _MockPlansCubit plans;
  late _MockDeviceLimitsCubit devices;

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
    plans = _MockPlansCubit();
    devices = _MockDeviceLimitsCubit();
    when(
      () => devices.state,
    ).thenReturn(const DeviceLimitsState(status: DeviceLimitsStatus.loaded));
    instance.registerSingleton<DeviceLimitsCubit>(devices);
  });

  tearDown(() async {
    await plans.close();
    await devices.close();
    await instance.reset();
  });

  Future<void> pumpCard(
    WidgetTester tester, {
    BasePlanModel? plan,
    PlansStatus status = PlansStatus.success,
    bool isFromHome = true,
    bool showRenewButton = true,
    bool postpaid = false,
  }) async {
    when(() => plans.state).thenReturn(
      PlansState(
        status: status,
        addOnsApiPrimaryPlans: plan == null ? [] : [plan],
      ),
    );
    await tester.pumpWidget(
      BlocProvider<PlansCubit>.value(
        value: plans,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: postpaid
                  ? const PostpaidActivePlanCard(
                      config: HomeUiConfig(
                        userType: UserType.postpaid,
                        hasActivePlan: true,
                        isFuturePlan: false,
                      ),
                    )
                  : PrepaidActivePlanCardWithData(
                      isFromHome: isFromHome,
                      showRenewButton: showRenewButton,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> disposeCard(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox.shrink());

  for (final remaining in [
    const Duration(days: 3, seconds: 1),
    const Duration(days: 3, hours: 23),
    const Duration(days: 3),
    const Duration(days: 2),
    const Duration(seconds: 30),
  ]) {
    testWidgets('HOME-006 expiry in $remaining', (tester) async {
      final end = DateTime.now().add(remaining);
      await pumpCard(tester, plan: _plan(end: end));
      final expected = remaining <= const Duration(days: 3);
      expect(_warning, expected ? findsOneWidget : findsNothing);
      if (expected) {
        expect(
          find.text(
            'your liberty120 plan expires on ${DateFormat('dd/MM/yy').format(end)}. renew to stay connected.',
          ),
          findsOneWidget,
        );
        expect(find.text('renew your plan'), findsNWidgets(2));
      } else {
        expect(find.text('renew your plan'), findsOneWidget);
      }
      // The original active card keeps its height and plan rendering.
      expect(find.text('liberty120'), findsOneWidget);
      expect(tester.getSize(find.byType(ClipRRect).first).height, 216);
      expect(tester.takeException(), isNull);
      await disposeCard(tester);
    });
  }

  for (final width in [320.0, 360.0, 430.0]) {
    testWidgets('dynamic name/date and banner layout at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final end = DateTime.now().add(const Duration(days: 2));
      const name = 'liberty40 bundle for 90';
      await pumpCard(
        tester,
        plan: _plan(end: end, name: name),
      );
      expect(
        find.text(
          'your $name plan expires on ${DateFormat('dd/MM/yy').format(end)}. renew to stay connected.',
        ),
        findsOneWidget,
      );
      _expectWarningAppearance(
        tester,
        message: _warning,
        actionText: 'renew your plan',
        width: width,
      );
      expect(tester.takeException(), isNull);
      await disposeCard(tester);
    });
  }

  testWidgets(
    'future, expired, and missing-date plans have no HOME-006 warning',
    (tester) async {
      final now = DateTime.now();
      for (final plan in [
        _plan(
          start: now.add(const Duration(days: 1)),
          end: now.add(const Duration(days: 2)),
        ),
        _plan(end: now.subtract(const Duration(seconds: 1))),
        BasePlanModel.fromApiMap({
          'PlanName': 'No expiry',
          'EndDate': 'invalid',
        }),
        BasePlanModel.fromApiMap({'PlanName': 'No expiry'}),
      ]) {
        await pumpCard(tester, plan: plan);
        expect(_warning, findsNothing);
        await disposeCard(tester);
      }
    },
  );

  testWidgets('no plan and loading/initial states retain existing rendering', (
    tester,
  ) async {
    await pumpCard(tester);
    expect(_warning, findsNothing);
    expect(find.text('no active plan'), findsOneWidget);
    await disposeCard(tester);
    for (final status in [PlansStatus.initial, PlansStatus.loading]) {
      await pumpCard(
        tester,
        status: status,
        plan: _plan(end: DateTime.now().add(const Duration(days: 2))),
      );
      expect(_warning, findsNothing);
      expect(find.byType(ActivePlanCardSkeleton), findsOneWidget);
      await disposeCard(tester);
    }
  });

  testWidgets('Usage/Plans card variants and postpaid remain unchanged', (
    tester,
  ) async {
    final plan = _plan(end: DateTime.now().add(const Duration(days: 2)));
    for (final showRenew in [true, false]) {
      await pumpCard(
        tester,
        plan: plan,
        isFromHome: false,
        showRenewButton: showRenew,
      );
      expect(_warning, findsNothing);
      expect(
        find.text('renew your plan'),
        showRenew ? findsOneWidget : findsNothing,
      );
      await disposeCard(tester);
    }
    await pumpCard(tester, plan: plan, postpaid: true);
    expect(_warning, findsNothing);
    expect(find.text('renew your plan'), findsNothing);
    expect(find.text(plan.planName), findsOneWidget);
    expect(tester.takeException(), isNull);
    await disposeCard(tester);
  });

  testWidgets('warning is shown even when existing auto-renew is enabled', (
    tester,
  ) async {
    when(() => devices.state).thenReturn(
      DeviceLimitsState(
        status: DeviceLimitsStatus.loaded,
        allDeviceLimits: [
          DeviceLimitsModel.fromJson({'AutoRenew': true}),
        ],
      ),
    );
    await pumpCard(
      tester,
      plan: _plan(end: DateTime.now().add(const Duration(days: 2))),
    );
    expect(_warning, findsOneWidget);
    // The original card still hides its button, while the banner has its CTA.
    expect(find.text('renew your plan'), findsOneWidget);
    await disposeCard(tester);
  });

  testWidgets(
    'warning updates at window/expiry boundaries without plan fetch',
    (tester) async {
      final plan = _MockPlan();
      var end = DateTime.now().add(const Duration(days: 3, seconds: 1));
      when(() => plan.endDateTime).thenAnswer((_) => end);
      when(
        () => plan.startDateTime,
      ).thenReturn(DateTime.now().subtract(const Duration(days: 1)));
      when(() => plan.planName).thenReturn('liberty120');
      await pumpCard(tester, plan: plan);
      expect(_warning, findsNothing);

      // Advance the model's clock alongside Flutter's fake timer clock.
      end = DateTime.now().add(
        const Duration(days: 3) - const Duration(seconds: 1),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(_warning, findsOneWidget);

      end = DateTime.now().subtract(const Duration(seconds: 1));
      await tester.pump(const Duration(days: 3));
      expect(_warning, findsNothing);
      expect(_expiredWarning, findsOneWidget);
      expect(find.text('purchase a new plan'), findsOneWidget);
      verifyNever(() => plans.refreshCurrentTab());
      verifyNever(() => plans.refreshBundlesOnly());
      await disposeCard(tester);
    },
  );

  for (final elapsed in [
    Duration.zero,
    const Duration(seconds: 1),
    const Duration(days: 2),
  ]) {
    testWidgets('HOME-007 expired by $elapsed', (tester) async {
      final end = DateTime.now().subtract(elapsed);
      final plan = _plan(end: end);
      await pumpCard(tester, plan: plan);
      expect(
        find.text(
          'your plan expired on ${DateFormat('dd/MM/yy').format(end)}. renew or buy a new plan to keep using data.',
        ),
        findsOneWidget,
      );
      expect(find.text('purchase a new plan'), findsOneWidget);
      expect(_warning, findsNothing);
      expect(plan.endDateTime, end);
      expect(find.text(plan.planName), findsOneWidget);
      expect(tester.getSize(find.byType(ClipRRect).first).height, 216);
      verifyNever(() => plans.refreshCurrentTab());
      verifyNever(() => plans.refreshBundlesOnly());
      expect(tester.takeException(), isNull);
      await disposeCard(tester);
    });
  }

  for (final width in [320.0, 360.0, 430.0]) {
    testWidgets('HOME-007 reference banner at width $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await pumpCard(
        tester,
        plan: _plan(end: DateTime.now().subtract(const Duration(days: 1))),
      );
      _expectWarningAppearance(
        tester,
        message: _expiredWarning,
        actionText: 'purchase a new plan',
        width: width,
      );
      expect(tester.takeException(), isNull);
      await disposeCard(tester);
    });
  }

  testWidgets('HOME-007 stays hidden for unresolved or unrelated states', (
    tester,
  ) async {
    final now = DateTime.now();
    for (final plan in [
      _plan(end: now.add(const Duration(days: 2))),
      _plan(end: now.add(const Duration(days: 7))),
      _plan(
        start: now.add(const Duration(days: 1)),
        end: now.add(const Duration(days: 2)),
      ),
      BasePlanModel.fromApiMap({
        'PlanName': 'Invalid expiry',
        'EndDate': 'invalid',
      }),
      BasePlanModel.fromApiMap({'PlanName': 'Missing expiry'}),
    ]) {
      await pumpCard(tester, plan: plan);
      expect(_expiredWarning, findsNothing);
      expect(find.text('purchase a new plan'), findsNothing);
      await disposeCard(tester);
    }
    final expiredPlan = _plan(end: now.subtract(const Duration(days: 1)));
    for (final status in [PlansStatus.initial, PlansStatus.loading]) {
      await pumpCard(tester, plan: expiredPlan, status: status);
      expect(_expiredWarning, findsNothing);
      expect(find.byType(ActivePlanCardSkeleton), findsOneWidget);
      await disposeCard(tester);
    }
    for (final showRenew in [true, false]) {
      await pumpCard(
        tester,
        plan: expiredPlan,
        isFromHome: false,
        showRenewButton: showRenew,
      );
      expect(_expiredWarning, findsNothing);
      await disposeCard(tester);
    }
    await pumpCard(tester, plan: expiredPlan, postpaid: true);
    expect(_expiredWarning, findsNothing);
    expect(find.text('purchase a new plan'), findsNothing);
    await disposeCard(tester);
  });

  testWidgets('HOME-007 purchase CTA opens the existing Plans destination', (
    tester,
  ) async {
    when(() => plans.state).thenReturn(
      PlansState(
        status: PlansStatus.success,
        addOnsApiPrimaryPlans: [
          _plan(end: DateTime.now().subtract(const Duration(days: 1))),
        ],
      ),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(
            body: PrepaidActivePlanCardWithData(isFromHome: true),
          ),
        ),
        GoRoute(
          path: AppRoutes.plans,
          builder: (_, _) =>
              const Scaffold(body: Text('existing plan purchase destination')),
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
    await tester.tap(find.text('purchase a new plan'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, AppRoutes.plans);
    expect(find.text('existing plan purchase destination'), findsOneWidget);
    expect(find.byType(AutoRenewBottomSheet), findsNothing);
    verifyNever(() => plans.refreshCurrentTab());
    verifyNever(() => plans.refreshBundlesOnly());
    await disposeCard(tester);
  });

  for (final useBanner in [false, true]) {
    testWidgets('renew CTA uses existing flow (banner: $useBanner)', (
      tester,
    ) async {
      final plan = _plan(
        end: DateTime.now().add(Duration(days: useBanner ? 2 : 7)),
      );
      when(() => plans.state).thenReturn(
        PlansState(status: PlansStatus.success, addOnsApiPrimaryPlans: [plan]),
      );
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(
              body: PrepaidActivePlanCardWithData(isFromHome: true),
            ),
          ),
          GoRoute(
            path: AppRoutes.autoRenewPrepaidScreen,
            builder: (_, _) =>
                const Scaffold(body: Text('existing renewal destination')),
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
      await tester.tap(find.text('renew your plan').first);
      await tester.pumpAndSettle();
      expect(find.byType(AutoRenewBottomSheet), findsOneWidget);
      expect(
        find.text(
          'enable auto-renew using your credit card or wallet balance.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('ok'));
      await tester.pumpAndSettle();
      expect(find.text('existing renewal destination'), findsOneWidget);
      verifyNever(() => plans.refreshCurrentTab());
      verifyNever(() => plans.refreshBundlesOnly());
      await disposeCard(tester);
    });
  }
}
