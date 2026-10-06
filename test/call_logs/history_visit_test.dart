import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/widgets/otp_code_fields.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/purchases/prepaid/view/purchase_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/profile/prepaid/view/profile_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/call_logs_screen.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/cubit/call_logs_cubit.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/cubit/transactions_cubit.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/models/usage_model.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/repository/call_logs_repository.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/repository/services/transactions_api_client.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/repository/transactions_repository.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_otp_route_args.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_otp_screen.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_gate_screen.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_session.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/history_route_observer.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/widgets/month_selector.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/widgets/transaction_tile_new.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/auth/hard_logout.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Network extends Mock implements NetworkService {}

class _Auth extends Mock implements AuthManager {}

class _Devices extends Mock implements DeviceLimitsCubit {}

class _Challenge extends CallLogsVerificationRepository {
  int requests = 0;
  Object? failure;
  Completer<CallLogsChallenge>? pending;

  @override
  Future<CallLogsChallenge> requestChallenge() async {
    requests++;
    if (failure != null) {
      throw failure!;
    }
    if (pending != null) {
      return pending!.future;
    }
    return CallLogsChallenge(
      mfaToken: 'test-mfa-$requests',
      apiPhoneNumber: '2425550100',
    );
  }
}

class _Calls extends CallLogsRepository {
  int requests = 0;

  @override
  Future<List<UsageModel>> fetchUsages({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    requests++;
    return [];
  }
}

class _TransactionApi extends TransactionsApiClient {
  int requests = 0;
  Object? failure;
  final dates = <DateTime>[];
  final accountIds = <int>[];

