import 'dart:async';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/bloc/auto_renew_auth_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/repository/auto_renew_auth_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/view/auto_renew_auth_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/verification/auto_renew_authorization_otp_route_args.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/verification/auto_renew_authorization_otp_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/bloc/auto_renew_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/bloc/auto_renew_prepaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/models/auto_renew_prepaid_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/widgets/auto_renew_prepaid_page_content.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/widgets/auto_renew_prepaid_proceed_action_button.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/widgets/otp_code_fields.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/common/verification/protected_account_access_verification_session.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/router/app_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class _Auth extends Mock implements AuthManager {}

class _Network extends Mock implements NetworkService {}

class _Challenge extends Mock implements CallLogsVerificationRepository {}

class _Devices extends Mock implements DeviceLimitsCubit {}

class _Account extends Mock implements AccountInfoCubit {}

class _Balance extends Mock implements BalanceCubit {}

class _Cards extends Mock implements SavedCardsCubit {}

class _Selection extends Mock implements AutoRenewPrepaidBloc {}

TokenSession _session(String label) => TokenSession(
  accessToken: 'test-$label',
  refreshToken: 'test-refresh-$label',
  accessExpiresAt: DateTime(2030),
  refreshExpiresAt: DateTime(2031),
);

class _Harness {
  _Harness() {
    instance.registerSingleton<AuthManager>(auth);
    instance.registerSingleton<NetworkService>(network);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<CallLogsVerificationRepository>(challenge);
    instance.registerSingleton<ProtectedAccountAccessVerificationSession>(
      history,
    );
    when(() => auth.currentSession).thenAnswer((_) => current);
    when(() => devices.state).thenAnswer((_) => deviceState);
    when(() => devices.stream).thenAnswer((_) => const Stream.empty());
    when(() => account.state).thenReturn(
      const AccountInfoState(
        status: AccountInfoStatus.success,
        accountInfo: AccountInfoModel(
          idAcc: 42,
          fName: 'Test',
          lName: 'Subscriber',
        ),
      ),
    );
    when(() => account.stream).thenAnswer((_) => const Stream.empty());
    when(() => balance.state).thenReturn(BalanceState.initial());
    when(() => balance.stream).thenAnswer((_) => const Stream.empty());
    when(
      () => cards.state,
    ).thenReturn(const SavedCardsState(status: SavedCardsStatus.success));
    when(() => cards.stream).thenAnswer((_) => const Stream.empty());
    when(() => selection.state).thenAnswer((_) => selectionState);
    when(() => selection.stream).thenAnswer((_) => const Stream.empty());
    when(() => challenge.requestChallenge()).thenAnswer((_) async {
      challenges++;
      trace.add('challenge');
      if (challengeFailure != null) {
        throw challengeFailure!;
      }
      if (challengeGate != null) {
        return challengeGate!.future;
      }
      return CallLogsChallenge(
        mfaToken: 'test-mfa-$challenges',
        apiPhoneNumber: '2425550100',
      );
    });
    when(() => auth.saveSession(any())).thenAnswer((invocation) async {
      saves++;
      current = invocation.positionalArguments.first as TokenSession;
      trace.add('save-start');
      if (saveFailure != null) {
        throw saveFailure!;
      }
      await saveGate?.future;
      trace.add('saved');
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
      trace.add('verify');
      payloads.add(invocation.namedArguments[#data] as Map);
      if (verifyFailure != null) {
        throw verifyFailure!;
      }
      return Response<dynamic>(
        requestOptions: RequestOptions(path: Api.verifyOtpUrl),
        data: {
          'access_token': 'test-updated',
          'refresh_token': 'test-refresh-updated',
          'expires_in': 3600,
          'refresh_expires_in': 86400,
        },
      );
    });
    when(
      () => devices.enableAutoRenewCard(
        token: any(named: 'token'),
        refreshAfter: false,
      ),
    ).thenAnswer((invocation) async {
      cardTokens.add(invocation.namedArguments[#token] as String);
      trace.add('card');
      await cardGate?.future;
      return clearSuccess;
    });
    when(() => devices.enableAutoRenewWallet(any())).thenAnswer((
      invocation,
    ) async {
      walletIds.add(invocation.positionalArguments.first as int);
      trace.add('wallet');
      return walletSuccess;
    });
    when(() => devices.disableAutoRenew(any())).thenAnswer((_) async {
      trace.add('disable');
      return true;
    });
    when(() => account.enableAutoPayInvoice()).thenAnswer((_) async {
      trace.add('invoice');
      return invoiceSuccess;
    });
  }

  final auth = _Auth();
  final network = _Network();
  final challenge = _Challenge();
  final devices = _Devices();
  final account = _Account();
  final balance = _Balance();
  final cards = _Cards();
  final selection = _Selection();
  final config = AppUiConfigCubit();
  final history = ProtectedAccountAccessVerificationSession(
    accountContext: () => 'test-account',
  );
  ProtectedAccountAccessVerificationSession get invoices => history;
  TokenSession? current = _session('old');
  DeviceLimitsState deviceState = DeviceLimitsState(
    status: DeviceLimitsStatus.loaded,
    allDeviceLimits: [
      DeviceLimitsModel.fromJson({'DeviceID': 123}),
    ],
  );
  AutoRenewPrepaidState selectionState = AutoRenewPrepaidState.initial()
      .copyWith(
        loadStatus: AutoRenewLoadStatus.ready,
        selectedMethodId: AutoRenewPaymentMethod.wallet.id,
      );
  final trace = <String>[];
  final cardTokens = <String>[];
  final walletIds = <int>[];
  final payloads = <Map>[];
  int challenges = 0, saves = 0, verifies = 0;
  Object? challengeFailure, verifyFailure, saveFailure;
  Completer<CallLogsChallenge>? challengeGate;
  Completer<void>? saveGate, cardGate;
  bool clearSuccess = true, walletSuccess = true;
  bool invoiceSuccess = true;
  late GoRouter router;
  AutoRenewAuthorizationOtpRouteArgs? otpArgs;

  Future<void> pump(
    WidgetTester tester, {
    AutoRenewPaymentMethodType? formMode,
    String? cardToken = 'test-saved-card',
    bool productionRouter = false,
  }) async {
    router = productionRouter
        ? AppRouter().router
        : GoRouter(
            navigatorKey: rootNavigatorKey,
            initialLocation: formMode == null ? '/wallet' : '/form',
            routes: [
              GoRoute(
                path: '/wallet',
                builder: (_, _) => const AutoRenewPrepaidPageContent(),
              ),
              GoRoute(
                path: '/form',
                builder: (_, _) => AutoRenewAuthPrepaidScreen(
                  paymentMethod: formMode ?? AutoRenewPaymentMethodType.card,
                  cardToken: cardToken,
                  cardLastDigits: '0000',
                ),
              ),
              GoRoute(
                path: AppRoutes.autoRenewAuthorizationOtp,
                builder: (_, state) {
                  otpArgs = state.extra as AutoRenewAuthorizationOtpRouteArgs;
                  return AutoRenewAuthorizationOtpScreen(args: otpArgs!);
                },
              ),
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) =>
                    const Scaffold(body: Text('home-destination')),
              ),
            ],
          );
    if (productionRouter) {
      router.go(AppRoutes.autoRenewAuthorizationOtp, extra: 'invalid');
    }
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AppUiConfigCubit>.value(value: config),
          BlocProvider<DeviceLimitsCubit>.value(value: devices),
          BlocProvider<BalanceCubit>.value(value: balance),
          BlocProvider<SavedCardsCubit>.value(value: cards),
          BlocProvider<AutoRenewPrepaidBloc>.value(value: selection),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> proceed(WidgetTester tester, {int taps = 1}) async {
    final button = tester.widget<AutoRenewPrepaidProceedActionButton>(
      find.byType(AutoRenewPrepaidProceedActionButton),
    );
    for (var i = 0; i < taps; i++) {
      button.onPressed();
    }
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> submitOtp(WidgetTester tester, {int taps = 1}) async {
    final bloc = tester
        .element(find.byType(OtpCodeFields))
        .read<LoginOtpBloc>();
    bloc.add(const LoginOtpCodeChanged('123456'));
    await tester.pump();
    for (var i = 0; i < taps; i++) {
      bloc.add(const LoginOtpSubmitted());
    }
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  void noMutations() {
    expect(cardTokens, isEmpty);
    expect(walletIds, isEmpty);
    expect(trace, isNot(contains('invoice')));
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    router.dispose();
    await config.close();
    await instance.reset();
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(_session('fallback'));
    registerFallbackValue(Options());
  });
  _Harness? harness;
  void flowTest(
    String name,
    Future<void> Function(WidgetTester, _Harness) body,
  ) {
    testWidgets(name, (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await http.runWithClient(() async {
        final h = harness = _Harness();
        try {
          await body(tester, h);
        } finally {
          await h.dispose(tester);
          harness = null;
        }
      }, () => MockClient((_) async => http.Response('', 200)));
    });
  }

  tearDown(() async {
    if (harness != null) {
      await instance.reset();
    }
  });

  flowTest('active wallet Proceed requests Challenge with zero mutations', (
    tester,
    h,
  ) async {
    h.challengeGate = Completer<CallLogsChallenge>();
    await h.pump(tester);
    await h.proceed(tester);
    expect(h.challenges, 1);
    h.noMutations();
    expect(
      tester
          .widget<AutoRenewPrepaidProceedActionButton>(
            find.byType(AutoRenewPrepaidProceedActionButton),
          )
          .isLoading,
      isTrue,
    );
    expect(h.devices.state.isTogglingAutoRenew, isFalse);
    h.challengeGate!.complete(
      const CallLogsChallenge(
        mfaToken: 'test-mfa',
        apiPhoneNumber: '2425550100',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(OtpCodeFields), findsOneWidget);
    h.noMutations();
    h.router.pop();
    await tester.pumpAndSettle();
  });
  flowTest(
    'wallet Challenge failure leaves actionable page and zero mutations',
    (tester, h) async {
      h.challengeFailure = const CallLogsVerificationException(
        'Challenge unavailable',
      );
      await h.pump(tester);
      await h.proceed(tester);
      await h.finish(tester);
      h.noMutations();
      expect(find.byType(AutoRenewPrepaidProceedActionButton), findsOneWidget);
      expect(
        tester
            .widget<AutoRenewPrepaidProceedActionButton>(
              find.byType(AutoRenewPrepaidProceedActionButton),
            )
            .isLoading,
        isFalse,
      );
    },
  );
  flowTest('wallet invalid OTP never mutates card/wallet', (tester, h) async {
    h.verifyFailure = Exception('Invalid OTP');
    await h.pump(tester);
    await h.proceed(tester);
    await h.submitOtp(tester);
    await h.finish(tester);
    expect(h.verifies, 1);
    expect(h.saves, 0);
    h.noMutations();
    expect(find.byType(OtpCodeFields), findsOneWidget);
  });
  flowTest('wallet persistence failure blocks both mutations', (
    tester,
    h,
  ) async {
    h.saveFailure = StateError('secure storage unavailable');
    await h.pump(tester);
    await h.proceed(tester);
    await h.submitOtp(tester);
    await h.finish(tester);
    expect(h.saves, 1);
    h.noMutations();
    expect(find.byType(OtpCodeFields), findsOneWidget);
  });
  flowTest(
    'wallet waits for save, clears once then enables once, returns Home',
    (tester, h) async {
      h.saveGate = Completer<void>();
      await h.pump(tester);
      await h.proceed(tester);
      await h.submitOtp(tester);
      expect(h.saves, 1);
      h.noMutations();
      h.saveGate!.complete();
      await h.finish(tester);
      expect(h.trace, [
        'challenge',
        'verify',
        'save-start',
        'saved',
        'card',
        'wallet',
      ]);
      expect(h.cardTokens, ['']);
      expect(h.walletIds, [123]);
      expect(find.text('home-destination'), findsOneWidget);
      expect(h.current?.accessToken, 'test-updated');
      expect(h.history.isVerified, isFalse);
      expect(h.invoices.isVerified, isFalse);
    },
  );
  flowTest(
    'clear-card failure prevents wallet enable and preserves Home/error',
    (tester, h) async {
      h.clearSuccess = false;
      h.deviceState = h.deviceState.copyWith(errorMessage: 'card clear failed');
      await h.pump(tester);
      await h.proceed(tester);
      await h.submitOtp(tester);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(h.cardTokens, ['']);
      expect(h.walletIds, isEmpty);
      expect(find.text('card clear failed'), findsOneWidget);
      expect(find.text('home-destination'), findsOneWidget);
    },
  );
  flowTest(
    'wallet enable failure preserves existing error and Home navigation',
    (tester, h) async {
      h.walletSuccess = false;
      h.deviceState = h.deviceState.copyWith(
        errorMessage: 'wallet enable failed',
      );
      await h.pump(tester);
      await h.proceed(tester);
      await h.submitOtp(tester);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(h.cardTokens, ['']);
      expect(h.walletIds, [123]);
      expect(find.text('wallet enable failed'), findsOneWidget);
      expect(find.text('home-destination'), findsOneWidget);
    },
  );
  flowTest(
    'back/cancel wallet OTP restores Proceed; retry uses new Challenge',
    (tester, h) async {
      await h.pump(tester);
      await h.proceed(tester);
      final oldAttempt = h.otpArgs!.attempt;
      h.router.pop();
      await tester.pumpAndSettle();
      expect(oldAttempt.isActive, isFalse);
      h.noMutations();
      expect(
        tester
            .widget<AutoRenewPrepaidProceedActionButton>(
              find.byType(AutoRenewPrepaidProceedActionButton),
            )
            .isLoading,
        isFalse,
      );
      await h.proceed(tester);
      expect(h.challenges, 2);
      h.noMutations();
      expect(identical(h.otpArgs!.attempt, oldAttempt), isFalse);
    },
  );
  flowTest(
    'rapid Proceed and repeated OTP submit execute wallet sequence at most once',
    (tester, h) async {
      await h.pump(tester);
      await h.proceed(tester, taps: 5);
      expect(h.challenges, 1);
      await h.submitOtp(tester, taps: 5);
      await h.finish(tester);
      expect(h.verifies, 1);
      expect(h.saves, 1);
      expect(h.cardTokens, ['']);
      expect(h.walletIds, [123]);
      expect(h.otpArgs!.attempt.verifiedResult, isNull);
    },
  );
  flowTest('wallet resend rotates MFA token without mutation', (
    tester,
    h,
  ) async {
    await h.pump(tester);
    await h.proceed(tester);
    await tester.tap(find.text('resend code'));
    await tester.pumpAndSettle();
    expect(h.challenges, 2);
    h.noMutations();
    await h.submitOtp(tester);
    await h.finish(tester);
    expect(h.payloads.single['mfa_token'], 'test-mfa-2');
    expect(h.payloads.single['PhoneNumber'], '2425550100');
    expect(h.cardTokens, ['']);
    expect(h.walletIds, [123]);
  });
  flowTest('cancel during session save never executes wallet mutation', (
    tester,
    h,
  ) async {
    h.saveGate = Completer<void>();
    await h.pump(tester);
    await h.proceed(tester);
    await h.submitOtp(tester);
    h.router.pop();
    await tester.pump();
    h.saveGate!.complete();
    await h.finish(tester);
    h.noMutations();
    expect(find.byType(AutoRenewPrepaidProceedActionButton), findsOneWidget);
  });
  flowTest('leaving wallet while Challenge pending ignores late response', (
    tester,
    h,
  ) async {
    h.challengeGate = Completer<CallLogsChallenge>();
    await h.pump(tester);
    await h.proceed(tester);
    h.router.go(AppRoutes.home);
    await tester.pumpAndSettle();
    h.challengeGate!.complete(
      const CallLogsChallenge(mfaToken: 'late', apiPhoneNumber: '2425550100'),
    );
    await h.finish(tester);
    h.noMutations();
    expect(find.byType(OtpCodeFields), findsNothing);
  });
  flowTest('wallet device validation still occurs before Challenge', (
    tester,
    h,
  ) async {
    h.deviceState = DeviceLimitsState.initial();
    await h.pump(tester);
    await h.proceed(tester);
    await h.finish(tester);
    expect(h.challenges, 0);
    h.noMutations();
  });
  flowTest('disable Auto Renew remains unchanged and does not request OTP', (
    tester,
    h,
  ) async {
    h.selectionState = h.selectionState.copyWith(
      selectedMethodId: AutoRenewPaymentMethod.none.id,
    );
    await h.pump(tester);
    await h.proceed(tester);
    await h.finish(tester);
    expect(h.challenges, 0);
    expect(h.trace, ['disable']);
    expect(find.text('home-destination'), findsOneWidget);
  });
  for (final mode in AutoRenewPaymentMethodType.values) {
    flowTest(
      '$mode authorization form validates then persists OTP before original submission',
      (tester, h) async {
        h.saveGate = Completer<void>();
        await h.pump(tester, formMode: mode);
        await tester.enterText(find.byType(TextField), 'Test Subscriber');
        await tester.pump();
        await tester.ensureVisible(find.text('submit'));
        await tester.tap(find.text('submit'));
        await tester.pumpAndSettle();
        expect(h.challenges, 1);
        h.noMutations();
        await h.submitOtp(tester);
        h.noMutations();
        h.saveGate!.complete();
        await h.finish(tester);
        expect(h.trace.take(4), ['challenge', 'verify', 'save-start', 'saved']);
        switch (mode) {
          case AutoRenewPaymentMethodType.wallet:
            expect(h.cardTokens, isEmpty);
            expect(h.walletIds, [123]);
          case AutoRenewPaymentMethodType.card:
            expect(h.cardTokens, ['test-saved-card']);
            expect(h.walletIds, [123]);
          case AutoRenewPaymentMethodType.postpaidInvoice:
            expect(h.cardTokens, ['test-saved-card']);
            expect(h.walletIds, isEmpty);
            expect(h.trace.last, 'invoice');
        }
        expect(find.text('home-destination'), findsOneWidget);
        expect(h.history.isVerified, isFalse);
        expect(h.invoices.isVerified, isFalse);
      },
    );
    flowTest(
      '$mode authorization OTP cancel retains signature and creates fresh Challenge',
      (tester, h) async {
        await h.pump(tester, formMode: mode);
        await tester.enterText(find.byType(TextField), 'Test Subscriber');
        await tester.pump();
        await tester.ensureVisible(find.text('submit'));
        await tester.tap(find.text('submit'));
        await tester.pumpAndSettle();
        h.router.pop();
        await tester.pumpAndSettle();
        h.noMutations();
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'Test Subscriber',
        );
        expect(
          tester
              .element(find.byType(TextField))
              .read<AutoRenewAuthPrepaidBloc>()
              .state
              .cardToken,
          'test-saved-card',
        );
        await tester.ensureVisible(find.text('submit'));
        await tester.tap(find.text('submit'));
        await tester.pumpAndSettle();
        expect(h.challenges, 2);
        h.noMutations();
      },
    );
  }

  for (final mode in AutoRenewPaymentMethodType.values) {
    for (final failure in [
      'challenge',
      'invalid OTP',
      'session save',
      'business',
    ]) {
      flowTest('$mode $failure failure blocks/preserves existing submission', (
        tester,
        h,
      ) async {
        switch (failure) {
          case 'challenge':
            h.challengeFailure = const CallLogsVerificationException(
              'Challenge unavailable',
            );
          case 'invalid OTP':
            h.verifyFailure = Exception('Invalid OTP');
          case 'session save':
            h.saveFailure = StateError('secure storage unavailable');
          case 'business':
            h.walletSuccess = false;
            h.invoiceSuccess = false;
        }
        await h.pump(tester, formMode: mode);
        await tester.enterText(find.byType(TextField), 'Test Subscriber');
        await tester.pump();
        final bloc = tester
            .element(find.byType(TextField))
            .read<AutoRenewAuthPrepaidBloc>();
        await tester.ensureVisible(find.text('submit'));
        await tester.tap(find.text('submit'));
        await tester.pumpAndSettle();
        if (failure != 'challenge') {
          await h.submitOtp(tester);
        }
        await h.finish(tester);
        if (failure == 'business') {
          expect(
            bloc.state.errorMessage,
            'Failed to enable auto-renew. Please try again.',
          );
          expect(find.byType(TextField), findsOneWidget);
          expect(find.text('home-destination'), findsNothing);
          expect(h.trace, contains('saved'));
        } else {
          h.noMutations();
          if (failure == 'challenge') {
            expect(h.verifies, 0);
            expect(h.saves, 0);
            expect(bloc.state.errorMessage, 'Challenge unavailable');
          } else {
            expect(find.byType(OtpCodeFields), findsOneWidget);
            expect(h.saves, failure == 'session save' ? 1 : 0);
          }
        }
      });
    }
  }

  flowTest(
    'postpaid invoice without a card preserves original invoice-only action',
    (tester, h) async {
      await h.pump(
        tester,
        formMode: AutoRenewPaymentMethodType.postpaidInvoice,
        cardToken: null,
      );
      await tester.enterText(find.byType(TextField), 'Test Subscriber');
      await tester.pump();
      await tester.ensureVisible(find.text('submit'));
      await tester.tap(find.text('submit'));
      await tester.pumpAndSettle();
      h.noMutations();
      await h.submitOtp(tester);
      await h.finish(tester);
      expect(h.trace, [
        'challenge',
        'verify',
        'save-start',
        'saved',
        'invoice',
      ]);
      expect(h.cardTokens, isEmpty);
      expect(h.walletIds, isEmpty);
    },
  );
  flowTest('production OTP route rejects missing/invalid typed arguments', (
    tester,
    h,
  ) async {
    await h.pump(tester, productionRouter: true);
    expect(
      find.text(
        'Verification details unavailable. Please return and try again.',
      ),
      findsOneWidget,
    );
    expect(h.challenges, 0);
    expect(h.verifies, 0);
    expect(h.saves, 0);
    h.noMutations();
    h.router.go(AppRoutes.autoRenewAuthorizationOtp);
    await tester.pumpAndSettle();
    expect(find.byType(OtpCodeFields), findsNothing);
    h.noMutations();
  });
  flowTest('wallet offline OTP makes no verify/save/mutation calls', (
    tester,
    h,
  ) async {
    await http.runWithClient(() async {
      await h.pump(tester);
      await h.proceed(tester);
      await h.submitOtp(tester);
      await h.finish(tester);
    }, () => MockClient((_) async => http.Response('', 500)));
    expect(h.verifies, 0);
    expect(h.saves, 0);
    h.noMutations();
    expect(find.byType(OtpCodeFields), findsOneWidget);
  });
  flowTest('wallet ignores expired route attempt reused directly', (
    tester,
    h,
  ) async {
    await h.pump(tester);
    await h.proceed(tester);
    final args = h.otpArgs!;
    h.router.pop();
    await tester.pumpAndSettle();
    h.router.push(AppRoutes.autoRenewAuthorizationOtp, extra: args);
    await tester.pumpAndSettle();
    expect(
      find.text('Verification expired. Please try again.'),
      findsOneWidget,
    );
    expect(h.verifies, 0);
    expect(h.saves, 0);
    h.noMutations();
  });
  flowTest(
    'outside route pushed during wallet Challenge does not receive late OTP',
    (tester, h) async {
      h.challengeGate = Completer<CallLogsChallenge>();
      await h.pump(tester);
      await h.proceed(tester);
      h.router.push(AppRoutes.home);
      await tester.pumpAndSettle();
      h.challengeGate!.complete(
        const CallLogsChallenge(mfaToken: 'late', apiPhoneNumber: '2425550100'),
      );
      await h.finish(tester);
      h.noMutations();
      expect(find.byType(OtpCodeFields), findsNothing);
      h.router.pop();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<AutoRenewPrepaidProceedActionButton>(
              find.byType(AutoRenewPrepaidProceedActionButton),
            )
            .isLoading,
        isFalse,
      );
    },
  );
  flowTest(
    'repeated Proceed while clear-card is pending cannot replay result',
    (tester, h) async {
      h.cardGate = Completer<void>();
      await h.pump(tester);
      await h.proceed(tester);
      await h.submitOtp(tester);
      await tester.pump(const Duration(seconds: 2));
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await h.proceed(tester, taps: 5);
      expect(h.cardTokens, ['']);
      expect(h.walletIds, isEmpty);
      expect(h.challenges, 1);
      expect(h.saves, 1);
      h.cardGate!.complete();
      await h.finish(tester);
      expect(h.walletIds, [123]);
    },
  );
}
