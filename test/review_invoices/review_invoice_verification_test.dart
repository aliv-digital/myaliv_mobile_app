import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/widgets/otp_code_fields.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/review_invoice_injection.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/cubit/review_invoice_postpaid_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/repository/review_invoice_postpaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/repository/services/invoice_api_client.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/repository/services/invoice_pdf_service.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/view/review_invoice_postpaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/reviewInvoice/postpaid/widgets/invoice_tile.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/verification/review_invoice_challenge_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/verification/review_invoice_otp_route_args.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/verification/review_invoice_otp_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/verification/review_invoice_route_observer.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/verification/review_invoice_verification_gate_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/verification/review_invoice_verification_repository.dart';
import 'package:myaliv_mobile_app/app/common/verification/protected_account_access_verification_session.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/reviewInvoices/verification/review_invoice_visit_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/purchases/prepaid/view/purchase_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_otp_route_args.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_otp_screen.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_gate_screen.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/history_route_observer.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/auth/hard_logout.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/router/app_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class _Network extends Mock implements NetworkService {}

class _Auth extends Mock implements AuthManager {}

class _Pdf extends Mock implements InvoicePdfService {}

class _Internet extends InternetConnection {
  _Internet(this.online) : super.createInstance();
  bool online;
  @override
  Future<bool> get hasInternetAccess async => online;
}

class _InvoiceApi extends InvoiceApiClient {
  int loads = 0;
  int downloads = 0;
  Object? failure;
  bool empty = false;
  @override
  Future<String> fetchInvoices() async {
    loads++;
    if (failure != null) throw failure!;
    return jsonEncode(
      empty
          ? []
          : [
              {
                'InvoiceID': 1,
                'InvoiceString': 'older',
                'InvoiceDate': '2026-01-01',
                'InvoiceDueDate': '2026-01-15',
                'InvoicePath': 'older.pdf',
                'InvoiceAmount': 5,
              },
              {
                'InvoiceID': 2,
                'InvoiceString': 'newer',
                'InvoiceDate': '2026-02-01',
                'InvoiceDueDate': '2026-02-15',
                'InvoicePath': 'newer.pdf',
                'Files': ['primary.pdf'],
                'InvoiceAmount': 10,
              },
            ],
    );
  }

  @override
  Future<String> fetchInvoicePdf({
    required int invoiceId,
    required String filename,
  }) async {
    downloads++;
    return base64Encode(utf8.encode('synthetic pdf'));
  }
}

