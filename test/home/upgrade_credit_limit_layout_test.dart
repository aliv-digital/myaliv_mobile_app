import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/view/widgets/limit_amount_input_field.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Balance extends MockCubit<BalanceState> implements BalanceCubit {}

class _Auth extends Mock implements AuthManager {}

class _Challenge extends Mock implements CallLogsVerificationRepository {}

void main() {
  setUpAll(() async {
    await (FontLoader(
      'CircularPro',
    )..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))).load();
  });

  for (final size in [const Size(320, 700), const Size(430, 932)]) {
    testWidgets('credit limit spacing and full-screen navigation at $size', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final devices = _Devices();
      final balance = _Balance();
      final config = AppUiConfigCubit();
      when(() => devices.state).thenReturn(
        DeviceLimitsState(
          status: DeviceLimitsStatus.loaded,
          allDeviceLimits: [
            DeviceLimitsModel.fromJson({
              'DeviceID': 123,
              'MaxAllowedLocalText': 30,
              'MaxAllowedLocalData': 30,
              'MaxAllowedLocalVoice': 30,
              'MaxAllowedRoaming': 150,
              'MaxAllowedInternational': 150,
            }),
          ],
        ),
      );
      when(() => devices.loadDeviceLimits()).thenAnswer((_) async {});
      when(() => balance.state).thenReturn(BalanceState.initial());
      instance.registerSingleton<DeviceLimitsCubit>(devices);
      instance.registerSingleton<AuthManager>(_Auth());
      instance.registerSingleton<CallLogsVerificationRepository>(_Challenge());

      final productionRouter = AppRouter().router;
      final shell = productionRouter.configuration.routes
          .whereType<ShellRoute>()
          .single;
      final creditLimitRoute = productionRouter.configuration.routes
          .whereType<GoRoute>()
          .singleWhere((route) => route.path == AppRoutes.upgradeCreditLimit);
      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: AppRoutes.usage,
        routes: [
          ShellRoute(
            builder: shell.builder,
            routes: [
              GoRoute(
                path: AppRoutes.usage,
                builder: (context, _) => Scaffold(
                  body: TextButton(
                    onPressed: () => context.push(AppRoutes.upgradeCreditLimit),
                    child: const Text('update credit limit'),
                  ),
                ),
              ),
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const Scaffold(body: Text('home')),
              ),
            ],
          ),
          creditLimitRoute,
        ],
      );
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox.shrink());
        router.dispose();
        productionRouter.dispose();
        await devices.close();
        await balance.close();
        await config.close();
        await instance.reset();
      });
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<BalanceCubit>.value(value: balance),
            BlocProvider.value(value: config),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      await tester.tap(find.text('update credit limit'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomNavigationBar), findsNothing);
      final fields = find.byType(LimitAmountInputField);
      expect(fields, findsNWidgets(5));
      for (var i = 0; i < 5; i++) {
        final field = fields.at(i);
        await tester.ensureVisible(field);
        await tester.pumpAndSettle();
        final symbol = find.descendant(of: field, matching: find.text(r'$'));
        final editable = find.descendant(
          of: field,
          matching: find.byType(EditableText),
        );
        expect(
          tester.getTopLeft(editable).dx - tester.getTopRight(symbol).dx,
          closeTo(16, 0.01),
        );
      }
      expect(tester.takeException(), isNull);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('update credit limit'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      await tester.tap(find.text('update credit limit'));
      await tester.pumpAndSettle();
      await tester.tap(
        find
            .descendant(
              of: find.byType(AppBar),
              matching: find.byType(GestureDetector),
            )
            .last,
      );
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, AppRoutes.home);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  }
}
