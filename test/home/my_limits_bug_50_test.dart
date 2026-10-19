import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/cubit/consumption_limit_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/cubit/consumption_limit_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/models/consumption_limit_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/view/limit_row.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/view/my_limits_view.dart';

class _MockConsumptionLimitCubit extends MockCubit<ConsumptionLimitState>
    implements ConsumptionLimitCubit {}

class _MockDeviceLimitsCubit extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bug 50: LimitRow amount formatting and typography', () {
    testWidgets('formats price without space between dollar sign and amount', (
      tester,
    ) async {
      const limit = ConsumptionLimitModel(
        name: 'C_SMS_local_Restriction',
        initialAmount: 30.0,
        usedAmount: 5.0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LimitRow(limit: limit)),
        ),
      );

      expect(find.text('local text'), findsOneWidget);
      expect(find.text(r'$25.00 of $30.00 remaining'), findsOneWidget);

      final subtitleText = tester.widget<Text>(
        find.text(r'$25.00 of $30.00 remaining'),
      );
      expect(subtitleText.style?.color, const Color(0xFF707070));
      expect(subtitleText.style?.fontSize, 12);
      expect(subtitleText.style?.fontWeight, FontWeight.w400);

      final titleText = tester.widget<Text>(find.text('local text'));
      expect(titleText.style?.color, const Color(0xFF222222));
      expect(titleText.style?.fontSize, 12);
      expect(titleText.style?.fontWeight, FontWeight.w700);
    });
  });

  group('Bug 50: MyLimitsTab background color and structure', () {
    late _MockConsumptionLimitCubit consumptionLimitCubit;
    late _MockDeviceLimitsCubit deviceLimitsCubit;

    setUp(() {
      consumptionLimitCubit = _MockConsumptionLimitCubit();
      deviceLimitsCubit = _MockDeviceLimitsCubit();

      when(
        () => deviceLimitsCubit.state,
      ).thenReturn(DeviceLimitsState.initial());
      when(() => consumptionLimitCubit.state).thenReturn(
        const ConsumptionLimitState(
          status: ConsumptionLimitStatus.loaded,
          limits: [
            ConsumptionLimitModel(
              name: 'C_SMS_local_Restriction',
              initialAmount: 30.0,
              usedAmount: 5.0,
            ),
          ],
        ),
      );

      instance.registerSingleton<ConsumptionLimitCubit>(consumptionLimitCubit);
      instance.registerSingleton<DeviceLimitsCubit>(deviceLimitsCubit);
    });

    tearDown(() async {
      await instance.reset();
    });

    testWidgets(
      'renders limits card inside white container and button on page background',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              backgroundColor: Color(0xFFF4F6FB),
              body: MyLimitsTab(),
            ),
          ),
        );

        expect(find.text('local text'), findsOneWidget);
        expect(find.text(r'$25.00 of $30.00 remaining'), findsOneWidget);
        expect(find.text('update credit limit'), findsOneWidget);

        // Verify the limits card container has Colors.white background
        final whiteContainerFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.color == Colors.white &&
              widget.child is Column,
        );
        expect(whiteContainerFinder, findsOneWidget);

        // Verify outer MyLimitsTab widget does NOT set color: Colors.white
        final outerWhiteContainerFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.color == Colors.white &&
              widget.child is RefreshIndicator,
        );
        expect(outerWhiteContainerFinder, findsNothing);
      },
    );
  });
}
