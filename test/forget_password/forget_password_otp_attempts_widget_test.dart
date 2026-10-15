import 'package:core/core.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:finger_face_security/finger_face_security.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/repository/services/role_api_client.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/model/password_recovery_otp_challenge.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/view/forget_password_otp_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_route_args.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'support/recovery_otp_network_harness.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_state.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Auth extends Mock implements AuthManager {}

class _Account extends Mock implements AccountInfoCubit {}

class _Devices extends Mock implements DeviceLimitsCubit {}

class _Role extends Mock implements RoleApiClient {}

class _Biometrics extends MockCubit<FingerFaceSecurityState>
    implements FingerFaceSecurityCubit {}

class _Analytics extends Mock implements AnalyticsService {}

void main() {
  late RecoveryOtpNetworkHarness harness;
  late _Auth auth;
  late _Biometrics biometrics;
  late AppUiConfigCubit config;
  GoRouter? router;
  PasswordRecoveryOtpChallenge? challenge;

  setUpAll(() async {
    registerFallbackValue(
      TokenSession(
        accessToken: 'test-access',
        refreshToken: 'test-refresh',
        accessExpiresAt: DateTime(2030),
        refreshExpiresAt: DateTime(2031),
      ),
    );
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() async {
    await instance.reset();
    SharedPreferences.setMockInitialValues({});
    auth = _Auth();
    harness = RecoveryOtpNetworkHarness(
      authManager: auth,
      persistCookies: false,
    );
    await harness.open();
    biometrics = _Biometrics();
    when(() => biometrics.state).thenReturn(const FingerFaceSecurityState());
    config = AppUiConfigCubit();
    router = null;
    challenge = null;
    final account = _Account();
    final devices = _Devices();
    final role = _Role();
    final analytics = _Analytics();
    when(() => auth.saveSession(any())).thenAnswer((_) async {});
    when(
      () => account.fetchAccountInfo(forceRefresh: true),
    ).thenAnswer((_) async {});
    when(() => account.state).thenReturn(
      const AccountInfoState(
        status: AccountInfoStatus.success,
        accountInfo: AccountInfoModel(idAcc: 1, paymentOption: 'PrePay'),
      ),
    );
    when(
      () => devices.loadDeviceLimits(forceRefresh: true),
    ).thenAnswer((_) async {});
    when(() => devices.state).thenReturn(
      DeviceLimitsState(
        status: DeviceLimitsStatus.loaded,
        allDeviceLimits: [
          DeviceLimitsModel.fromJson({'DeviceID': 123}),
        ],
      ),
    );
    when(() => role.fetchRoleId(123)).thenAnswer((_) async => 1);
    when(() => analytics.logLogin()).thenAnswer((_) async {});
    instance.registerSingleton<NetworkService>(harness.network);
    instance.registerSingleton<AuthManager>(auth);
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<RoleApiClient>(role);
    instance.registerSingleton<FingerFaceSecurityCubit>(biometrics);
    instance.registerSingleton<AnalyticsService>(analytics);
  });

  tearDown(() async {
    router?.dispose();
    await config.close();
    await harness.close();
    await instance.reset();
  });

  Future<void> open(
    WidgetTester tester, {
    double width = 390,
    bool recovery = true,
    bool fromLogin = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 1000);
    addTearDown(tester.view.reset);
    final path = recovery ? AppRoutes.forgetPasswordOtp : AppRoutes.loginOtp;
    final productionRouter = AppRouter().router;
    final productionRoutes = productionRouter.configuration.routes
        .whereType<GoRoute>()
        .where(
          (route) => [
            AppRoutes.logIn,
            AppRoutes.forgetPassword,
            AppRoutes.forgetPasswordOtp,
            AppRoutes.loginOtp,
          ].contains(route.path),
        )
        .toList();
    productionRouter.dispose();
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: fromLogin ? AppRoutes.logIn : path,
      initialExtra: fromLogin
          ? null
          : recovery
          ? PasswordRecoveryOtpChallenge(
              mfaToken: 'original-challenge',
              phoneNumber: '242-765-4321',
              apiPhoneNumber: '2427654321',
            )
          : const LoginOtpRouteArgs(
              mfaToken: 'original-challenge',
              phoneNumber: '242-765-4321',
              apiPhoneNumber: '2427654321',
            ),
      routes: [
        ...productionRoutes,
        GoRoute(
          path: AppRoutes.createPassword,
          builder: (_, state) {
            expect(state.extra, isTrue);
            return const Scaffold(body: Text('password reset destination'));
          },
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const Scaffold(body: Text('home destination')),
        ),
      ],
    );
    await tester.pumpWidget(
      BlocProvider.value(
        value: config,
        child: MaterialApp.router(routerConfig: router!),
      ),
    );
    await tester.pumpAndSettle();
    if (fromLogin) {
      await tester.ensureVisible(find.text('forgot password?'));
      await tester.tap(find.text('forgot password?'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '7654321');
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('send'));
      await tester.tap(find.text('send'));
      await tester.pumpAndSettle();
      expect(harness.transport.forgotRequests, hasLength(1));
      expect(
        harness.transport.forgotRequests.single.data,
        containsPair('Username', '2427654321'),
      );
      expect(
        find.text('a verification code has been sent to your number and email'),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 3));
    }
    if (recovery) {
      challenge = tester
          .widget<ForgetPasswordOtpScreen>(find.byType(ForgetPasswordOtpScreen))
          .challenge;
    }
    await tester.enterText(find.byType(TextField).first, '000000');
    await tester.pumpAndSettle();
  }

  Future<void> tapVerify(WidgetTester tester) async {
    await tester.ensureVisible(find.text('verify'));
    await tester.tap(find.text('verify'));
    await tester.pumpAndSettle();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpWidget(const SizedBox.shrink());
  }

  LoginOtpBloc activeBloc(WidgetTester tester) =>
      tester.element(find.byType(TextField).first).read<LoginOtpBloc>();

  Future<void> invalidAttempts(WidgetTester tester, int count) async {
    for (var i = 0; i < count; i++) {
      await tapVerify(tester);
      expect(find.text('Invalid OTP'), findsOneWidget);
      expect(find.text(requiredRecoveryOtpMessage), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    }
  }

  Future<void> resend(WidgetTester tester) async {
    await tester.ensureVisible(find.text('resend code'));
    await tester.tap(find.text('resend code'));
    await tester.pumpAndSettle();
    expect(activeBloc(tester).state.code, isEmpty);
    expect(
      tester
          .widgetList<TextField>(find.byType(TextField))
          .map((field) => field.controller!.text),
      everyElement(isEmpty),
    );
  }

  void testScreen(String description, WidgetTesterCallback callback) {
    testWidgets(description, (tester) async {
      await http.runWithClient(
        () => callback(tester),
        () => MockClient((_) async => http.Response('', 200)),
      );
    });
  }

  for (final width in [320.0, 390.0]) {
    testScreen(
      'exact HTTP 400 code 202 shows one special toast on attempt five at $width',
      (tester) async {
        await open(tester, width: width, fromLogin: width >= 390);
        final bloc = activeBloc(tester);
        for (var i = 1; i <= 5; i++) {
          tester.view.physicalSize = Size(width + i, 1000);
          await tester.pumpAndSettle();
          expect(identical(activeBloc(tester), bloc), isTrue);
          await tapVerify(tester);
          expect(harness.transport.verifyRequests.length, i);
          expect(
            find.text(i == 5 ? requiredRecoveryOtpMessage : 'Invalid OTP'),
            findsOneWidget,
          );
          expect(find.byIcon(Icons.close), findsOneWidget);
          expect(find.text('password reset destination'), findsNothing);
          if (i == 5) {
            expect(find.text('Invalid OTP'), findsNothing);
          } else {
            expect(find.text(requiredRecoveryOtpMessage), findsNothing);
          }
          await tester.pump(const Duration(seconds: 3));
        }
        verifyNever(() => auth.saveSession(any()));
        verifyNever(() => biometrics.markSessionAuthenticated());
        expect(harness.hardLogouts, 0);
        expect(tester.takeException(), isNull);
        await finish(tester);
      },
    );
  }

  testScreen(
    'correct OTP before five failures preserves success and reset navigation',
    (tester) async {
      await open(tester, fromLogin: true);
      await invalidAttempts(tester, 3);
      harness.transport.successfulAttempt = 4;
      await tapVerify(tester);
      expect(find.text('Code verified.'), findsOneWidget);
      expect(find.text('password reset destination'), findsOneWidget);
      expect(find.text(requiredRecoveryOtpMessage), findsNothing);
      verify(() => auth.saveSession(any())).called(1);
      verify(() => biometrics.markSessionAuthenticated()).called(1);
      expect(harness.transport.verifyRequests, hasLength(4));
      await finish(tester);
    },
  );

  testScreen(
    'replacement resend starts at zero and same challenge survives leaving and reopening',
    (tester) async {
      await open(tester);
      await invalidAttempts(tester, 4);
      await resend(tester);
      expect(harness.transport.resendRequests, hasLength(1));
      expect(
        find.text('Verification code resent successfully.'),
        findsOneWidget,
      );
      expect(activeBloc(tester).state.mfaToken, 'replacement-challenge');
      await tester.pump(const Duration(seconds: 3));
      await tester.enterText(find.byType(TextField).first, '000000');
      await invalidAttempts(tester, 4);
      final oldBloc = activeBloc(tester);
      router!.go(AppRoutes.logIn);
      await tester.pumpAndSettle();
      expect(find.byType(ForgetPasswordOtpScreen), findsNothing);
      router!.push(AppRoutes.forgetPasswordOtp, extra: challenge);
      await tester.pumpAndSettle();
      expect(identical(activeBloc(tester), oldBloc), isFalse);
      expect(activeBloc(tester).state.mfaToken, 'replacement-challenge');
      await tester.enterText(find.byType(TextField).first, '000000');
      await tapVerify(tester);
      expect(harness.transport.verifyRequests, hasLength(9));
      expect(
        harness.transport.verifyRequests.last.data,
        containsPair('mfa_token', 'replacement-challenge'),
      );
      expect(find.text(requiredRecoveryOtpMessage), findsOneWidget);
      expect(find.text('Invalid OTP'), findsNothing);
      expect(find.byIcon(Icons.close), findsOneWidget);
      await finish(tester);
    },
  );

  testScreen(
    'failed resend retains four incorrect attempts and backend error',
    (tester) async {
      await open(tester);
      await invalidAttempts(tester, 4);
      harness.transport.resendReply = const OtpHttpReply(429, {
        'Message': 'Please wait before requesting another code.',
      });
      await resend(tester);
      expect(
        find.text('Please wait before requesting another code.'),
        findsOneWidget,
      );
      expect(activeBloc(tester).state.mfaToken, 'original-challenge');
      await tester.pump(const Duration(seconds: 3));
      await tester.enterText(find.byType(TextField).first, '000000');
      await tapVerify(tester);
      expect(find.text(requiredRecoveryOtpMessage), findsOneWidget);
      expect(harness.transport.verifyRequests, hasLength(5));
      await finish(tester);
    },
  );

  testScreen(
    'backend verification lockout stays authoritative at attempt five',
    (tester) async {
      await open(tester);
      await invalidAttempts(tester, 4);
      harness.transport.invalidReply = const OtpHttpReply(429, {
        'Message': 'Too many requests. Try again later.',
      });
      await tapVerify(tester);
      expect(find.text('Too many requests. Try again later.'), findsOneWidget);
      expect(find.text(requiredRecoveryOtpMessage), findsNothing);
      expect(find.text('password reset destination'), findsNothing);
      expect(activeBloc(tester).state.status, LoginOtpStatus.failure);
      await finish(tester);
    },
  );

  testScreen(
    'Login 2FA keeps its existing message for six exact HTTP 400 responses',
    (tester) async {
      await open(tester, recovery: false);
      await invalidAttempts(tester, 6);
      expect(harness.transport.verifyRequests, hasLength(6));
      expect(find.text('password reset destination'), findsNothing);
      expect(find.text('home destination'), findsNothing);
      verifyNever(() => auth.saveSession(any()));
      await finish(tester);
    },
  );
}
