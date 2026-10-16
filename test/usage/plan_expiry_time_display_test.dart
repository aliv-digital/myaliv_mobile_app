import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Usage/future_plan_tab.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/future_plan_card.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/usage_roaming_widget.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

class _Plans extends MockCubit<PlansState> implements PlansCubit {}

void main() {
  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  final cases = <String, (String?, DateTime?)>{
    'missing': (null, null),
    'empty': ('', null),
    'whitespace': ('   ', null),
    'invalid timestamp': ('invalid 12:30:00', null),
    'date only': ('2099-11-07', null),
    'ISO timestamp': (
      '2099-11-07T18:30:00Z',
      DateTime.utc(2099, 11, 7, 18, 30),
    ),
    'backend timestamp': (
      '2099-11-07 18:30:00',
      DateTime.utc(2099, 11, 7, 18, 30),
    ),
    'explicit midnight': ('2099-11-07T00:00:00Z', DateTime.utc(2099, 11, 7)),
  };

  for (final future in [false, true]) {
    for (final entry in cases.entries) {
      testWidgets('${future ? 'future' : 'standalone'} expiry: ${entry.key}', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final plan = BasePlanModel.fromApiMap({
          'PlanID': '1',
          'PlanName': 'roameasy usa & can',
          'PlanType': 'A',
          'StartDate': '2099-10-31T00:00:00Z',
          if (entry.value.$1 != null) 'EndDate': entry.value.$1,
        });
        final plans = _Plans();
        final config = AppUiConfigCubit();
        config.setUserType(UserType.postpaid);
        when(() => plans.state).thenReturn(PlansState(standAlonePlans: [plan]));
        addTearDown(plans.close);
        addTearDown(config.close);

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<PlansCubit>.value(value: plans),
              BlocProvider<AppUiConfigCubit>.value(value: config),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: future
                    ? const FuturePlansTab()
                    : Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [UsageRoamingPlanCard(plan: plan)],
                        ),
                      ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final expected = entry.value.$2 == null
            ? '--/--/--'
            : DateFormat('hh:mm a').format(entry.value.$2!.toLocal());
        final subtitle = find.byWidgetPredicate(
          (widget) =>
              widget is Text &&
              widget.data == expected &&
              widget.style?.fontSize == 11,
        );
        expect(subtitle, findsOneWidget);
        final expiryColumn = find
            .ancestor(of: find.text('expire'), matching: find.byType(Column))
            .first;
        final expiryDate = find.descendant(
          of: expiryColumn,
          matching: find.byWidgetPredicate(
            (widget) => widget is Text && widget.style?.fontSize == 15,
          ),
        );
        expect(
          tester.getTopLeft(subtitle).dy,
          greaterThan(tester.getBottomLeft(expiryDate).dy),
        );
        expect(
          tester.getTopRight(subtitle).dx,
          tester.getTopRight(expiryDate).dx,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final width in [320.0, 430.0]) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('expiry line fits width $width at text scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    UsageRoamingPlanCard(
                      plan: BasePlanModel.fromApiMap({
                        'PlanName': 'liberty global caribbean',
                        'StartDate': '2099-10-31',
                        'EndDate': '2099-11-07',
                      }),
                    ),
                    const SizedBox(height: 16),
                    const FuturePlanCard(
                      title: 'roameasy usa & can',
                      startDate: '31/10/99',
                      endDate: '07/11/99',
                      image: 'assets/images/Future Plan 1.png',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('--/--/--'), findsNWidgets(2));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
