import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/logOut/repository/logout_repository.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/model/logout_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/drawer.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Network extends Mock implements NetworkService {}

class _Auth extends Mock implements AuthManager {}

class _Logout extends Mock implements LogoutRepository {}

const _title = 'are you sure you want to logout?';
const _yes = 'yes, logout';
const _no = 'no';
const _welcome = 'welcome screen';

void main() {
  late _Network network;
  late _Auth auth;

  setUp(() {
    network = _Network();
    auth = _Auth();
    final account = _Account();
    when(() => account.state).thenReturn(const AccountInfoState());
    final devices = _Devices();
    when(() => devices.state).thenReturn(DeviceLimitsState.initial());
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<NetworkService>(network);
    instance.registerSingleton<AuthManager>(auth);
  });

  tearDown(() async {
    await instance.reset();
  });

  Future<void> pumpRouter(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(path: '/', builder: (_, _) => home),
        GoRoute(
          path: AppRoutes.welcome,
          builder: (_, _) => const Scaffold(body: Text(_welcome)),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  for (final userType in UserType.values) {
    group('${userType.label} menu logout', () {
      Future<void> openSheetFromDrawer(WidgetTester tester) async {
        final scaffoldKey = GlobalKey<ScaffoldState>();
        await pumpRouter(
          tester,
          BlocProvider<AppUiConfigCubit>(
            create: (_) => AppUiConfigCubit(
              initialConfig: HomeUiConfig(
                userType: userType,
                hasActivePlan: true,
                isFuturePlan: false,
              ),
            ),
            child: Scaffold(
              key: scaffoldKey,
              drawer: const AppMenuDrawer(),
              body: const Text('home'),
            ),
          ),
        );
        scaffoldKey.currentState!.openDrawer();
        await tester.pumpAndSettle();
        expect(find.text(_title), findsNothing);

        await tester.tap(find.text('logout'));
        await tester.pumpAndSettle();
      }

      testWidgets('tap shows the confirmation with exact copy first', (
        tester,
      ) async {
        await openSheetFromDrawer(tester);

        expect(find.byType(LogoutBottomSheet), findsOneWidget);
        expect(find.text(_title), findsOneWidget);
        expect(find.text(_yes), findsOneWidget);
        expect(find.text(_no), findsOneWidget);
        expect(find.text('Logout successful!'), findsNothing);
        verifyZeroInteractions(network);
        verifyZeroInteractions(auth);
      });

      testWidgets('no dismisses only; session and route are untouched', (
        tester,
      ) async {
        await openSheetFromDrawer(tester);

        await tester.tap(find.text(_no));
        await tester.pumpAndSettle();

        expect(find.byType(LogoutBottomSheet), findsNothing);
        expect(find.text('home'), findsOneWidget);
        expect(find.text(_welcome), findsNothing);
        verifyZeroInteractions(network);
        verifyZeroInteractions(auth);
      });
    });
  }

  group('LogoutBottomSheet confirm path', () {
    Future<void> pumpSheet(WidgetTester tester, LogoutRepository repo) async {
      await pumpRouter(
        tester,
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => LogoutBottomSheet(repository: repo),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('no never calls the logout action', (tester) async {
      final repo = _Logout();
      await pumpSheet(tester, repo);

      await tester.tap(find.text(_no));
      await tester.pumpAndSettle();

      verifyNever(
        () => repo.logout(logoutAllDevices: any(named: 'logoutAllDevices')),
      );
      expect(find.text('open'), findsOneWidget);
      expect(find.text(_welcome), findsNothing);
    });

    testWidgets('yes, logout runs the existing logout and goes to welcome', (
      tester,
    ) async {
      var localLogoutCalls = 0;
      when(() => auth.currentSession).thenReturn(null);
      final repo = LogoutRepository(
        networkService: network,
        authManager: auth,
        performLocalLogout: () async => localLogoutCalls++,
      );
      await pumpSheet(tester, repo);
      expect(localLogoutCalls, 0);

      await tester.tap(find.text(_yes));
      await tester.pumpAndSettle();

      expect(localLogoutCalls, 1);
      expect(find.text('Logout successful!'), findsOneWidget);
      expect(find.text(_welcome), findsOneWidget);
      expect(find.byType(LogoutBottomSheet), findsNothing);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('logout success waits for completion after welcome navigation',
        (
      tester,
    ) async {
      final completion = Completer<void>();
      when(() => auth.currentSession).thenReturn(null);
      final repo = LogoutRepository(
        networkService: network,
        authManager: auth,
        performLocalLogout: () async {
          GoRouter.of(rootNavigatorKey.currentContext!).go(AppRoutes.welcome);
          await completion.future;
        },
      );
      await pumpSheet(tester, repo);
      await tester.tap(find.text(_yes));
      await tester.pumpAndSettle();
      expect(find.text(_welcome), findsOneWidget);
      expect(find.text('Logout successful!'), findsNothing);
      completion.complete();
      await tester.pumpAndSettle();
      expect(find.text('Logout successful!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('failed logout keeps the existing error handling', (
      tester,
    ) async {
      final repo = _Logout();
      when(
        () => repo.logout(logoutAllDevices: any(named: 'logoutAllDevices')),
      ).thenAnswer((_) async => false);
      await pumpSheet(tester, repo);

      await tester.tap(find.text(_yes));
      await tester.pump();

      verify(() => repo.logout(logoutAllDevices: false)).called(1);
      expect(find.text('Logout failed. Please try again.'), findsOneWidget);
      expect(find.text('Logout successful!'), findsNothing);
      expect(find.text(_welcome), findsNothing);
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });
  });
}
