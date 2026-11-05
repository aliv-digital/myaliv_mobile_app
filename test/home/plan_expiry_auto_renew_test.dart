import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan_card_with_data.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

class _Plans extends MockCubit<PlansState> implements PlansCubit {}

class _Limits extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

DeviceLimitsState _limitsState(bool autoRenew, {bool pending = false}) =>
    DeviceLimitsState(
      status: DeviceLimitsStatus.loaded,
      isTogglingAutoRenew: pending,
      allDeviceLimits: [
        DeviceLimitsModel.fromJson({'DeviceID': 42, 'AutoRenew': autoRenew}),
      ],
    );

void main() {
  late _Plans plans;
  late _Limits limits;
  late AppUiConfigCubit config;
  late StreamController<DeviceLimitsState> limitStates;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
    await (FontLoader(
      'CircularProBold',
    )..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf'))).load();
  });

  setUp(() {
    plans = _Plans();
    limits = _Limits();
    config = AppUiConfigCubit();
    limitStates = StreamController<DeviceLimitsState>.broadcast();
    instance.registerSingleton<DeviceLimitsCubit>(limits);
    instance.registerSingleton<AppUiConfigCubit>(config);
  });

  tearDown(() async {
    await limitStates.close();
    await plans.close();
    await limits.close();
    await config.close();
    await instance.reset();
  });

  Future<void> open(
    WidgetTester tester,
    Size size, {
    required bool autoRenew,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final now = DateTime.now();
    final plan = BasePlanModel.fromApiMap({
      'PlanID': '5',
      'PlanName': 'freedom5',
      'PlanType': 'P',
      'StartDate': now
          .subtract(const Duration(days: 2))
          .toUtc()
          .toIso8601String(),
      'EndDate': now.add(const Duration(days: 2)).toUtc().toIso8601String(),
      // Device limits drive the displayed toggle, not the plan metadata.
      'AutoRenew': !autoRenew,
    });
    whenListen(
      plans,
      const Stream<PlansState>.empty(),
      initialState: PlansState(
        status: PlansStatus.success,
        addOnsApiPrimaryPlans: [plan],
      ),
    );
    whenListen(
      limits,
      limitStates.stream,
      initialState: _limitsState(autoRenew),
    );
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<PlansCubit>.value(value: plans),
          BlocProvider<AppUiConfigCubit>.value(value: config),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PrepaidActivePlanCardWithData(isFromHome: true),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  final warning = find.textContaining('renew to stay connected.');

  for (final size in [const Size(320, 700), const Size(443, 958)]) {
    testWidgets(
      'auto renew ON hides the expiry warning on first load at $size',
      (tester) async {
        await open(tester, size, autoRenew: true);
        expect(find.text('on'), findsOneWidget);
        expect(warning, findsNothing);
        expect(find.text('renew your plan'), findsNothing);
        expect(find.text('freedom5'), findsOneWidget);
        expect(find.text('expire'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets('expiry warning follows confirmed auto renew changes at $size', (
      tester,
    ) async {
      await open(tester, size, autoRenew: false);
      expect(find.text('off'), findsOneWidget);
      expect(warning, findsOneWidget);
      final planState = plans.state;

      // A pending enable leaves the existing warning until renewal is enabled.
      limitStates.add(_limitsState(false, pending: true));
      await tester.pump();
      expect(warning, findsOneWidget);

      limitStates.add(_limitsState(true));
      await tester.pumpAndSettle();
      expect(find.text('on'), findsOneWidget);
      expect(warning, findsNothing);
      expect(find.text('renew your plan'), findsNothing);
      expect(find.text('freedom5'), findsOneWidget);
      expect(find.text('expire'), findsOneWidget);

      // A pending or failed disable still has renewal ON, so no warning appears.
      limitStates.add(_limitsState(true, pending: true));
      await tester.pump();
      expect(warning, findsNothing);
      limitStates.add(_limitsState(true));
      await tester.pumpAndSettle();
      expect(warning, findsNothing);

      limitStates.add(_limitsState(false));
      await tester.pumpAndSettle();
      expect(find.text('off'), findsOneWidget);
      expect(warning, findsOneWidget);
      expect(identical(plans.state, planState), isTrue);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
