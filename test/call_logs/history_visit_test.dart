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
import 'package:myaliv_mobile_app/app/common/verification/protected_account_access_verification_session.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/history_route_observer.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/widgets/transaction_tile_new.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
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
    required int deviceAccountId,
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
    instance.registerSingleton<ProtectedAccountAccessVerificationSession>(
      session,
    );
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
      () => CallLogsCubit(repository: calls, deviceLimitsCubit: devices),
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
  DateTime now = DateTime.utc(2026, 10, 7);
  late final session = ProtectedAccountAccessVerificationSession(
    accountContext: () => 'test-account',
    now: () => now,
  );
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

  test('cold verification session starts unverified', () {
    final previous = ProtectedAccountAccessVerificationSession(
      accountContext: () => 'test-account',
    )..markVerified();
    expect(previous.isVerified, isTrue);
    expect(
      ProtectedAccountAccessVerificationSession(
        accountContext: () => 'test-account',
      ).isVerified,
      isFalse,
    );
  });

  historyTest(
    'active expired Transactions stays visible, tapping Call Logs requires OTP',
    (tester) async {
      final h = _Harness();
      await h.pump(tester);
      await h.authorize(tester, HistoryDestination.transactions);
      h.now = h.now.add(const Duration(minutes: 20));
      tester.element(find.byType(CallLogsScreen)).markNeedsBuild();
      await tester.pumpAndSettle();
      expect(find.byType(TransactionTileNew), findsWidgets);
      await tester.tap(find.text('call logs'));
      await tester.pumpAndSettle();
      // Session expired → tapping the Call Logs tab triggers a fresh challenge.
      expect(h.challenge.requests, 2);
      expect(find.byType(CallLogsOtpScreen), findsOneWidget);
    },
  );

  historyTest(
    'retained History return within window preserves data and expiry',
    (tester) async {
      final h = _Harness();
      await h.pump(tester);
      await h.authorize(tester, HistoryDestination.transactions);
      final expiry = h.session.expiresAt;
      h.router.push('/other');
      await tester.pumpAndSettle();
      h.now = h.now.add(const Duration(minutes: 19));
      h.router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(TransactionTileNew), findsWidgets);
      expect(find.byType(CallLogsOtpScreen), findsNothing);
      expect(h.challenge.requests, 1);
      expect(h.session.expiresAt, expiry);
    },
  );
}