  @override
  Future<String> fetchTransactions({
    required DateTime startDate,
    required DateTime endDate,
    required int accountId,
  }) async {
    requests++;
    dates.add(startDate);
    accountIds.add(accountId);
    if (failure != null) {
      throw failure!;
    }
    return jsonEncode([
      {'Date': '2026-01-01T12:00:00Z', 'Type': 'older payment', 'Amount': 5},
      {'Date': '2026-01-02T12:00:00Z', 'Type': 'newer payment', 'Amount': 10},
    ]);
  }
}

class _Harness {
  _Harness({bool prepaid = true}) {
    instance.registerSingleton<NetworkService>(network);
    instance.registerSingleton<AuthManager>(auth);
    instance.registerSingleton<CallLogsVerificationSession>(session);
    challenge = _Challenge();
    calls = _Calls();
    transactionApi = _TransactionApi();
    instance.registerSingleton<CallLogsVerificationRepository>(challenge);
    when(() => devices.state).thenReturn(
      DeviceLimitsState(
        status: DeviceLimitsStatus.loaded,
        allDeviceLimits: [
          DeviceLimitsModel.fromJson({'DeviceID': 123}),
        ],
      ),
    );
    instance.registerFactory<CallLogsCubit>(
      () => CallLogsCubit(repository: calls),
    );
    instance.registerFactory<TransactionsCubit>(
      () => TransactionsCubit(
        repository: TransactionsRepository(apiClient: transactionApi),
        deviceLimitsCubit: devices,
      ),
    );
    uiConfig = AppUiConfigCubit(
      initialConfig: HomeUiConfig(
        userType: prepaid ? UserType.prepaid : UserType.postpaid,
        hasActivePlan: false,
        isFuturePlan: false,
      ),
    );
    when(() => auth.saveSession(any())).thenAnswer((invocation) async {
      saves++;
      savedSession = invocation.positionalArguments.first as TokenSession;
      if (saveFailure != null) {
        throw saveFailure!;
      }
      await pendingSave?.future;
    });
    when(() => auth.clearSession()).thenAnswer((_) async {});
    when(
      () => network.request<dynamic>(
        Api.verifyOtpUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((invocation) async {
      verifies++;
      verifyPayloads.add(invocation.namedArguments[#data] as Map);
      if (verifyFailure != null) {
        throw verifyFailure!;
      }
      return Response<dynamic>(
        requestOptions: RequestOptions(path: Api.verifyOtpUrl),
        data: {
          'access_token': 'test-updated-access',
          'refresh_token': 'test-updated-refresh',
          'expires_in': 3600,
          'refresh_expires_in': 86400,
        },
      );
    });
  }

  final network = _Network();
  final auth = _Auth();
  final devices = _Devices();
  final session = CallLogsVerificationSession();
  late final _Challenge challenge;
  late final _Calls calls;
  late final _TransactionApi transactionApi;
  late final AppUiConfigCubit uiConfig;
  late GoRouter router;
  CallLogsOtpRouteArgs? otpArgs;
  int saves = 0;
  int verifies = 0;
  TokenSession? savedSession;
  Completer<void>? pendingSave;
  Object? saveFailure;
  Object? verifyFailure;
  final verifyPayloads = <Map>[];

  Future<void> pump(
    WidgetTester tester, {
    String initial = '/outside',
    bool productionRouter = false,
  }) async {
    router = productionRouter
        ? AppRouter().router
        : GoRouter(
            navigatorKey: rootNavigatorKey,
            observers: [historyRouteObserver],
            initialLocation: initial,
            routes: [
              for (final path in ['/outside', AppRoutes.home, '/other'])
                GoRoute(
                  path: path,
                  builder: (_, _) => const Scaffold(body: Text('outside')),
                ),
              GoRoute(
                path: AppRoutes.purchasesPrepaidScreen,
                builder: (_, _) => const PurchasesPrepaidScreen(),
              ),
              GoRoute(
                path: AppRoutes.profilePrepaidScreen,
                builder: (_, _) => const ProfilePrepaidScreen(),
              ),
              GoRoute(
                path: AppRoutes.callLogs,
                builder: (_, state) {
                  final destination = HistoryDestination.fromTabParameter(
                    state.uri.queryParameters['tab'],
                  );
                  return session.isVerified
                      ? CallLogsScreen(
                          initialTab:
                              destination == HistoryDestination.transactions
                              ? CallLogsTabType.transactions
                              : CallLogsTabType.callLogs,
                        )
                      : CallLogsVerificationGateScreen(
                          destination: destination,
                        );
                },
              ),
              GoRoute(
                path: AppRoutes.callLogsOtp,
                builder: (_, state) {
                  otpArgs = state.extra! as CallLogsOtpRouteArgs;
                  return CallLogsOtpScreen(
                    initialMfaToken: otpArgs!.mfaToken,
                    apiPhoneNumber: otpArgs!.apiPhoneNumber,
                    destination: otpArgs!.destination,
                  );
                },
              ),
            ],
          );
    if (productionRouter) {
      router.go(initial);
    }
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 4));
      router.dispose();
      await uiConfig.close();
      await instance.reset();
    });
    await tester.pumpWidget(
      BlocProvider.value(
        value: uiConfig,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, HistoryDestination target) async {
    router.push(target.location);
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester, {int taps = 1}) async {
    final bloc = tester
        .element(find.byType(OtpCodeFields))
        .read<LoginOtpBloc>();
    bloc.add(const LoginOtpCodeChanged('123456'));
    await tester.pump();
    for (var i = 0; i < taps; i++) {
      await tester.tap(find.text('verify'));
    }
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  Future<void> authorize(WidgetTester tester, HistoryDestination target) async {
    await enter(tester, target);
    await submit(tester);
    await finish(tester);
    expect(session.isVerified, isTrue);
    expect(find.text('history'), findsOneWidget);
  }
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    registerFallbackValue(
      TokenSession(
        accessToken: 'test',
        refreshToken: 'test',
        accessExpiresAt: DateTime(2030),
        refreshExpiresAt: DateTime(2031),
      ),
    );
    registerFallbackValue(Options());
  });

  void historyTest(String description, WidgetTesterCallback body) {
    testWidgets(description, (tester) {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      return http.runWithClient(() async {
        try {
          await body(tester);
        } finally {
          await tester.pump(const Duration(seconds: 4));
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          debugDefaultTargetPlatformOverride = null;
        }
      }, () => MockClient((_) async => http.Response('', 200)));
    });
  }

  for (final prepaid in [true, false]) {
    historyTest(
      '${prepaid ? 'prepaid' : 'postpaid'} purchases verifies Transactions',
      (tester) async {
        final h = _Harness(prepaid: prepaid);
        await h.pump(tester, initial: AppRoutes.purchasesPrepaidScreen);
        await tester.tap(find.text('transaction history'));
        await tester.pumpAndSettle();
        expect(h.challenge.requests, 1);
        expect(h.otpArgs?.destination, HistoryDestination.transactions);
        expect(h.transactionApi.requests, 0);
        await h.submit(tester);
        await h.finish(tester);
        expect(h.saves, 1);
        expect(h.savedSession?.accessToken, 'test-updated-access');
        expect(h.savedSession?.refreshToken, 'test-updated-refresh');
        expect(
          GoRouterState.of(
            tester.element(find.byType(CallLogsScreen)),
          ).uri.toString(),
          HistoryDestination.transactions.location,
        );
        expect(h.session.isVerified, isTrue);
        expect(h.transactionApi.accountIds, everyElement(123));
        expect(find.byType(TransactionTileNew), findsNWidgets(2));
      },
    );
  }

  historyTest('active Profile verifies and preserves Call Logs destination', (
    tester,
  ) async {
    final h = _Harness();
    await h.pump(tester, initial: AppRoutes.profilePrepaidScreen);
    await tester.tap(find.text('call logs'));
    await tester.pumpAndSettle();
    expect(h.challenge.requests, 1);
    expect(h.otpArgs?.destination, HistoryDestination.callLogs);
    await h.submit(tester);
    await h.finish(tester);
    expect(h.saves, 1);
    expect(
      GoRouterState.of(
        tester.element(find.byType(CallLogsScreen)),
      ).uri.toString(),
      HistoryDestination.callLogs.location,
    );
    expect(find.text('No call logs found for this month'), findsOneWidget);
  });

  for (final location in [
    '/call_logs?tab=transactions',
    '/call_logs?tab=call_logs',
    '/call_logs',
    '/call_logs?tab=',
    '/call_logs?tab=unknown',
  ]) {
    historyTest('production router gates $location before any History fetch', (
      tester,
    ) async {
      final h = _Harness();
      await h.pump(tester, initial: location, productionRouter: true);
      expect(h.challenge.requests, 1);
      expect(find.byType(CallLogsOtpScreen), findsOneWidget);
      expect(h.calls.requests, 0);
      expect(h.transactionApi.requests, 0);
      final screen = tester.widget<CallLogsOtpScreen>(
        find.byType(CallLogsOtpScreen),
      );
      expect(
        screen.destination,
        HistoryDestination.fromTabParameter(
          Uri.parse(location).queryParameters['tab'],
        ),
      );
    });
  }

  historyTest('saving completes before History authorization and navigation', (
    tester,
  ) async {
    final h = _Harness()..pendingSave = Completer<void>();
    await h.pump(tester);
    await h.enter(tester, HistoryDestination.transactions);
    await h.submit(tester);
    expect(h.saves, 1);
    expect(h.session.isVerified, isFalse);
    expect(find.byType(CallLogsOtpScreen), findsOneWidget);
    expect(h.transactionApi.requests, 0);
    h.pendingSave!.complete();
    await tester.pump();
    await h.finish(tester);
    expect(h.session.isVerified, isTrue);
    expect(find.text('history'), findsOneWidget);
  });

  for (final failure in ['save', 'invalid OTP']) {
    historyTest('$failure failure does not authorize or open History', (
      tester,
    ) async {
      final h = _Harness();
      if (failure == 'save') {
        h.saveFailure = Exception('test persistence failure');
      } else {
        h.verifyFailure = Exception('Invalid OTP');
      }
      await h.pump(tester);
      await h.enter(tester, HistoryDestination.transactions);
      await h.submit(tester);
      await h.finish(tester);
      expect(h.session.isVerified, isFalse);
      expect(find.byType(CallLogsOtpScreen), findsOneWidget);
      expect(h.transactionApi.requests, 0);
    });
  }

  for (final message in ['Challenge failed', 'No internet']) {
    historyTest('$message blocks History entry', (tester) async {
      final h = _Harness()
        ..challenge.failure = CallLogsVerificationException(message);
      await h.pump(tester);
      await h.enter(tester, HistoryDestination.transactions);
      expect(h.session.isVerified, isFalse);
      expect(find.text('outside'), findsOneWidget);
      expect(h.transactionApi.requests, 0);
    });
  }

  historyTest('OTP resend rotates the MFA token used for verification', (
    tester,
  ) async {
    final h = _Harness();
    await h.pump(tester);
    await h.enter(tester, HistoryDestination.transactions);
    await tester.tap(find.text('resend code'));
    await tester.pumpAndSettle();
    await h.submit(tester);
    await h.finish(tester);
    expect(h.challenge.requests, 2);
    expect(h.verifyPayloads.single['mfa_token'], 'test-mfa-2');
  });

  historyTest('rapid external requests only challenge the visible gate', (
    tester,
  ) async {
    final h = _Harness()..challenge.pending = Completer<CallLogsChallenge>();
    await h.pump(tester);
    h.router.push(HistoryDestination.transactions.location);
    h.router.push(HistoryDestination.transactions.location);
    h.router.push(HistoryDestination.transactions.location);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(h.challenge.requests, 1);
    h.challenge.pending!.complete(
      const CallLogsChallenge(
        mfaToken: 'test-mfa',
        apiPhoneNumber: '2425550100',
      ),
    );
    await tester.pumpAndSettle();
  });

  historyTest('rapid Verify taps submit and save exactly once', (tester) async {
    final h = _Harness()..pendingSave = Completer<void>();
    await h.pump(tester);
    await h.enter(tester, HistoryDestination.transactions);
    await h.submit(tester, taps: 4);
    expect(h.verifies, 1);
    expect(h.saves, 1);
    h.pendingSave!.complete();
    await tester.pump();
    await h.finish(tester);
  });

  for (final target in HistoryDestination.values) {
    historyTest('tabs and swipes stay in the authorized ${target.name} visit', (
      tester,
    ) async {
      final h = _Harness();
      await h.pump(tester);
      await h.authorize(tester, target);
      for (var i = 0; i < 2; i++) {
        await tester.tap(find.text('call logs'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('transactions'));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(TabBarView), const Offset(-500, 0));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(TabBarView), const Offset(500, 0));
        await tester.pumpAndSettle();
      }
      expect(h.session.isVerified, isTrue);
      expect(h.challenge.requests, 1);
      expect(h.verifies, 1);
    });
  }

