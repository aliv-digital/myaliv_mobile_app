import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plan_types.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/home_plan_purchase_sheet_launcher.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/wallet_payment_activate_bottom_sheet.dart';

// import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/wallet_payment_activate_or_future_bottom_sheet.dart';

class _MockPlansCubit extends MockCubit<PlansState> implements PlansCubit {}

void main() {
  late _MockPlansCubit plans;
  late DateTime today;
  late DateTime currentEnd;
  late DateTime futureEnd;

  setUp(() {
    plans = _MockPlansCubit();
    final now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    currentEnd = today.add(const Duration(days: 7));
    futureEnd = currentEnd.add(const Duration(days: 30));
  });

  tearDown(() async {
    await plans.close();
  });

  BasePlanModel plan({
    String id = 'current',
    String type = 'P',
    DateTime? start,
    DateTime? end,
  }) => BasePlanModel.fromApiMap({
    'PlanID': id,
    'PlanType': type,
    'StartDate': start?.toUtc().toIso8601String() ?? '',
    'EndDate': end?.toUtc().toIso8601String() ?? '',
  });

  Future<void> openSheet(WidgetTester tester, PlansState state) async {
    when(() => plans.state).thenReturn(state);
    await tester.pumpWidget(
      BlocProvider<PlansCubit>.value(
        value: plans,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => unawaited(
                  showHomePlanPurchaseBottomSheet(
                    context: context,
                    selectedTab: HomePlanTab.monthly,
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
    );
    await tester.tap(find.text('purchase now'));
    await tester.pumpAndSettle();
  }

  for (final size in [const Size(360, 640), const Size(430, 932)]) {
    testWidgets('no plan uses immediate activation wording at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openSheet(tester, const PlansState());

      expect(
        find.byType(HomePlanWalletPaymentActivateBottomSheet),
        findsOneWidget,
      );
      expect(
        find.text(
          'you have no current plans, so your new plan will start immediately.',
        ),
        findsOneWidget,
      );
      expect(find.text('activate now'), findsOneWidget);
      expect(find.text('future plan'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('standalone and future primary use shorter wording at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await openSheet(
        tester,
        PlansState(
          addOnsApiPrimaryPlans: [
            plan(id: 'future', start: currentEnd, end: futureEnd),
          ],
          standAlonePlans: [plan(type: 'A', start: today, end: currentEnd)],
        ),
      );

      expect(
        find.text(
          'you can activate your plan when your current plan ends on '
          '${DateFormat('MM-dd-yy').format(futureEnd)}.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('activating now replaces'), findsNothing);
      expect(find.text('future plan'), findsOneWidget);
      expect(find.text('activate now'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final scenario in ['primary only', 'future only', 'standalone only']) {
    testWidgets('$scenario keeps replacement wording', (tester) async {
      final end = scenario == 'future only' ? futureEnd : currentEnd;
      await openSheet(
        tester,
        PlansState(
          addOnsApiPrimaryPlans: [
            plan(
              start: scenario == 'future only' ? currentEnd : today,
              end: end,
            ),
          ],
          standAlonePlans: scenario == 'standalone only'
              ? [plan(type: 'A', start: today, end: currentEnd)]
              : [],
        ),
      );
      expect(
        find.text(
          'activating now replaces your current plan. '
          'you can also activate your plan when your current plan ends on '
          '${DateFormat('MM-dd-yy').format(end)}.',
        ),
        findsOneWidget,
      );
    });
  }

  testWidgets(
    // Previous expectation: active primary with future standalone keeps replacement wording.
    'active primary with future standalone uses the single dated action',
    (tester) async {
      await openSheet(
        tester,
        PlansState(
          addOnsApiPrimaryPlans: [plan(start: today, end: currentEnd)],
          standAlonePlans: [plan(type: 'A', start: currentEnd, end: futureEnd)],
        ),
      );
      // expect(find.textContaining('activating now replaces'), findsOneWidget);
      expect(
        find.text(
          'you can activate your plan when your current plan ends on '
          '${DateFormat('MM-dd-yy').format(futureEnd)}.',
        ),
        findsOneWidget,
      );
      expect(find.text('future plan'), findsNothing);
    },
  );

  test('today, missing and invalid start dates are not future plans', () {
    final state = PlansState(
      addOnsApiPrimaryPlans: [
        plan(start: today.add(const Duration(hours: 23))),
        plan(id: 'missing'),
        BasePlanModel.fromApiMap({'PlanID': 'invalid', 'StartDate': 'invalid'}),
      ],
    );
    expect(state.hasFuturePlans, isFalse);
    expect(const PlansState().hasFuturePlans, isFalse);
  });

  testWidgets('optimistic future plan keeps latest scheduling date', (
    tester,
  ) async {
    await openSheet(
      tester,
      PlansState(
        addOnsApiPrimaryPlans: [plan(start: today, end: currentEnd)],
        optimisticActivePlan: plan(
          id: 'future',
          start: currentEnd,
          end: futureEnd,
        ),
        standAlonePlans: [plan(type: 'A', start: today, end: currentEnd)],
      ),
    );
    final sheet = tester
        // Previous sheet: HomePlanWalletPaymentActivateOrFutureBottomSheet.
        .widget<HomePlanWalletPaymentActivateBottomSheet>(
          find.byType(HomePlanWalletPaymentActivateBottomSheet),
        );
    expect(
      sheet.warningText,
      // 'activating now replaces your current plan. '
      // 'you can also activate your plan when your current plan ends on '
      'you can activate your plan when your current plan ends on '
      '${DateFormat('MM-dd-yy').format(futureEnd)}.',
    );
  });

  testWidgets(
    // Previous expectation: active primary takes priority over standalone and future plans.
    'active primary with standalone and future plans uses the single dated action',
    (tester) async {
      await openSheet(
        tester,
        PlansState(
          addOnsApiPrimaryPlans: [
            plan(start: today, end: currentEnd),
            plan(id: 'future', start: currentEnd, end: futureEnd),
          ],
          standAlonePlans: [plan(type: 'A', start: today, end: currentEnd)],
        ),
      );
      expect(
        find.text(
          // 'activating now replaces your current plan. '
          // 'you can also activate your plan when your current plan ends on '
          'you can activate your plan when your current plan ends on '
          '${DateFormat('MM-dd-yy').format(futureEnd)}.',
        ),
        findsOneWidget,
      );
    },
  );

  test('active primary detection excludes future and expired plans', () {
    expect(
      PlansState(
        addOnsApiPrimaryPlans: [plan(start: today, end: currentEnd)],
      ).hasActivePrimaryPlan,
      isTrue,
    );
    expect(
      PlansState(
        addOnsApiPrimaryPlans: [
          plan(start: currentEnd, end: futureEnd),
          plan(
            id: 'expired',
            start: today.subtract(const Duration(days: 30)),
            end: today.subtract(const Duration(days: 1)),
          ),
        ],
      ).hasActivePrimaryPlan,
      isFalse,
    );
    expect(const PlansState().hasActivePrimaryPlan, isFalse);
  });

  testWidgets('missing end date omits the date suffix', (tester) async {
    await openSheet(
      tester,
      PlansState(
        addOnsApiPrimaryPlans: [plan(start: currentEnd)],
        standAlonePlans: [plan(type: 'A', start: today)],
      ),
    );
    expect(
      find.text('you can activate your plan when your current plan ends.'),
      findsOneWidget,
    );
  });
}
