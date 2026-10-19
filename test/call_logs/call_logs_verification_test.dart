import 'dart:async';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/services/auth_completion_service.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_resend_response_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_verify_response_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/base_login_otp_repository.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_otp_repository.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_otp_route_args.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_session_completion_service.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_gate_screen.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/common/verification/protected_account_access_verification_session.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/profile/prepaid/view/profile_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/profile/prepaid/widgets/profile_menu_item_tile.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _MockNetworkService extends Mock implements NetworkService {}

class _MockAuthManager extends Mock implements AuthManager {}

class _MockVerificationRepository extends Mock
    implements CallLogsVerificationRepository {}

class _MockOtpRepository extends Mock implements BaseLoginOtpRepository {}

class _FixedInternetConnection extends Fake implements InternetConnection {
  _FixedInternetConnection(this.isConnected);

  final bool isConnected;

  @override
  Future<bool> get hasInternetAccess async => isConnected;
}

class _NoOpAuthCompletionService extends Fake implements AuthCompletionService {
  @override
  Future<void> complete({
    required TokenSession session,
    required AppUiConfigCubit appUiConfigCubit,
  }) async {}
}

class _NoOpAnalyticsService extends Fake implements AnalyticsService {
  @override
  Future<void> logLogin() async {}
}

void main() {
  late _MockNetworkService networkService;
  late _MockAuthManager authManager;

  setUp(() {
    networkService = _MockNetworkService();
    authManager = _MockAuthManager();
  });

  group('Call Logs challenge', () {
    test('posts the current access token and returns MFA route data', () async {
      final session = _session(accessToken: 'current-access');
      when(() => authManager.currentSession).thenReturn(session);
      when(
        () => networkService.request<dynamic>(
          Api.challengeOtpUrl,
          method: HttpMethod.post,
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          data: <String, dynamic>{'mfa_token': 'mfa-123'},
          statusCode: 202,
          requestOptions: RequestOptions(path: Api.challengeOtpUrl),
        ),
      );
      final repository = CallLogsVerificationRepository(
        networkService: networkService,
        authManager: authManager,
        internetConnection: _FixedInternetConnection(true),
        phoneNumberProvider: () async => '12425551234',
      );

      final result = await repository.requestChallenge();

      expect(result.mfaToken, 'mfa-123');
      expect(result.apiPhoneNumber, '12425551234');
      final captured = verify(
        () => networkService.request<dynamic>(
          Api.challengeOtpUrl,
          method: HttpMethod.post,
          data: captureAny(named: 'data'),
        ),
      ).captured;
      expect(captured.first, <String, dynamic>{
        'access_token': 'current-access',
      });
      verifyNever(authManager.refreshIfNeeded);
    });

    test('returns No internet before starting the challenge when offline', () {
      final repository = CallLogsVerificationRepository(
        networkService: networkService,
        authManager: authManager,
        internetConnection: _FixedInternetConnection(false),
        phoneNumberProvider: () async => '12425551234',
      );

      expect(
        repository.requestChallenge,
        throwsA(
          isA<CallLogsVerificationException>().having(
            (error) => error.message,
            'message',
            'No internet',
          ),
        ),
      );
      verifyNever(authManager.refreshIfNeeded);
      verifyNever(
        () => networkService.request<dynamic>(
          Api.challengeOtpUrl,
          method: HttpMethod.post,
          data: any(named: 'data'),
        ),
      );
    });

    test('does not call challenge API without a signed-in session', () async {
      when(() => authManager.currentSession).thenReturn(null);
      final repository = CallLogsVerificationRepository(
        networkService: networkService,
        authManager: authManager,
        internetConnection: _FixedInternetConnection(true),
        phoneNumberProvider: () async => '12425551234',
      );

      expect(
        repository.requestChallenge,
        throwsA(
          isA<CallLogsVerificationException>().having(
            (error) => error.message,
            'message',
            contains('session'),
          ),
        ),
      );
      verifyNever(
        () => networkService.request<dynamic>(
          Api.challengeOtpUrl,
          method: HttpMethod.post,
          data: any(named: 'data'),
        ),
      );
    });

    test('refreshes before challenge and posts the new access token', () async {
      final expiredSession = _session(
        accessToken: 'expired-access',
        accessExpiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );
      final refreshedSession = _session(accessToken: 'fresh-access');
      when(() => authManager.currentSession).thenReturn(expiredSession);
      when(
        authManager.refreshIfNeeded,
      ).thenAnswer((_) async => refreshedSession);
      when(
        () => networkService.request<dynamic>(
          Api.challengeOtpUrl,
          method: HttpMethod.post,
          data: any(named: 'data'),
        ),
      ).thenAnswer(
        (_) async => Response<dynamic>(
          data: <String, dynamic>{'mfa_token': 'mfa-after-refresh'},
          statusCode: 202,
          requestOptions: RequestOptions(path: Api.challengeOtpUrl),
        ),
      );
      final repository = CallLogsVerificationRepository(
        networkService: networkService,
        authManager: authManager,
        internetConnection: _FixedInternetConnection(true),
        phoneNumberProvider: () async => '12425551234',
      );

      final result = await repository.requestChallenge();

      expect(result.mfaToken, 'mfa-after-refresh');
      verify(authManager.refreshIfNeeded).called(1);
      verify(
        () => networkService.request<dynamic>(
          Api.challengeOtpUrl,
          method: HttpMethod.post,
          data: <String, dynamic>{'access_token': 'fresh-access'},
        ),
      ).called(1);
    });

    test('does not refresh or retry when the challenge API fails', () async {
      final session = _session(accessToken: 'current-access');
      when(() => authManager.currentSession).thenReturn(session);
      when(
        () => networkService.request<dynamic>(
          Api.challengeOtpUrl,
          method: HttpMethod.post,
          data: any(named: 'data'),
        ),
      ).thenThrow(
        ServerException('An unexpected error occurred.', statusCode: 500),
      );
      final repository = CallLogsVerificationRepository(
        networkService: networkService,
        authManager: authManager,
        internetConnection: _FixedInternetConnection(true),
        phoneNumberProvider: () async => '12425551234',
      );

      await expectLater(
        repository.requestChallenge(),
        throwsA(isA<CallLogsVerificationException>()),
      );
      verifyNever(authManager.refreshIfNeeded);
      verify(
        () => networkService.request<dynamic>(
          Api.challengeOtpUrl,
          method: HttpMethod.post,
          data: <String, dynamic>{'access_token': 'current-access'},
        ),
      ).called(1);
    });
  });

  group('Call Logs OTP adapter', () {
    test(
      'verify delegates to the existing OTP verification repository',
      () async {
        final verificationRepository = _MockVerificationRepository();
        final otpDelegate = _MockOtpRepository();
        final response = LoginOtpVerifyResponse(session: _session());
        when(
          () => otpDelegate.verifyCode(
            phoneNumber: '12425551234',
            mfaToken: 'mfa-123',
            otpCode: '123456',
          ),
        ).thenAnswer((_) async => response);
        final repository = CallLogsOtpRepository(
          verificationRepository: verificationRepository,
          verificationDelegate: otpDelegate,
        );

        final result = await repository.verifyCode(
          phoneNumber: '12425551234',
          mfaToken: 'mfa-123',
          otpCode: '123456',
        );

        expect(result, same(response));
        verify(
          () => otpDelegate.verifyCode(
            phoneNumber: '12425551234',
            mfaToken: 'mfa-123',
            otpCode: '123456',
          ),
        ).called(1);
      },
    );

    test('resend requests a new challenge and returns its MFA token', () async {
      final verificationRepository = _MockVerificationRepository();
      final otpDelegate = _MockOtpRepository();
      when(verificationRepository.requestChallenge).thenAnswer(
        (_) async => const CallLogsChallenge(
          mfaToken: 'replacement-mfa',
          apiPhoneNumber: '12425551234',
        ),
      );
      final repository = CallLogsOtpRepository(
        verificationRepository: verificationRepository,
        verificationDelegate: otpDelegate,
      );

      final LoginOtpResendResponse result = await repository.resendCode(
        phoneNumber: 'ignored',
        mfaToken: 'old-mfa',
      );

      expect(result.mfaToken, 'replacement-mfa');
      verify(verificationRepository.requestChallenge).called(1);
    });
  });

  test(
    'Call Logs OTP ignores rapid Verify submissions while one is in flight',
    () async {
      final repository = _MockOtpRepository();
      var verifyCompleter = Completer<LoginOtpVerifyResponse>();
      when(
        () => repository.verifyCode(
          phoneNumber: any(named: 'phoneNumber'),
          mfaToken: any(named: 'mfaToken'),
          otpCode: any(named: 'otpCode'),
        ),
      ).thenAnswer((_) => verifyCompleter.future);
      final bloc = LoginOtpBloc(
        repository: repository,
        appUiConfigCubit: AppUiConfigCubit(),
        authCompletionService: _NoOpAuthCompletionService(),
        internetConnection: _FixedInternetConnection(true),
        analyticsService: _NoOpAnalyticsService(),
        initialMfaToken: 'mfa-123',
        initialPhoneNumber: '2428997955',
        initialApiPhoneNumber: '2428997955',
        preventDuplicateSubmissions: true,
      );
      addTearDown(bloc.close);

      final codeReady = bloc.stream.firstWhere(
        (state) => state.code == '123456',
      );
      bloc.add(const LoginOtpCodeChanged('123456'));
      await codeReady;

      final firstLoading = bloc.stream.firstWhere(
        (state) => state.status == LoginOtpStatus.loading,
      );
      bloc
        ..add(const LoginOtpSubmitted())
        ..add(const LoginOtpSubmitted())
        ..add(const LoginOtpSubmitted())
        ..add(const LoginOtpSubmitted());
      await firstLoading;

      verify(
        () => repository.verifyCode(
          phoneNumber: '2428997955',
          mfaToken: 'mfa-123',
          otpCode: '123456',
        ),
      ).called(1);

      final firstFailure = bloc.stream.firstWhere(
        (state) => state.status == LoginOtpStatus.failure,
      );
      verifyCompleter.completeError(Exception('Invalid OTP'));
      await firstFailure;

      verifyCompleter = Completer<LoginOtpVerifyResponse>();
      final retryLoading = bloc.stream.firstWhere(
        (state) => state.status == LoginOtpStatus.loading,
      );
      bloc.add(const LoginOtpSubmitted());
      await retryLoading;

      verify(
        () => repository.verifyCode(
          phoneNumber: '2428997955',
          mfaToken: 'mfa-123',
          otpCode: '123456',
        ),
      ).called(1);

      final retryFailure = bloc.stream.firstWhere(
        (state) => state.status == LoginOtpStatus.failure,
      );
      verifyCompleter.completeError(Exception('Invalid OTP'));
      await retryFailure;
    },
  );

  test(
    'Call Logs OTP uses the dedicated network error message when offline',
    () async {
      const networkErrorMessage =
          "We couldn't verify the OTP due to a network error. Please try again later";
      final repository = _MockOtpRepository();
      final bloc = LoginOtpBloc(
        repository: repository,
        appUiConfigCubit: AppUiConfigCubit(),
        authCompletionService: _NoOpAuthCompletionService(),
        internetConnection: _FixedInternetConnection(false),
        analyticsService: _NoOpAnalyticsService(),
        initialMfaToken: 'mfa-123',
        initialPhoneNumber: '2428997955',
        initialApiPhoneNumber: '2428997955',
        preventDuplicateSubmissions: true,
        offlineVerificationMessage: networkErrorMessage,
      );
      addTearDown(bloc.close);

      final codeReady = bloc.stream.firstWhere(
        (state) => state.code == '123456',
      );
      bloc.add(const LoginOtpCodeChanged('123456'));
      await codeReady;

      final failure = bloc.stream.firstWhere(
        (state) => state.status == LoginOtpStatus.failure,
      );
      bloc.add(const LoginOtpSubmitted());
      final state = await failure;

      expect(state.errorMessage, networkErrorMessage);
      verifyNever(
        () => repository.verifyCode(
          phoneNumber: any(named: 'phoneNumber'),
          mfaToken: any(named: 'mfaToken'),
          otpCode: any(named: 'otpCode'),
        ),
      );
    },
  );

  test(
    'successful Call Logs verification replaces both stored tokens',
    () async {
      final nextSession = _session(
        accessToken: 'new-access',
        refreshToken: 'new-refresh',
      );
      when(() => authManager.saveSession(nextSession)).thenAnswer((_) async {});
      final service = CallLogsSessionCompletionService(
        authManager: authManager,
      );

      await service.complete(
        session: nextSession,
        appUiConfigCubit: AppUiConfigCubit(),
      );

      verify(() => authManager.saveSession(nextSession)).called(1);
    },
  );

  test('verification authorization is memory-only and resettable', () {
    final session = ProtectedAccountAccessVerificationSession(
      accountContext: () => 'test-account',
    );

    expect(session.isVerified, isFalse);
    session.markVerified();
    expect(session.isVerified, isTrue);
    session.reset();
    expect(session.isVerified, isFalse);
    expect(
      ProtectedAccountAccessVerificationSession(
        accountContext: () => 'test-account',
      ).isVerified,
      isFalse,
    );
  });

  testWidgets(
    'profile shows an inline loader and opens OTP after challenge success',
    (tester) async {
      final repository = _MockVerificationRepository();
      final challengeCompleter = Completer<CallLogsChallenge>();
      when(
        repository.requestChallenge,
      ).thenAnswer((_) => challengeCompleter.future);
      instance.registerSingleton<CallLogsVerificationRepository>(repository);
      instance.registerSingleton<ProtectedAccountAccessVerificationSession>(
        ProtectedAccountAccessVerificationSession(
          accountContext: () => 'test-account',
        ),
      );
      addTearDown(() async {
        await instance.unregister<CallLogsVerificationRepository>();
        await instance.unregister<ProtectedAccountAccessVerificationSession>();
      });

      CallLogsOtpRouteArgs? receivedArgs;
      var otpNavigationCount = 0;
      final router = GoRouter(
        initialLocation: '/profile-test',
        routes: [
          GoRoute(
            path: '/profile-test',
            builder: (context, state) => const ProfilePrepaidScreen(),
          ),
          GoRoute(
            path: AppRoutes.callLogsOtp,
            builder: (context, state) {
              otpNavigationCount++;
              receivedArgs = state.extra! as CallLogsOtpRouteArgs;
              return const Scaffold(body: Text('OTP destination'));
            },
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('call logs'));
      await tester.pump();

      final callLogsTile = find.byWidgetPredicate(
        (widget) =>
            widget is ProfileMenuItemTile && widget.title == 'call logs',
      );
      expect(
        find.descendant(
          of: callLogsTile,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<ProfileMenuItemTile>(callLogsTile).isTapEnabled,
        isFalse,
      );

      await tester.tap(find.text('call logs'));
      await tester.tap(find.text('call logs'));
      await tester.tap(find.text('call logs'));
      await tester.pump();

      verify(repository.requestChallenge).called(1);

      challengeCompleter.complete(
        const CallLogsChallenge(
          mfaToken: 'mfa-from-profile',
          apiPhoneNumber: '12425551234',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('OTP destination'), findsOneWidget);
      expect(otpNavigationCount, 1);
      expect(receivedArgs?.mfaToken, 'mfa-from-profile');
      expect(receivedArgs?.apiPhoneNumber, '12425551234');
    },
  );

  testWidgets(
    'profile reopens Call Logs without another challenge after verification',
    (tester) async {
      final repository = _MockVerificationRepository();
      instance.registerSingleton<CallLogsVerificationRepository>(repository);
      instance.registerSingleton<ProtectedAccountAccessVerificationSession>(
        ProtectedAccountAccessVerificationSession(
          accountContext: () => 'test-account',
        )..markVerified(),
      );
      addTearDown(() async {
        await instance.unregister<CallLogsVerificationRepository>();
        await instance.unregister<ProtectedAccountAccessVerificationSession>();
      });

      final router = GoRouter(
        initialLocation: '/profile-test',
        routes: [
          GoRoute(
            path: '/profile-test',
            builder: (context, state) => const ProfilePrepaidScreen(),
          ),
          GoRoute(
            path: AppRoutes.callLogs,
            builder: (context, state) =>
                const Scaffold(body: Text('Call Logs destination')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('call logs'));
      await tester.pumpAndSettle();

      expect(find.text('Call Logs destination'), findsOneWidget);
      verifyNever(repository.requestChallenge);
    },
  );

  testWidgets('gate requests challenge and forwards the MFA token to OTP', (
    tester,
  ) async {
    final repository = _MockVerificationRepository();
    final verificationSession = ProtectedAccountAccessVerificationSession(
      accountContext: () => 'test-account',
    );
    when(repository.requestChallenge).thenAnswer(
      (_) async => const CallLogsChallenge(
        mfaToken: 'mfa-from-challenge',
        apiPhoneNumber: '12425551234',
      ),
    );
    CallLogsOtpRouteArgs? receivedArgs;
    final router = _gateRouter(
      repository: repository,
      verificationSession: verificationSession,
      onOtp: (args) => receivedArgs = args,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('OTP destination'), findsOneWidget);
    expect(receivedArgs?.mfaToken, 'mfa-from-challenge');
    expect(receivedArgs?.apiPhoneNumber, '12425551234');
    verify(repository.requestChallenge).called(1);
  });

  testWidgets('verified in-memory session bypasses another challenge', (
    tester,
  ) async {
    final repository = _MockVerificationRepository();
    final verificationSession = ProtectedAccountAccessVerificationSession(
      accountContext: () => 'test-account',
    )..markVerified();
    final router = _gateRouter(
      repository: repository,
      verificationSession: verificationSession,
      onOtp: (_) {},
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Call Logs destination'), findsOneWidget);
    verifyNever(repository.requestChallenge);
  });
}

TokenSession _session({
  String accessToken = 'access',
  String refreshToken = 'refresh',
  DateTime? accessExpiresAt,
}) {
  return TokenSession(
    accessToken: accessToken,
    refreshToken: refreshToken,
    accessExpiresAt:
        accessExpiresAt ?? DateTime.now().add(const Duration(hours: 1)),
    refreshExpiresAt: DateTime.now().add(const Duration(days: 30)),
  );
}

GoRouter _gateRouter({
  required CallLogsVerificationRepository repository,
  required ProtectedAccountAccessVerificationSession verificationSession,
  required ValueChanged<CallLogsOtpRouteArgs> onOtp,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/gate',
    routes: [
      GoRoute(
        path: '/gate',
        builder: (context, state) => CallLogsVerificationGateScreen(
          repository: repository,
          verificationSession: verificationSession,
        ),
      ),
      GoRoute(
        path: AppRoutes.callLogsOtp,
        builder: (context, state) {
          onOtp(state.extra! as CallLogsOtpRouteArgs);
          return const Scaffold(body: Text('OTP destination'));
        },
      ),
      GoRoute(
        path: AppRoutes.callLogs,
        builder: (context, state) =>
            const Scaffold(body: Text('Call Logs destination')),
      ),
    ],
  );
}
