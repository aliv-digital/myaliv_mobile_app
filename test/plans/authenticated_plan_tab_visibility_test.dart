import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/authenticated_add_on_filter_service.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/view/home_plan_screen.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/plan_tabs.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

class _Plans extends MockCubit<PlansState> implements PlansCubit {}

void main() {
  late _Plans plans;
  late AppUiConfigCubit config;

  setUpAll(() {
    registerFallbackValue(UserType.prepaid);
  });

  setUp(() {
    plans = _Plans();
    config = AppUiConfigCubit();
    when(
      () => plans.started(userType: any(named: 'userType')),
    ).thenAnswer((_) async {});
  });

  tearDown(() async {
    await plans.close();
    await config.close();
  });

  for (final width in [360.0, 430.0]) {
    for (final scenario in [
      'matching',
      'no matches',
      'no primary',
      'expired',
      'future',
      'empty catalogue',
    ]) {
      testWidgets('$scenario controls the add-ons tab at $width', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 932);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final now = DateTime.now();
        final primary = BasePlanModel.fromApiMap({
          'PlanID': 'current',
          'PlanName': 'liberty70',
          'PlanType': 'P',
          'StartDate': now
              .add(Duration(days: scenario == 'future' ? 10 : -10))
              .toIso8601String(),
          'EndDate': now
              .add(Duration(days: scenario == 'expired' ? -1 : 40))
              .toIso8601String(),
          'AvailableBoltOns': [
            {
              'PlanID': 'addon',
              'PlanName': scenario == 'matching'
                  ? 'liberty data1'
                  : 'liberty70 data1',
              'PlanType': 'S',
            },
          ],
        });
        final primaryPlans = scenario == 'no primary'
            ? <BasePlanModel>[]
            : [primary];
        when(() => plans.state).thenReturn(
          PlansState(
            status: PlansStatus.success,
            addOnsApiPrimaryPlans: primaryPlans,
            addOns: const AuthenticatedAddOnFilterService().filter(
              primaryPlans,
            ),
            monthlyApiPlans: scenario == 'empty catalogue' ? [] : [primary],
          ),
        );
        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<PlansCubit>.value(value: plans),
              BlocProvider<AppUiConfigCubit>.value(value: config),
            ],
            child: const MaterialApp(home: HomePlanScreen()),
          ),
        );
        await tester.pumpAndSettle();
        final tabs = tester
            .widget<HomePlanTabs>(find.byType(HomePlanTabs))
            .tabs!;
        expect(tabs.contains(HomePlanTab.addOns), scenario == 'matching');
        expect(tabs, isNotEmpty);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