  historyTest(
    'month popup, filtering, sorting and rebuild keep authorization',
    (tester) async {
      final h = _Harness();
      await h.pump(tester);
      await h.authorize(tester, HistoryDestination.transactions);
      final tiles = tester
          .widgetList<TransactionTileNew>(find.byType(TransactionTileNew))
          .toList();
      expect(tiles.map((tile) => tile.transaction.type), [
        'newer payment',
        'older payment',
      ]);
      final previousFetches = h.transactionApi.requests;
      await tester.tap(find.byType(MonthSelector));
      await tester.pumpAndSettle();
      expect(h.session.isVerified, isTrue);
      await tester.tap(find.byType(ListTile).at(1));
      await tester.pumpAndSettle();
      expect(h.transactionApi.requests, greaterThan(previousFetches));
      final expectedMonth = DateTime(
        DateTime.now().year,
        DateTime.now().month - 1,
        1,
      );
      expect(h.transactionApi.dates.last, expectedMonth);
      tester.element(find.byType(CallLogsScreen)).markNeedsBuild();
      await tester.pumpAndSettle();
      expect(h.session.isVerified, isTrue);
      expect(h.challenge.requests, 1);
    },
  );

  historyTest('Retry retains verification and transaction behavior', (
    tester,
  ) async {
    final h = _Harness()
      ..transactionApi.failure = Exception('test transaction error');
    await h.pump(tester);
    await h.authorize(tester, HistoryDestination.transactions);
    expect(find.text('Retry'), findsOneWidget);
    h.transactionApi.failure = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionTileNew), findsNWidgets(2));
    expect(h.session.isVerified, isTrue);
    expect(h.challenge.requests, 1);
  });

  for (final exit in [
    'back',
    'system back',
    'home',
    'go',
    'replacement',
    'removal',
  ]) {
    historyTest('$exit ends the visit and next entry requires OTP', (
      tester,
    ) async {
      final h = _Harness();
      await h.pump(tester);
      await h.authorize(tester, HistoryDestination.transactions);
      switch (exit) {
        case 'back':
          await tester.tap(find.byIcon(Icons.arrow_back));
        case 'system back':
          await tester.binding.handlePopRoute();
        case 'home':
          await tester.tap(find.text('back to home page'));
        case 'go':
          h.router.go('/other');
        case 'replacement':
          h.router.pushReplacement('/other');
        case 'removal':
          rootNavigatorKey.currentState!.removeRoute(
            ModalRoute.of(tester.element(find.byType(CallLogsScreen)))!,
          );
      }
      await tester.pumpAndSettle();
      expect(h.session.isVerified, isFalse);
      await h.enter(tester, HistoryDestination.callLogs);
      expect(h.challenge.requests, 2);
      expect(find.byType(CallLogsOtpScreen), findsOneWidget);
    });
  }

  historyTest(
    'pushed outside page ends visit; return and cancel cannot expose old data',
    (tester) async {
      final h = _Harness();
      await h.pump(tester);
      await h.authorize(tester, HistoryDestination.transactions);
      h.router.push('/other');
      await tester.pumpAndSettle();
      expect(h.session.isVerified, isFalse);
      expect(h.challenge.requests, 1);
      h.router.pop();
      await tester.pumpAndSettle();
      expect(h.challenge.requests, 2);
      expect(find.byType(CallLogsOtpScreen), findsOneWidget);
      expect(find.byType(TransactionTileNew), findsNothing);
      h.router.pop();
      await tester.pumpAndSettle();
      expect(h.session.isVerified, isFalse);
      expect(find.byType(TransactionTileNew), findsNothing);
    },
  );

  historyTest('hard logout resets the current History visit', (tester) async {
    final h = _Harness();
    await h.pump(tester);
    await h.authorize(tester, HistoryDestination.transactions);
    // Logout still navigates to welcome; errors from intentionally absent
    // unrelated singleton caches are handled by the existing logout service.
    await performHardLogout();
    await tester.pumpAndSettle();
    expect(h.session.isVerified, isFalse);
    verify(() => h.auth.clearSession()).called(1);
  });

  for (final target in HistoryDestination.values) {
    historyTest('production router completes OTP into ${target.name}', (
      tester,
    ) async {
      final h = _Harness();
      await h.pump(tester, initial: target.location, productionRouter: true);
      await h.submit(tester);
      await h.finish(tester);
      expect(h.session.isVerified, isTrue);
      expect(
        GoRouterState.of(
          tester.element(find.byType(CallLogsScreen)),
        ).uri.toString(),
        target.location,
      );
    });
  }

  for (final legacy in [
    '/enter-password?continue=call_logs',
    '/verification-code?next=call_logs',
  ]) {
    historyTest('legacy $legacy cannot bypass real OTP', (tester) async {
      final h = _Harness();
      await h.pump(tester, initial: legacy, productionRouter: true);
      await tester.tap(
        find.text(legacy.startsWith('/enter-password') ? 'Continue' : 'verify'),
      );
      await tester.pumpAndSettle();
      expect(h.challenge.requests, 1);
      expect(find.byType(CallLogsOtpScreen), findsOneWidget);
      expect(h.calls.requests, 0);
      expect(h.transactionApi.requests, 0);
    });
  }

  historyTest('offline OTP verification does not save or authorize History', (
    tester,
  ) async {
    await http.runWithClient(() async {
      final h = _Harness();
      await h.pump(tester);
      await h.enter(tester, HistoryDestination.transactions);
      await h.submit(tester);
      await h.finish(tester);
      expect(h.verifies, 0);
      expect(h.saves, 0);
      expect(h.session.isVerified, isFalse);
      expect(find.byType(CallLogsOtpScreen), findsOneWidget);
    }, () => MockClient((_) async => http.Response('', 500)));
  });

  historyTest('dialog and dismissed month picker retain the History visit', (
    tester,
  ) async {
    final h = _Harness();
    await h.pump(tester);
    await h.authorize(tester, HistoryDestination.transactions);
    await tester.tap(find.byType(MonthSelector));
    await tester.pumpAndSettle();
    h.router.pop();
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(CallLogsScreen));
    showDialog<void>(
      context: context,
      builder: (_) => const AlertDialog(title: Text('internal dialog')),
    );
    await tester.pumpAndSettle();
    h.router.pop();
    await tester.pumpAndSettle();
    expect(h.session.isVerified, isTrue);
    expect(h.challenge.requests, 1);
  });

  for (final complete in [false, true]) {
    historyTest(
      'iOS interactive Back ${complete ? 'completion ends' : 'cancellation retains'} visit',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        final h = _Harness();
        await h.pump(tester);
        await h.authorize(tester, HistoryDestination.transactions);
        final gesture = await tester.startGesture(const Offset(1, 500));
        await gesture.moveBy(const Offset(40, 0));
        await tester.pump();
        await gesture.moveBy(Offset(complete ? 650 : 40, 0));
        await tester.pump(const Duration(milliseconds: 100));
        expect(rootNavigatorKey.currentState!.userGestureInProgress, isTrue);
        if (complete) {
          await gesture.up();
        } else {
          await gesture.cancel();
        }
        await tester.pumpAndSettle();
        expect(h.session.isVerified, !complete);
        expect(find.text('history'), complete ? findsNothing : findsOneWidget);
      },
    );
  }

  historyTest(
    'old retained History cleanup does not reset newer OTP authorization',
    (tester) async {
      final h = _Harness();
      await h.pump(tester);
      await h.authorize(tester, HistoryDestination.transactions);
      final oldRoute =
          ModalRoute.of(tester.element(find.byType(CallLogsScreen)))!
              as PageRoute<dynamic>;
      h.router.push('/other');
      await tester.pumpAndSettle();
      await h.authorize(tester, HistoryDestination.callLogs);
      rootNavigatorKey.currentState!.removeRoute(oldRoute);
      await tester.pumpAndSettle();
      historyRouteObserver.endVisit(oldRoute);
      expect(h.session.isVerified, isTrue);
      expect(find.text('history'), findsOneWidget);
      expect(h.challenge.requests, 2);
    },
  );

  historyTest(
    'covered pending challenge cannot navigate away from outside page',
    (tester) async {
      final h = _Harness()..challenge.pending = Completer<CallLogsChallenge>();
      await h.pump(tester);
      h.router.push(HistoryDestination.transactions.location);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(h.challenge.requests, 1);
      h.router.push('/other');
      await tester.pumpAndSettle();
      h.challenge.pending!.complete(
        const CallLogsChallenge(
          mfaToken: 'test-stale',
          apiPhoneNumber: '2425550100',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('outside'), findsOneWidget);
      expect(find.byType(CallLogsOtpScreen), findsNothing);
      expect(h.session.isVerified, isFalse);
    },
  );

  test('cold verification session starts unverified', () {
    final previous = CallLogsVerificationSession()..markVerified();
    expect(previous.isVerified, isTrue);
    expect(CallLogsVerificationSession().isVerified, isFalse);
  });

  test('observer ignores popups and a cancelled interactive Back', () {
    final observer = HistoryRouteObserver();
    final history = MaterialPageRoute<void>(builder: (_) => const SizedBox());
    var ends = 0;
    observer.watchVisit(history, () => ends++);
    final popup = _Popup();
    observer.didPush(popup, history);
    observer.didPop(popup, history);
    observer.didStartUserGesture(history, null);
    observer.didStopUserGesture();
    expect(ends, 0);
    observer.didPop(history, null);
    expect(ends, 1);
  });

  test('stale removal/disposal cannot end a newer History visit', () {
    final observer = HistoryRouteObserver();
    final old = MaterialPageRoute<void>(builder: (_) => const SizedBox());
    final outside = MaterialPageRoute<void>(builder: (_) => const SizedBox());
    final current = MaterialPageRoute<void>(builder: (_) => const SizedBox());
    var oldEnds = 0;
    var currentEnds = 0;
    observer.watchVisit(old, () => oldEnds++);
    observer.didPush(outside, old);
    observer.watchVisit(current, () => currentEnds++);
    observer.didRemove(old, null);
    observer.endVisit(old);
    expect(oldEnds, 1);
    expect(currentEnds, 0);
    observer.didReplace(oldRoute: current, newRoute: outside);
    expect(currentEnds, 1);
  });
}

class _Popup extends PopupRoute<void> {
  @override
  Color? get barrierColor => null;
  @override
  bool get barrierDismissible => true;
  @override
  String? get barrierLabel => 'test popup';
  @override
  Duration get transitionDuration => Duration.zero;
  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) => const SizedBox();
}