class _Harness {
  _Harness({bool prepaid = false}) {
    instance.registerSingleton<NetworkService>(network);
    instance.registerSingleton<AuthManager>(auth);
    instance.registerSingleton<ProtectedAccountAccessVerificationSession>(
      session,
    );
    when(() => auth.currentSession).thenReturn(_token());
    when(
      () => auth.refreshIfNeeded(),
    ).thenAnswer((_) async => _token(access: 'fresh-access'));
    when(() => auth.clearSession()).thenAnswer((_) async {});
    when(() => auth.saveSession(any())).thenAnswer((invocation) async {
      saves++;
      savedSession = invocation.positionalArguments.first as TokenSession;
      if (saveFailure != null) throw saveFailure!;
      await pendingSave?.future;
      saveCompleted = true;
    });
    when(
      () => network.request<dynamic>(
        Api.challengeOtpUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
      ),
    ).thenAnswer((invocation) async {
      challenges++;
      challengePayloads.add(invocation.namedArguments[#data] as Map);
      if (challengeFailure != null) throw challengeFailure!;
      if (pendingChallenge != null) return pendingChallenge!.future;
      return _challengeResponse('test-mfa-$challenges');
    });
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
      if (verifyFailure != null) throw verifyFailure!;
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
    repository = ReviewInvoiceVerificationRepository(
      networkService: network,
      authManager: auth,
      internetConnection: internet,
      phoneNumberProvider: () async => '2425550100',
    );
    instance.registerSingleton<ReviewInvoiceVerificationRepository>(repository);
    instance.registerSingleton<CallLogsVerificationRepository>(
      CallLogsVerificationRepository(
        networkService: network,
        authManager: auth,
        internetConnection: internet,
        phoneNumberProvider: () async => '2425550100',
      ),
    );
    instance.registerFactory<ReviewInvoiceChallengeCubit>(
      () => ReviewInvoiceChallengeCubit(repository: repository),
    );
    api = _InvoiceApi();
    when(() => pdf.isCached(any())).thenAnswer((_) async => cached);
    when(
      () => pdf.getCachePath(any()),
    ).thenAnswer((_) async => '/tmp/synthetic-invoice.pdf');
    when(() => pdf.decodeAndSavePdf(any(), any())).thenAnswer((_) async {
      cached = true;
      return '/tmp/synthetic-invoice.pdf';
    });
    when(() => pdf.openPdf(any())).thenAnswer((_) async => true);
    when(() => pdf.sharePdf(any(), any())).thenAnswer((_) async {});
    when(
      () => pdf.savePdfToDownloads(any(), any()),
    ).thenAnswer((_) async => true);
    instance.registerFactory<ReviewInvoicePostpaidCubit>(() {
      constructions++;
      expect(session.isVerified, isTrue);
      expect(saveCompleted || saves == 0, isTrue);
      return ReviewInvoicePostpaidCubit(
        repository: ReviewInvoicePostpaidRepositoryImpl(
          apiClient: api,
          pdfService: pdf,
        ),
        pdfService: pdf,
      );
    });
    uiConfig = AppUiConfigCubit(
      initialConfig: HomeUiConfig(
        userType: prepaid ? UserType.prepaid : UserType.postpaid,
        hasActivePlan: false,
        isFuturePlan: false,
      ),
    );
  }
  final network = _Network();
  final auth = _Auth();
  final pdf = _Pdf();
  final internet = _Internet(true);
  DateTime now = DateTime.utc(2026, 10, 7);
  late final session = ProtectedAccountAccessVerificationSession(
    accountContext: () => 'test-account',
    now: () => now,
  );
  ProtectedAccountAccessVerificationSession get history => session;
  late final ReviewInvoiceVerificationRepository repository;
  late final _InvoiceApi api;
  late final AppUiConfigCubit uiConfig;
  late GoRouter router;
  int challenges = 0;
  int verifies = 0;
  int saves = 0;
  int constructions = 0;
  bool saveCompleted = false;
  bool cached = false;
  TokenSession? savedSession;
  Object? challengeFailure;
  Object? verifyFailure;
  Object? saveFailure;
  Completer<Response<dynamic>>? pendingChallenge;
  Completer<void>? pendingSave;
  final challengePayloads = <Map>[];
  final verifyPayloads = <Map>[];

  Future<void> pump(
    WidgetTester tester, {
    String initial = '/outside',
    bool production = false,
  }) async {
    router = production
        ? AppRouter().router
        : GoRouter(
            navigatorKey: rootNavigatorKey,
            observers: [historyRouteObserver, reviewInvoiceRouteObserver],
            initialLocation: initial,
            routes: [
              for (final path in [
                '/outside',
                '/other',
                AppRoutes.home,
                AppRoutes.welcome,
              ])
                GoRoute(
                  path: path,
                  builder: (_, _) => const Scaffold(body: Text('outside')),
                ),
              GoRoute(
                path: AppRoutes.purchasesPrepaidScreen,
                builder: (_, _) => const PurchasesPrepaidScreen(),
              ),
              GoRoute(
                path: AppRoutes.reviewInvoicePostPaidScreen,
                builder: (_, _) => const ReviewInvoiceVisitScreen(),
              ),
              GoRoute(
                path: AppRoutes.reviewInvoiceOtp,
                builder: (_, state) {
                  final args = state.extra;
                  if (args is! ReviewInvoiceOtpRouteArgs || !args.isValid) {
                    return const ReviewInvoiceVerificationGateScreen();
                  }
                  return ReviewInvoiceOtpScreen(
                    initialMfaToken: args.mfaToken,
                    apiPhoneNumber: args.apiPhoneNumber,
                  );
                },
              ),
              GoRoute(
                path: AppRoutes.callLogs,
                builder: (_, _) => session.isVerified
                    ? const Scaffold(body: Text('verified History'))
                    : const CallLogsVerificationGateScreen(
                        destination: HistoryDestination.transactions,
                      ),
              ),
              GoRoute(
                path: AppRoutes.callLogsOtp,
                builder: (_, state) {
                  final args = state.extra! as CallLogsOtpRouteArgs;
                  return CallLogsOtpScreen(
                    initialMfaToken: args.mfaToken,
                    apiPhoneNumber: args.apiPhoneNumber,
                    destination: args.destination,
                  );
                },
              ),
            ],
          );
    if (production) router.go(initial);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 4));
      router.dispose();
      await uiConfig.close();
      session.dispose();
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

  Future<void> enter(WidgetTester tester) async {
    router.push(AppRoutes.reviewInvoicePostPaidScreen);
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester, {int taps = 1}) async {
    tester
        .element(find.byType(OtpCodeFields))
        .read<LoginOtpBloc>()
        .add(const LoginOtpCodeChanged('123456'));
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

  Future<void> authorize(WidgetTester tester) async {
    await enter(tester);
    await submit(tester);
    await finish(tester);
    expect(session.isVerified, isTrue);
    expect(find.byType(ReviewInvoicePostpaidScreen), findsOneWidget);
  }
}

TokenSession _token({String access = 'current-access', bool expired = false}) =>
    TokenSession(
      accessToken: access,
      refreshToken: 'test-refresh',
      accessExpiresAt: DateTime.now().add(Duration(minutes: expired ? -5 : 60)),
      refreshExpiresAt: DateTime.now().add(const Duration(days: 1)),
    );
Response<dynamic> _challengeResponse(String mfa) => Response<dynamic>(
  requestOptions: RequestOptions(path: Api.challengeOtpUrl),
  data: {'mfa_token': mfa},
);

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
    registerFallbackValue(_token());
    registerFallbackValue(Options());
  });
  void invoiceTest(String description, WidgetTesterCallback body) {
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

  invoiceTest(
    'postpaid Purchases verifies, saves both tokens, then loads sorted invoices',
    (tester) async {
      final h = _Harness();
      await h.pump(
        tester,
        initial: AppRoutes.purchasesPrepaidScreen,
        production: true,
      );
      await tester.tap(find.text('review invoices'));
      await tester.pumpAndSettle();
      expect(h.challenges, 1);
      expect(h.constructions, 0);
      expect(h.api.loads, 0);
      expect(find.byType(ReviewInvoiceOtpScreen), findsOneWidget);
      await h.submit(tester);
      await h.finish(tester);
      expect(h.savedSession?.accessToken, 'test-updated-access');
      expect(h.savedSession?.refreshToken, 'test-updated-refresh');
      expect(h.saves, 1);
      expect(h.constructions, 1);
      expect(h.api.loads, 1);
      expect(h.history.isVerified, isTrue);
      expect(
        GoRouterState.of(
          tester.element(find.byType(ReviewInvoiceVisitScreen)),
        ).uri.path,
        AppRoutes.reviewInvoicePostPaidScreen,
      );
      expect(
        tester
            .widgetList<InvoiceTile>(find.byType(InvoiceTile))
            .map((tile) => tile.invoice.invoiceId),
        [2, 1],
      );
      expect(h.verifyPayloads.single['PhoneNumber'], '2425550100');
      expect(h.verifyPayloads.single['mfa_token'], 'test-mfa-1');
    },
  );

  invoiceTest('prepaid menu still has no Review Invoices entry', (
    tester,
  ) async {
    final h = _Harness(prepaid: true);
    await h.pump(tester, initial: AppRoutes.purchasesPrepaidScreen);
    expect(find.text('review invoices'), findsNothing);
    expect(h.challenges, 0);
  });

  for (final path in [
    AppRoutes.reviewInvoicePostPaidScreen,
    AppRoutes.otpReviewInvoicePostPaidScreen,
    AppRoutes.enterPasswordReviewInvoicePostpaidScreen,
    AppRoutes.reviewInvoiceOtp,
  ]) {
    invoiceTest(
      'production route $path requires real OTP and preserves invoice destination',
      (tester) async {
        final h = _Harness();
        await h.pump(tester, initial: path, production: true);
        expect(h.challenges, 1);
        expect(h.api.loads, 0);
        expect(find.byType(ReviewInvoiceOtpScreen), findsOneWidget);
        await h.submit(tester);
        await h.finish(tester);
        expect(h.session.isVerified, isTrue);
        expect(
          h.router.routeInformationProvider.value.uri.path,
          AppRoutes.reviewInvoicePostPaidScreen,
        );
        expect(h.api.loads, 1);
      },
    );
  }

  invoiceTest(
    'saveSession must finish before authorization, screen construction or loading',
    (tester) async {
      final h = _Harness()..pendingSave = Completer<void>();
      await h.pump(tester);
      await h.enter(tester);
      await h.submit(tester);
      expect(h.saves, 1);
      expect(h.session.isVerified, isFalse);
      expect(h.constructions, 0);
      expect(h.api.loads, 0);
      h.pendingSave!.complete();
      await tester.pump();
      await h.finish(tester);
      expect(h.session.isVerified, isTrue);
      expect(h.constructions, 1);
    },
  );

  for (final failure in ['save', 'verify']) {
    invoiceTest('$failure failure blocks invoice authorization and loading', (
      tester,
    ) async {
      final h = _Harness();
      if (failure == 'save') h.saveFailure = Exception('storage failed');
      if (failure == 'verify') h.verifyFailure = Exception('Invalid OTP');
      await h.pump(tester);
      await h.enter(tester);
      await h.submit(tester);
      await h.finish(tester);
      expect(h.session.isVerified, isFalse);
      expect(h.api.loads, 0);
      expect(h.constructions, 0);
      expect(find.byType(ReviewInvoiceOtpScreen), findsOneWidget);
      expect(h.saves, failure == 'save' ? 1 : 0);
    });
  }

  for (final offline in [false, true]) {
    invoiceTest(
      '${offline ? 'offline' : 'failed'} Challenge blocks invoice entry',
      (tester) async {
        final h = _Harness();
        if (offline) {
          h.internet.online = false;
        } else {
          h.challengeFailure = Exception('Challenge failed');
        }
        await h.pump(tester);
        await h.enter(tester);
        expect(h.session.isVerified, isFalse);
        expect(h.api.loads, 0);
        expect(find.text('outside'), findsOneWidget);
        expect(h.challenges, offline ? 0 : 1);
      },
    );
  }

  invoiceTest('expired access token is refreshed before invoice Challenge', (
    tester,
  ) async {
    final h = _Harness();
    when(() => h.auth.currentSession).thenReturn(_token(expired: true));
    await h.pump(tester);
    await h.enter(tester);
    expect(h.challengePayloads.single['access_token'], 'fresh-access');
    verify(h.auth.refreshIfNeeded).called(1);
  });

  invoiceTest('offline OTP makes no verification or session save request', (
    tester,
  ) async {
    final h = _Harness();
    await http.runWithClient(() async {
      await h.pump(tester);
      await h.enter(tester);
      await h.submit(tester);
      await h.finish(tester);
    }, () => MockClient((_) async => http.Response('', 500)));
    expect(h.verifies, 0);
    expect(h.saves, 0);
    expect(h.session.isVerified, isFalse);
    expect(find.byType(ReviewInvoiceOtpScreen), findsOneWidget);
  });

  invoiceTest('resend requests Challenge and verifies with replacement MFA', (
    tester,
  ) async {
    final h = _Harness();
    await h.pump(tester);
    await h.enter(tester);
    await tester.tap(find.text('resend code'));
    await tester.pumpAndSettle();
    await h.submit(tester);
    await h.finish(tester);
    expect(h.challenges, 2);
    expect(h.verifyPayloads.single['mfa_token'], 'test-mfa-2');
  });

  invoiceTest(
    'concurrent and staggered rapid entries share one pending Challenge',
    (tester) async {
      final h = _Harness()..pendingChallenge = Completer<Response<dynamic>>();
      await h.pump(tester);
      h.router.push(AppRoutes.reviewInvoicePostPaidScreen);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(h.challenges, 1);
      h.router.push(AppRoutes.reviewInvoicePostPaidScreen);
      h.router.push(AppRoutes.reviewInvoicePostPaidScreen);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(h.challenges, 1);
      h.pendingChallenge!.complete(_challengeResponse('test-pending-mfa'));
      await tester.pumpAndSettle();
      expect(find.byType(ReviewInvoiceOtpScreen), findsOneWidget);
      expect(h.constructions, 0);
    },
  );

  invoiceTest('rapid Verify taps submit and save exactly once', (tester) async {
    final h = _Harness()..pendingSave = Completer<void>();
    await h.pump(tester);
    await h.enter(tester);
    await h.submit(tester, taps: 4);
    expect(h.verifies, 1);
    expect(h.saves, 1);
    h.pendingSave!.complete();
    await tester.pump();
    await h.finish(tester);
  });

  invoiceTest('History verification unlocks invoices within the fixed window', (
    tester,
  ) async {
    final h = _Harness()..history.markVerified();
    await h.pump(tester);
    await h.enter(tester);
    expect(find.byType(ReviewInvoiceOtpScreen), findsNothing);
    expect(h.challenges, 0);
    expect(h.api.loads, 1);
  });

  invoiceTest('Invoice verification unlocks History', (tester) async {
    final h = _Harness();
    await h.pump(tester);
    await h.authorize(tester);
    h.router.push(HistoryDestination.transactions.location);
    await tester.pumpAndSettle();
    expect(h.history.isVerified, isTrue);
    expect(find.byType(CallLogsOtpScreen), findsNothing);
    expect(h.challenges, 1);
  });

  invoiceTest(
    'Retry, scroll, rebuild, and PDF actions retain the verified visit',
    (tester) async {
      final h = _Harness()..api.failure = Exception('test invoice load error');
      await h.pump(tester);
      await h.authorize(tester);
      expect(find.text('Retry'), findsOneWidget);
      h.api.failure = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(h.api.loads, 2);
      final context = tester.element(find.byType(InvoiceTile).first);
      final cubit = context.read<ReviewInvoicePostpaidCubit>();
      final invoice = cubit.state.invoices.first;
      await tester.tap(find.byType(InvoiceTile).first);
      await tester.pumpAndSettle();
      expect(h.api.downloads, 1);
      await tester.tap(find.byType(InvoiceTile).first);
      await tester.pumpAndSettle();
      expect(h.api.downloads, 1); // second open is cached
      await cubit.sharePdf(invoice);
      await cubit.savePdfToDownloads(invoice);
      verify(() => h.pdf.openPdf('/tmp/synthetic-invoice.pdf')).called(2);
      verify(
        () => h.pdf.sharePdf('/tmp/synthetic-invoice.pdf', 'newer'),
      ).called(1);
      verify(
        () => h.pdf.savePdfToDownloads('/tmp/synthetic-invoice.pdf', 'newer'),
      ).called(1);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -100));
      tester.element(find.byType(ReviewInvoiceVisitScreen)).markNeedsBuild();
      await tester.pumpAndSettle();
      expect(h.session.isVerified, isTrue);
      expect(h.challenges, 1);
      expect(h.constructions, 1);
    },
  );

  invoiceTest('empty invoices retain original empty state after verification', (
    tester,
  ) async {
    final h = _Harness()..api.empty = true;
    await h.pump(tester);
    await h.authorize(tester);
    expect(find.text('No invoices found'), findsOneWidget);
    expect(h.session.isVerified, isTrue);
  });

  for (final exit in [
    'back',
    'system back',
    'home',
    'replacement',
    'removal',
  ]) {
    invoiceTest('$exit retains shared access; next entry needs no OTP', (
      tester,
    ) async {
      final h = _Harness();
      await h.pump(tester);
      await h.authorize(tester);
      switch (exit) {
        case 'back':
          await tester.tap(find.byType(InkResponse).first);
        case 'system back':
          await tester.binding.handlePopRoute();
        case 'home':
          h.router.go(AppRoutes.home);
        case 'replacement':
          h.router.pushReplacement('/other');
        case 'removal':
          rootNavigatorKey.currentState!.removeRoute(
            ModalRoute.of(
              tester.element(find.byType(ReviewInvoiceVisitScreen)),
            )!,
          );
          // Keep GoRouter's declarative page list in sync with native removal
          // instead of resurrecting the removed page on the next router push.
          h.router.go('/other');
      }
      await tester.pumpAndSettle();
      expect(h.session.isVerified, isTrue);
      final loadsBeforeEntry = h.api.loads;
      await h.enter(tester);
      expect(h.challenges, 1);
      expect(find.byType(ReviewInvoiceOtpScreen), findsNothing);
      expect(h.api.loads, loadsBeforeEntry + 1);
    });
  }

  invoiceTest(
    'retained invoice entry after expiry requires OTP and cancel hides invoices',
    (tester) async {
      final h = _Harness();
      await h.pump(tester);
      await h.authorize(tester);
      h.router.push('/other');
      await tester.pumpAndSettle();
      expect(h.session.isVerified, isTrue);
      h.now = h.now.add(const Duration(minutes: 20));
      expect(h.challenges, 1);
      h.router.pop();
      await tester.pumpAndSettle();
      expect(h.challenges, 2);
      expect(find.byType(ReviewInvoiceOtpScreen), findsOneWidget);
      expect(find.byType(InvoiceTile), findsNothing);
      h.router.pop();
      await tester.pumpAndSettle();
      expect(h.session.isVerified, isFalse);
      expect(find.byType(InvoiceTile), findsNothing);
      expect(h.api.loads, 1);
    },
  );

  invoiceTest(
    'active expiry does not eject invoices, but next entry requires OTP',
    (tester) async {
      final h = _Harness();
      await h.pump(tester);
      await h.authorize(tester);
      final expiry = h.session.expiresAt;
      h.now = h.now.add(const Duration(minutes: 20));
      tester.element(find.byType(ReviewInvoiceVisitScreen)).markNeedsBuild();
      await tester.pumpAndSettle();
      expect(find.byType(InvoiceTile), findsWidgets);
      expect(find.byType(ReviewInvoiceOtpScreen), findsNothing);
      expect(h.session.expiresAt, expiry);
      h.router.pop();
      await tester.pumpAndSettle();
      await h.enter(tester);
      expect(find.byType(ReviewInvoiceOtpScreen), findsOneWidget);
      expect(h.challenges, 2);
    },
  );

  invoiceTest(
    'retained invoice return within window preserves the grant and data',
    (tester) async {
      final h = _Harness();
      await h.pump(tester);
      await h.authorize(tester);
      final expiry = h.session.expiresAt;
      h.router.push('/other');
      await tester.pumpAndSettle();
      h.now = h.now.add(const Duration(minutes: 19));
      h.router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(InvoiceTile), findsWidgets);
      expect(find.byType(ReviewInvoiceOtpScreen), findsNothing);
      expect(h.session.expiresAt, expiry);
      expect(h.challenges, 1);
      expect(h.api.loads, 1);
    },
  );

  invoiceTest('dialogs do not reset invoice authorization', (tester) async {
    final h = _Harness();
    await h.pump(tester);
    await h.authorize(tester);
    showDialog<void>(
      context: tester.element(find.byType(ReviewInvoiceVisitScreen)),
      builder: (_) => const AlertDialog(title: Text('internal dialog')),
    );
    await tester.pumpAndSettle();
    expect(h.session.isVerified, isTrue);
    h.router.pop();
    await tester.pumpAndSettle();
    expect(h.session.isVerified, isTrue);
    expect(h.challenges, 1);
  });

  invoiceTest(
    'native-viewer style inactive/resumed app lifecycle retains invoice visit',
    (tester) async {
      final h = _Harness();
      await h.pump(tester);
      await h.authorize(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(h.session.isVerified, isTrue);
      expect(h.challenges, 1);
      expect(h.api.loads, 1);
    },
  );

  for (final complete in [false, true]) {
    invoiceTest(
      'iOS Back gesture ${complete ? 'completion retains' : 'cancellation retains'} authorization',
      (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        final h = _Harness();
        await h.pump(tester);
        await h.authorize(tester);
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
        expect(h.session.isVerified, isTrue);
        expect(
          find.byType(ReviewInvoicePostpaidScreen),
          complete ? findsNothing : findsOneWidget,
        );
      },
    );
  }

  invoiceTest(
    'stale retained route cleanup cannot reset a newer authorized invoice visit',
    (tester) async {
      final h = _Harness();
      await h.pump(tester);
      await h.authorize(tester);
      final old =
          ModalRoute.of(tester.element(find.byType(ReviewInvoiceVisitScreen)))!
              as PageRoute<dynamic>;
      h.router.push('/other');
      await tester.pumpAndSettle();
      await h.enter(tester);
      rootNavigatorKey.currentState!.removeRoute(old);
      await tester.pumpAndSettle();
      expect(h.session.isVerified, isTrue);
      expect(find.byType(ReviewInvoicePostpaidScreen), findsOneWidget);
      expect(h.challenges, 1);
    },
  );

  invoiceTest('hard logout resets the single shared History/Invoice session', (
    tester,
  ) async {
    final h = _Harness();
    await h.pump(tester);
    await h.authorize(tester);
    h.history.markVerified();
    await performHardLogout();
    await tester.pumpAndSettle();
    expect(h.session.isVerified, isFalse);
    expect(h.history.isVerified, isFalse);
    verify(() => h.auth.clearSession()).called(1);
  });

  invoiceTest(
    'reset while session save is pending prevents stale OTP success authorization',
    (tester) async {
      final h = _Harness()..pendingSave = Completer<void>();
      await h.pump(tester);
      await h.enter(tester);
      await h.submit(tester);
      h.session.reset();
      h.pendingSave!.complete();
      await tester.pump();
      await h.finish(tester);
      expect(h.session.isVerified, isFalse);
      expect(h.api.loads, 0);
    },
  );

  invoiceTest(
    'covered pending Challenge cannot navigate away from an outside page',
    (tester) async {
      final h = _Harness()..pendingChallenge = Completer<Response<dynamic>>();
      await h.pump(tester);
      h.router.push(AppRoutes.reviewInvoicePostPaidScreen);
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(h.challenges, 1);
      h.router.push('/other');
      await tester.pumpAndSettle();
      h.pendingChallenge!.complete(_challengeResponse('stale-test-mfa'));
      await tester.pumpAndSettle();
      expect(find.text('outside'), findsOneWidget);
      expect(find.byType(ReviewInvoiceOtpScreen), findsNothing);
      expect(h.session.isVerified, isFalse);
    },
  );

  test('authorization is resettable, memory-only with no disk restoration', () {
    final invoices = ProtectedAccountAccessVerificationSession(
      accountContext: () => 'test-account',
    );
    final history = invoices..markVerified();
    expect(invoices.isVerified, isTrue);
    invoices.markVerified();
    history.reset();
    expect(invoices.isVerified, isFalse);
    invoices.reset();
    expect(invoices.isVerified, isFalse);
    final cold = ProtectedAccountAccessVerificationSession(
      accountContext: () => 'test-account',
    );
    expect(cold.isVerified, isFalse);
    invoices.dispose();
    cold.dispose();
  });

  test(
    'injection registers shared access state and short-lived gate Cubits',
    () async {
      instance.registerSingleton<NetworkService>(_Network());
      instance.registerSingleton<AuthManager>(_Auth());
      await setupReviewInvoiceInjection();
      await setupReviewInvoiceInjection();
      expect(
        instance<ProtectedAccountAccessVerificationSession>().isVerified,
        isFalse,
      );
      expect(
        instance.isRegistered<ProtectedAccountAccessVerificationSession>(),
        isTrue,
      );
      final first = instance<ReviewInvoiceChallengeCubit>();
      final second = instance<ReviewInvoiceChallengeCubit>();
      expect(identical(first, second), isFalse);
      await first.close();
      await second.close();
      await instance.reset();
    },
  );
}
