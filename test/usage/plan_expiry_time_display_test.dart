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
    'US timestamp': ('11/7/2099 6:30:00 PM', DateTime.utc(2099, 11, 7, 18, 30)),
    'timestamp with offset': (
      '2099-11-07T18:30:00-05:00',
      DateTime.utc(2099, 11, 7, 23, 30),
    ),
    'compact ISO timestamp': (
      '20991107T183000Z',
      DateTime.utc(2099, 11, 7, 18, 30),
    ),
    'explicit midnight': ('2099-11-07T00:00:00Z', DateTime.utc(2099, 11, 7)),
  };

  for (final (future, userType, planType) in [
    (false, UserType.postpaid, 'A'),
    (true, UserType.postpaid, 'A'),
    (true, UserType.prepaid, 'A'),
    (true, UserType.postpaid, 'P'),
    (true, UserType.prepaid, 'P'),
  ]) {
    for (final entry in cases.entries) {
      if (!future && entry.key == 'compact ISO timestamp') {
        continue;
      }
      testWidgets(
        '${future ? 'future' : 'standalone'} $userType $planType expiry: ${entry.key}',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final plan = BasePlanModel.fromApiMap({
            'PlanID': '1',
            'PlanName': 'roameasy usa & can',
            'PlanType': planType,
            'StartDate': '2099-10-31T00:00:00Z',
            if (entry.value.$1 != null) 'EndDate': entry.value.$1,
          });
          final plans = _Plans();
          final config = AppUiConfigCubit();
          config.setUserType(userType);
          when(() => plans.state).thenReturn(
            PlansState(
              standAlonePlans: planType == 'A' ? [plan] : [],
              addOnsApiPrimaryPlans: planType == 'P' ? [plan] : [],
            ),
          );
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
          final expectedDate = entry.value.$2 != null
              ? DateFormat('dd/MM/yy').format(entry.value.$2!.toLocal())
              : entry.key == 'date only'
              ? (future
                    ? '07/11/99'
                    : DateFormat(
                        'dd/MM/yy',
                      ).format(DateTime.utc(2099, 11, 7).toLocal()))
              : '--/--/--';
          expect(tester.widget<Text>(expiryDate).data, expectedDate);
          expect(
            tester.getTopLeft(subtitle).dy,
            greaterThan(tester.getBottomLeft(expiryDate).dy),
          );
          expect(
            tester.getTopRight(subtitle).dx,
            tester.getTopRight(expiryDate).dx,
          );
          expect(tester.takeException(), isNull);
        },
      );
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
