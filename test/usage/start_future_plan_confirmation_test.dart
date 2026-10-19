import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Usage/future_plan_tab.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/start_future_plan_bottom_sheet.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

class _MockPlansCubit extends MockCubit<PlansState> implements PlansCubit {}

class _MockDeviceLimitsCubit extends Mock implements DeviceLimitsCubit {}

class _MockNetworkService extends Mock implements NetworkService {}

void main() {
  late _MockPlansCubit plans;
  late _MockDeviceLimitsCubit devices;
  late _MockNetworkService network;
  late AppUiConfigCubit config;
  const deviceId = 42;
  final requestPath = '${Api.startFuturePlan}/$deviceId/jump-start-future-plan';

  setUp(() {
    plans = _MockPlansCubit();
    devices = _MockDeviceLimitsCubit();
    network = _MockNetworkService();
    config = AppUiConfigCubit();
    final startDate = DateTime.now().add(const Duration(days: 7));
    when(() => plans.state).thenReturn(
      PlansState(
        addOnsApiPrimaryPlans: [
          BasePlanModel.fromApiMap({
            'PlanID': '1',
            'PlanName': 'Scheduled plan',
            'PlanType': 'P',
            'StartDate': startDate.toIso8601String(),
            'EndDate': startDate
                .add(const Duration(days: 30))
                .toIso8601String(),
          }),
        ],
      ),
    );
    when(() => plans.refreshCurrentTab()).thenAnswer((_) async {});
    when(() => devices.state).thenReturn(
      DeviceLimitsState(
        status: DeviceLimitsStatus.loaded,
        allDeviceLimits: [
          DeviceLimitsModel.fromJson({'DeviceID': deviceId}),
        ],
      ),
    );
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<NetworkService>(network);
  });

  tearDown(() async {
    await config.close();
    await plans.close();
    await instance.reset();
  });

  Future<void> showTab(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AppUiConfigCubit>.value(value: config),
          BlocProvider<PlansCubit>.value(value: plans),
        ],
        child: const MaterialApp(home: Scaffold(body: FuturePlansTab())),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(find.text('start plan'));
    await tester.pumpAndSettle();
    expect(find.byType(StartFuturePlanBottomSheet), findsOneWidget);
    expect(
      find.text('are you sure you want to start this plan now?'),
      findsOneWidget,
    );
    verifyZeroInteractions(network);
  }

  for (final size in [const Size(360, 640), const Size(430, 932)]) {
    testWidgets('OK starts the existing process once at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final pending = Completer<Response<dynamic>>();
      when(
        () => network.request<dynamic>(requestPath, method: HttpMethod.put),
      ).thenAnswer((_) => pending.future);

      await showTab(tester);
      await openSheet(tester);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('ok'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(StartFuturePlanBottomSheet), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).first,
      );
      expect(button.onPressed, isNull);
      verify(
        () => network.request<dynamic>(requestPath, method: HttpMethod.put),
      ).called(1);

      pending.complete(
        Response<dynamic>(
          requestOptions: RequestOptions(path: requestPath),
          statusCode: 200,
        ),
      );
      await tester.pumpAndSettle();

      verify(() => plans.refreshCurrentTab()).called(1);
      expect(find.text('start plan'), findsOneWidget);
      verifyNoMoreInteractions(network);
      expect(tester.takeException(), isNull);
    });
  }

  for (final dismissal in ['arrow', 'barrier', 'system back', 'drag']) {
    testWidgets('$dismissal cancels without starting the plan', (tester) async {
      await showTab(tester);
      await openSheet(tester);

      switch (dismissal) {
        case 'arrow':
          await tester.tap(find.byTooltip('Back'));
        case 'barrier':
          await tester.tapAt(const Offset(10, 10));
        case 'system back':
          await tester.binding.handlePopRoute();
        case 'drag':
          await tester.drag(
            find.byType(StartFuturePlanBottomSheet),
            const Offset(0, 400),
          );
      }
      await tester.pumpAndSettle();

      expect(find.byType(StartFuturePlanBottomSheet), findsNothing);
      verifyZeroInteractions(network);
      verifyNever(() => plans.refreshCurrentTab());
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'start plan'),
      );
      expect(button.onPressed, isNotNull);
    });
  }

  testWidgets('repeated Start Plan taps open only one confirmation', (
    tester,
  ) async {
    await showTab(tester);
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'start plan'),
    );
    button.onPressed!();
    button.onPressed!();
    await tester.pumpAndSettle();

    expect(find.byType(StartFuturePlanBottomSheet), findsOneWidget);
    verifyZeroInteractions(network);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
  });

  testWidgets('postpaid users keep the existing absence of Start Plan', (
    tester,
  ) async {
    config.setUserType(UserType.postpaid);
    await showTab(tester);

    expect(find.text('Scheduled plan'), findsOneWidget);
    expect(find.text('start plan'), findsNothing);
    verifyZeroInteractions(network);
  });

  testWidgets('confirmation sheet fits a narrow screen with larger text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => StartFuturePlanBottomSheet.show(context),
              child: const Text('confirm'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('confirm'));
    await tester.pumpAndSettle();

    expect(find.text('ok').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    verifyZeroInteractions(network);
  });
}
