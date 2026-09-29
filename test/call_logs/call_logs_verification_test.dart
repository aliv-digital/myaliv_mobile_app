import 'dart:async';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_resend_response_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_verify_response_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/base_login_otp_repository.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_otp_repository.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_otp_route_args.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_session_completion_service.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_gate_screen.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_session.dart';
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

    test('does not call challenge API without a signed-in session', () async {
      when(() => authManager.currentSession).thenReturn(null);
      final repository = CallLogsVerificationRepository(
        networkService: networkService,
        authManager: authManager,
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
      when(authManager.refreshIfNeeded)
          .thenAnswer((_) async => refreshedSession);
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
        ServerException(
          'An unexpected error occurred.',
          statusCode: 500,
        ),
      );
      final repository = CallLogsVerificationRepository(
        networkService: networkService,
        authManager: authManager,
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
    test('verify delegates to the existing OTP verification repository',
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
    });

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

  test('successful Call Logs verification replaces both stored tokens',
      () async {
    final nextSession = _session(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
    );
    when(() => authManager.saveSession(nextSession)).thenAnswer((_) async {});
    final service = CallLogsSessionCompletionService(authManager: authManager);

    await service.complete(
      session: nextSession,
      appUiConfigCubit: AppUiConfigCubit(),
    );

    verify(() => authManager.saveSession(nextSession)).called(1);
  });

  test('verification authorization is memory-only and resettable', () {
    final session = CallLogsVerificationSession();

    expect(session.isVerified, isFalse);
    session.markVerified();
    expect(session.isVerified, isTrue);
    session.reset();
    expect(session.isVerified, isFalse);
  });

  testWidgets(
    'profile shows an inline loader and opens OTP after challenge success',
    (tester) async {
      final repository = _MockVerificationRepository();
      final challengeCompleter = Completer<CallLogsChallenge>();
      when(repository.requestChallenge).thenAnswer(
        (_) => challengeCompleter.future,
      );
      instance.registerSingleton<CallLogsVerificationRepository>(repository);
      addTearDown(() async {
        await instance.unregister<CallLogsVerificationRepository>();
      });

      CallLogsOtpRouteArgs? receivedArgs;
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
      verify(repository.requestChallenge).called(1);

      challengeCompleter.complete(
        const CallLogsChallenge(
          mfaToken: 'mfa-from-profile',
          apiPhoneNumber: '12425551234',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('OTP destination'), findsOneWidget);
      expect(receivedArgs?.mfaToken, 'mfa-from-profile');
      expect(receivedArgs?.apiPhoneNumber, '12425551234');
    },
  );

  testWidgets('gate requests challenge and forwards the MFA token to OTP', (
    tester,
  ) async {
    final repository = _MockVerificationRepository();
    final verificationSession = CallLogsVerificationSession();
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
    final verificationSession = CallLogsVerificationSession()..markVerified();
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
  required CallLogsVerificationSession verificationSession,
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
