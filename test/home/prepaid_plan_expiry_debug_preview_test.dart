import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
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
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan_card_postpaid.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan_card_with_data.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/theme/theme.dart';
import 'package:myaliv_mobile_app/resources/color_manager.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Plans extends MockCubit<PlansState> implements PlansCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Plans plans;
  late _Devices devices;
  late BasePlanModel plan;
  late DateTime realEnd;

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
    devices = _Devices();
    realEnd = DateTime.now().add(const Duration(days: 30));
    plan = BasePlanModel.fromApiMap({
      'PlanID': 'real-plan',
      'PlanName': 'liberty120',
      'StartDate': DateTime.now()
          .subtract(const Duration(days: 7))
          .toUtc()
          .toIso8601String(),
      'EndDate': realEnd.toUtc().toIso8601String(),
    });
    when(() => plans.state).thenReturn(
      PlansState(status: PlansStatus.success, addOnsApiPrimaryPlans: [plan]),
    );
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

  Future<void> pumpCard(WidgetTester tester, Widget card) {
    return tester.pumpWidget(
      BlocProvider<PlansCubit>.value(
        value: plans,
        child: MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: card)),
        ),
      ),
    );
  }

  test('preview requires a debug build and explicit opt-in', () {
    expect(
      debugForcePlanExpiryWarning,
      kDebugMode && const bool.fromEnvironment('debugForcePlanExpiryWarning'),
    );
    if (kReleaseMode || kProfileMode) {
      expect(debugForcePlanExpiryWarning, isFalse);
    }
  });

  for (final width in [320.0, 360.0, 430.0]) {
    testWidgets('expiry-only debug preview at width $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final originalEndDate = plan.endDate;
      final simulatedDate = DateFormat(
        'dd/MM/yy',
      ).format(DateTime.now().add(const Duration(days: 2)));
      await pumpCard(
        tester,
        const PrepaidActivePlanCardWithData(isFromHome: true),
      );
      if (debugForcePlanExpiryWarning) {
        final message = find.text(
          'your liberty120 plan expires on $simulatedDate. renew to stay connected.',
        );
        expect(message, findsOneWidget);
        final red = ColorManager.primaryRedFF0000;
        expect(tester.widget<Text>(message).style?.color, red);
        final banner = find
            .ancestor(
              of: message,
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is Container && widget.decoration is BoxDecoration,
              ),
            )
            .first;
        final decoration =
            tester.widget<Container>(banner).decoration! as BoxDecoration;
        expect(decoration.color, Colors.white);
        expect(
          decoration.border,
          Border.all(color: HomePlanTheme.warningBorder, width: 1),
        );
        expect(decoration.borderRadius, BorderRadius.circular(8));
        final warningIcon = find.byIcon(Icons.error_outline);
        expect(warningIcon, findsOneWidget);
        expect(tester.widget<Icon>(warningIcon).color, red);
        expect(
          tester.getTopLeft(warningIcon).dx,
          lessThan(tester.getTopLeft(message).dx),
        );
        final link = find.descendant(
          of: banner,
          matching: find.text('renew your plan'),
        );
        expect(link, findsOneWidget);
        expect(tester.widget<Text>(link).style?.color, red);
        expect(
          tester.widget<Text>(link).style?.decoration,
          TextDecoration.underline,
        );
        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
        final cardTop = tester.getTopLeft(find.byType(ClipRRect).first).dy;
        expect(cardTop - tester.getBottomLeft(banner).dy, 20);
        expect(tester.getTopLeft(banner), const Offset(24, 16));
        expect(tester.getSize(banner).width, width - 48);
        expect(tester.widget<Text>(message).style?.fontSize, 12);
        expect(tester.widget<Icon>(warningIcon).size, 16);
        expect(tester.widget<Icon>(find.byIcon(Icons.arrow_forward)).size, 12);
      } else {
        expect(find.textContaining('renew to stay connected.'), findsNothing);
        expect(find.byIcon(Icons.error_outline), findsNothing);
      }
      expect(plan.endDate, originalEndDate);
      expect(plan.endDateTime, realEnd);
      expect(find.text(DateFormat('dd/MM/yy').format(realEnd)), findsOneWidget);
      expect(find.text('liberty120'), findsOneWidget);
      expect(tester.getSize(find.byType(ClipRRect).first).height, 216);
      verifyNever(() => plans.refreshCurrentTab());
      verifyNever(() => plans.refreshBundlesOnly());
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('preview does not affect other card variants or postpaid', (
    tester,
  ) async {
    for (final showRenew in [true, false]) {
      await pumpCard(
        tester,
        PrepaidActivePlanCardWithData(showRenewButton: showRenew),
      );
      expect(find.textContaining('renew to stay connected.'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    }
    await pumpCard(
      tester,
      const PostpaidActivePlanCard(
        config: HomeUiConfig(
          userType: UserType.postpaid,
          hasActivePlan: true,
          isFuturePlan: false,
        ),
      ),
    );
    expect(find.textContaining('renew to stay connected.'), findsNothing);
    expect(plan.endDateTime, realEnd);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('preview CTA retains the existing renewal flow', (tester) async {
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
              const Scaffold(body: Text('existing renewal flow')),
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
    await tester.tap(find.text('ok'));
    await tester.pumpAndSettle();
    expect(find.text('existing renewal flow'), findsOneWidget);
    expect(plan.endDateTime, realEnd);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
