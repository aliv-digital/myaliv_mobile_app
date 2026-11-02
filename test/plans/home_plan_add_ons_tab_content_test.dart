import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan_card_with_data.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/add_on_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/widgets/home_plan_add_ons_tab_content.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/postpaid_current_plan.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:core/core.dart';

class MockPlansCubit extends Mock implements PlansCubit {}

class MockDeviceLimitsCubit extends Mock implements DeviceLimitsCubit {}

class MockAppUiConfigCubit extends Mock implements AppUiConfigCubit {}

void main() {
  late MockPlansCubit mockPlansCubit;
  late MockDeviceLimitsCubit mockLimitsCubit;
  late MockAppUiConfigCubit mockUiConfigCubit;

  const sampleAddOns = <HomePlanAddOnModel>[
    HomePlanAddOnModel(
      id: 'addon_1',
      title: 'liberty140 data10',
      label: 'data balance',
      value: '10gb',
      price: 31.0,
      vatAmount: 3.1,
    ),
  ];

  setUpAll(() {
    mockLimitsCubit = MockDeviceLimitsCubit();
    when(() => mockLimitsCubit.state).thenReturn(DeviceLimitsState.initial());
    when(() => mockLimitsCubit.stream).thenAnswer((_) => const Stream.empty());
    if (instance.isRegistered<DeviceLimitsCubit>()) {
      instance.unregister<DeviceLimitsCubit>();
    }
    instance.registerSingleton<DeviceLimitsCubit>(mockLimitsCubit);
  });

  setUp(() {
    mockPlansCubit = MockPlansCubit();
    mockUiConfigCubit = MockAppUiConfigCubit();
  });

  Widget createWidget({
    required UserType userType,
    required BasePlanModel primaryPlan,
  }) {
    when(() => mockUiConfigCubit.state).thenReturn(
      HomeUiConfig(
        userType: userType,
        hasActivePlan: true,
        isFuturePlan: false,
        isCurrentPlan: false,
      ),
    );
    when(
      () => mockUiConfigCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(() => mockPlansCubit.state).thenReturn(
      PlansState(
        status: PlansStatus.success,
        addOnsApiPrimaryPlans: [primaryPlan],
        addOnsApiLastSyncedAt: DateTime.now(),
      ),
    );
    when(() => mockPlansCubit.stream).thenAnswer((_) => const Stream.empty());

    return MultiBlocProvider(
      providers: [
        BlocProvider<PlansCubit>.value(value: mockPlansCubit),
        BlocProvider<AppUiConfigCubit>.value(value: mockUiConfigCubit),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: HomePlanAddOnsTabContent(
            addOns: sampleAddOns,
            selectedAddOnIds: const {},
            onToggleAddOn: (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets(
    'renders red active plan card for prepaid users with plan name and policy',
    (tester) async {
      final prepaidPlan = BasePlanModel.fromApiMap({
        'PlanID': '1',
        'PlanName': 'liberty120',
        'PlanType': 'P',
        'StartDate': '2024-08-20T00:00:00Z',
        'EndDate': '2024-09-19T23:59:00Z',
      });

      await tester.pumpWidget(
        createWidget(userType: UserType.prepaid, primaryPlan: prepaidPlan),
      );

      expect(find.byType(PrepaidActivePlanCardWithData), findsOneWidget);
      expect(find.byType(PostpaidCurrentPlan), findsNothing);
      expect(find.text('liberty120'), findsOneWidget);
      expect(find.text('active plan'), findsOneWidget);
      expect(find.text('auto renew'), findsOneWidget);
      expect(find.text('fair use policy'), findsOneWidget);
      expect(find.text('liberty140 data10'), findsOneWidget);
    },
  );

  testWidgets(
    'renders red active plan card (same design) for postpaid users instead of PostpaidCurrentPlan',
    (tester) async {
      final postpaidPlan = BasePlanModel.fromApiMap({
        'PlanID': '2',
        'PlanName': 'postpaid prime',
        'PlanType': 'O',
        'StartDate': '2024-08-01T00:00:00Z',
        'EndDate': '2036-01-01T00:00:00Z',
      });

      await tester.pumpWidget(
        createWidget(userType: UserType.postpaid, primaryPlan: postpaidPlan),
      );

      // Both prepaid and postpaid now render PrepaidActivePlanCardWithData (the red card)
      expect(find.byType(PrepaidActivePlanCardWithData), findsOneWidget);
      expect(find.byType(PostpaidCurrentPlan), findsNothing);
      expect(find.text('postpaid prime'), findsOneWidget);
      expect(find.text('active plan'), findsOneWidget);
      expect(find.text('auto renew'), findsOneWidget);
      // Sentinel end date 2036-01-01 is replaced with billing cycle end date with 11:59 PM
      expect(find.text('01/01/36'), findsNothing);
      expect(find.text('11:59 PM'), findsOneWidget);
    },
  );

  testWidgets('active and expire dates are aligned to the same baseline', (
    tester,
  ) async {
    final prepaidPlan = BasePlanModel.fromApiMap({
      'PlanID': '1',
      'PlanName': 'liberty120',
      'PlanType': 'P',
      'StartDate': '2024-08-20T00:00:00Z',
      'EndDate': '2024-09-19T23:59:00Z',
    });

    await tester.pumpWidget(
      createWidget(userType: UserType.prepaid, primaryPlan: prepaidPlan),
    );

    final activeFinder = find.text('active');
    final expireFinder = find.text('expire');
    final activeDateFinder = find.text('20/08/24');

    expect(activeFinder, findsOneWidget);
    expect(expireFinder, findsOneWidget);
    expect(activeDateFinder, findsOneWidget);

    // Verify label top alignment
    final activeTop = tester.getTopLeft(activeFinder).dy;
    final expireTop = tester.getTopLeft(expireFinder).dy;
    expect(activeTop, equals(expireTop));

    // Find the expire date text widget
    final activeDateTop = tester.getTopLeft(activeDateFinder).dy;
    final activeDateBottom = tester.getBottomLeft(activeDateFinder).dy;

    final allTexts = tester.widgetList<Text>(find.byType(Text));
    final expireDateText = allTexts.firstWhere(
      (t) => t.data != null && t.data!.contains('/24') && t.data != '20/08/24',
    );
    final expireDateFinder = find.text(expireDateText.data!);
    final expireDateTop = tester.getTopLeft(expireDateFinder).dy;
    final expireDateBottom = tester.getBottomLeft(expireDateFinder).dy;

    expect(activeDateTop, equals(expireDateTop));
    expect(activeDateBottom, equals(expireDateBottom));

    // Verify generous gap between package name and date portion (at least 30px)
    final planNameBottom = tester.getBottomLeft(find.text('liberty120')).dy;
    final gap = activeTop - planNameBottom;
    expect(gap, greaterThanOrEqualTo(30.0));
  });
}
