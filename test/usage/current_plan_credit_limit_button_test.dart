import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan_card_postpaid.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/upgrade_credit_limit_button.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/current_plan_active_card.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/postpaid_current_plan.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Plans extends MockCubit<PlansState> implements PlansCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

const _postpaid = HomeUiConfig(
  userType: UserType.postpaid,
  hasActivePlan: true,
  isFuturePlan: false,
);

void main() {
  setUpAll(() async {
    await (FontLoader(
      'CircularPro',
    )..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))).load();
  });

  late _Plans plans;
  late AppUiConfigCubit config;

  setUp(() {
    plans = _Plans();
    config = AppUiConfigCubit(initialConfig: _postpaid);
    when(() => plans.state).thenReturn(
      PlansState(
        status: PlansStatus.success,
        addOnsApiPrimaryPlans: [
          BasePlanModel.fromApiMap({
            'PlanID': '1',
            'PlanName': 'liberty prime 24m sr',
            'StartDate': '2025-08-19T00:00:00Z',
            'EndDate': '2036-01-01T00:00:00Z',
          }),
        ],
      ),
    );
  });

  tearDown(() async {
    await plans.close();
    await config.close();
  });

  Widget provide(Widget child) => MultiBlocProvider(
    providers: [
      BlocProvider<PlansCubit>.value(value: plans),
      BlocProvider.value(value: config),
    ],
    child: child,
  );

  for (final size in [const Size(320, 700), const Size(430, 932)]) {
    for (final fromHome in [false, true]) {
      testWidgets(
        '${fromHome ? 'Home' : 'Usage'} credit limit button opens my limits at $size',
        (tester) async {
          await tester.binding.setSurfaceSize(size);
          addTearDown(() => tester.binding.setSurfaceSize(null));
          Widget card() => fromHome
              ? const PostpaidActivePlanCard(config: _postpaid)
              : const CurrentPlanActiveCard(config: _postpaid);
          final router = GoRouter(
            initialLocation: fromHome ? AppRoutes.home : AppRoutes.usage,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => Scaffold(body: ListView(children: [card()])),
              ),
              GoRoute(
                path: AppRoutes.usage,
                builder: (_, _) => Scaffold(body: ListView(children: [card()])),
              ),
            ],
          );
          addTearDown(router.dispose);
          await tester.pumpWidget(
            provide(MaterialApp.router(routerConfig: router)),
          );
          await tester.pumpAndSettle();

          expect(find.text('liberty prime 24m sr'), findsOneWidget);
          expect(find.byType(UpgradeCreditLimitButton), findsOneWidget);
          final button = find.widgetWithText(
            ElevatedButton,
            'upgrade credit limit',
          );
          final rect = tester.getRect(button);
          expect(rect.left, greaterThanOrEqualTo(40));
          expect(rect.right, lessThanOrEqualTo(size.width - 40));
          expect(rect.height, 50);
          expect(tester.takeException(), isNull);

          await tester.tap(button);
          await tester.pumpAndSettle();
          expect(config.state.openMyLimits, isTrue);
          expect(config.state.isCurrentPlan, isFalse);
          expect(config.state.isFuturePlan, isFalse);
          expect(
            router.routeInformationProvider.value.uri.path,
            AppRoutes.usage,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('prepaid active plan does not show the credit limit button', (
    tester,
  ) async {
    final devices = _Devices();
    when(() => devices.state).thenReturn(DeviceLimitsState.initial());
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    addTearDown(() async {
      await instance.unregister<DeviceLimitsCubit>();
      await devices.close();
    });
    await tester.pumpWidget(
      provide(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                CurrentPlanActiveCard(
                  config: _postpaid.copyWith(userType: UserType.prepaid),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(UpgradeCreditLimitButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no active postpaid plan keeps the empty state', (tester) async {
    when(
      () => plans.state,
    ).thenReturn(const PlansState(status: PlansStatus.success));
    await tester.pumpWidget(
      provide(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [const CurrentPlanActiveCard(config: _postpaid)],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('you currently do not have an active plan'),
      findsOneWidget,
    );
    expect(find.byType(UpgradeCreditLimitButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('add-ons card keeps the credit limit button hidden', (
    tester,
  ) async {
    await tester.pumpWidget(
      provide(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [const PostpaidCurrentPlan(showRenewButton: false)],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(UpgradeCreditLimitButton), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
