import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/auto_renew_actions.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _DeviceState extends Mock implements DeviceLimitsState {}

class _Device extends Mock implements DeviceLimitsModel {}

const _question = 'are you sure you want to turn off auto renew?';
const _success = 'auto renew has been turned off';
const _failure = 'Failed to disable auto-renew';

void main() {
  late _Devices devices;
  late _DeviceState deviceState;
  bool? result;

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
    devices = _Devices();
    deviceState = _DeviceState();
    result = null;
    final device = _Device();
    when(() => device.deviceId).thenReturn(4242);
    when(() => deviceState.deviceLimits).thenReturn(device);
    when(() => devices.state).thenReturn(deviceState);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
  });

  tearDown(() async {
    await devices.close();
    await instance.reset();
  });

  Future<void> attemptOff(WidgetTester tester, {bool succeeds = true}) async {
    when(() => devices.disableAutoRenew(any())).thenAnswer((_) async {
      return succeeds;
    });
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                // Same call the Home card makes when the toggle is ON.
                onPressed: () async => result = await handleAutoRenewToggle(
                  context,
                  currentValue: true,
                ),
                child: const Text('toggle'),
              ),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('toggle'));
    await tester.pumpAndSettle();
  }

  Future<void> settleToasts(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  testWidgets('AREN-010 shows the confirmation with ok and cancel', (
    tester,
  ) async {
    await attemptOff(tester);
    expect(find.text(_question), findsOneWidget);
    expect(find.text('ok'), findsOneWidget);
    expect(find.text('cancel'), findsOneWidget);
    expect(find.text('yes'), findsNothing);
    verifyNever(() => devices.disableAutoRenew(any()));
  });

  testWidgets('AREN-010 cancel dismisses only', (tester) async {
    await attemptOff(tester);
    await tester.tap(find.text('cancel'));
    await tester.pumpAndSettle();
    expect(find.text(_question), findsNothing);
    expect(find.text(_success), findsNothing);
    expect(result, isFalse);
    verifyNever(() => devices.disableAutoRenew(any()));
  });

  testWidgets('AREN-010 back arrow still dismisses without disabling', (
    tester,
  ) async {
    await attemptOff(tester);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text(_question), findsNothing);
    expect(result, isFalse);
    verifyNever(() => devices.disableAutoRenew(any()));
  });

  testWidgets('AREN-011 ok disables, then shows the success toast', (
    tester,
  ) async {
    await attemptOff(tester);
    expect(find.text(_success), findsNothing);
    await tester.tap(find.text('ok'));
    await tester.pump(const Duration(milliseconds: 500));
    verify(() => devices.disableAutoRenew(4242)).called(1);
    expect(find.text(_success), findsOneWidget);
    expect(find.text('your account will not auto renew'), findsNothing);
    expect(result, isTrue);
    await settleToasts(tester);
  });

  testWidgets('AREN-011 failed disable shows no success toast', (tester) async {
    await attemptOff(tester, succeeds: false);
    await tester.tap(find.text('ok'));
    await tester.pump(const Duration(milliseconds: 500));
    verify(() => devices.disableAutoRenew(4242)).called(1);
    expect(find.text(_success), findsNothing);
    expect(find.text(_failure), findsOneWidget);
    expect(result, isFalse);
    await settleToasts(tester);
  });
}
