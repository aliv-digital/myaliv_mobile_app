import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:finger_face_security/finger_face_security.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/repository/services/role_api_client.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/login_social_buttons.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_route_args.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Biometrics extends Mock implements FingerFaceSecurityRepository {}

class _Network extends Mock implements NetworkService {}

class _Auth extends Mock implements AuthManager {}

class _Account extends MockCubit<AccountInfoState>
    implements AccountInfoCubit {}

class _Devices extends MockCubit<DeviceLimitsState>
    implements DeviceLimitsCubit {}

class _Device extends Mock implements DeviceLimitsModel {}

class _Role extends Mock implements RoleApiClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const storageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  late _Biometrics repository;
  late FingerFaceSecurityCubit biometrics;
  late _Network network;
  late _Auth auth;
  late _Account account;
  late _Devices devices;
  late _Role role;
  late AppUiConfigCubit config;
  late Completer<Response<dynamic>> login;
  late Completer<void> sessionSaved;
  late Map<String, String> credentials;
  late List<String> credentialReads;
  LoginOtpRouteArgs? otpArgs;

  setUpAll(() async {
    registerFallbackValue(HttpMethod.post);
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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    credentialReads = [];
    credentials = {
      'auth.login_api_phone': '2428011616',
      'auth.login_password': 'test-password',
    };
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (call) async {
          if (call.method == 'read') {
            final key = call.arguments['key'] as String;
            credentialReads.add(key);
            return credentials[key];
          }
          return null;
        });
    repository = _Biometrics();
    when(() => repository.getBiometricStatus()).thenAnswer(
      (_) async => const FingerFaceSecurityModel(
        fingerprintEnabled: true,
        faceIdEnabled: true,
      ),
    );
    when(
      () => repository.authenticate(reason: any(named: 'reason')),
    ).thenAnswer((_) async => BiometricAuthResult.success);
    biometrics = FingerFaceSecurityCubit(repository);
    network = _Network();
    auth = _Auth();
    account = _Account();
    devices = _Devices();
    role = _Role();
    config = AppUiConfigCubit();
    otpArgs = null;
    when(() => account.state).thenReturn(
      const AccountInfoState(
        status: AccountInfoStatus.success,
        accountInfo: AccountInfoModel(idAcc: 123, paymentOption: 'PrePay'),
      ),
    );
    when(
      () => account.fetchAccountInfo(forceRefresh: true),
    ).thenAnswer((_) async {});
    final device = _Device();
    when(() => device.deviceId).thenReturn(456);
    when(() => devices.state).thenReturn(
      DeviceLimitsState(
        status: DeviceLimitsStatus.loaded,
        allDeviceLimits: [device],
      ),
    );
    when(
      () => devices.loadDeviceLimits(forceRefresh: true),
    ).thenAnswer((_) async {});
    when(() => role.fetchRoleId(456)).thenAnswer((_) async => 1);
    instance.registerSingleton<NetworkService>(network);
    instance.registerSingleton<AuthManager>(auth);
    instance.registerSingleton<AccountInfoCubit>(account);
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<RoleApiClient>(role);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
    await biometrics.close();
    await account.close();
    await devices.close();
    await config.close();
    await instance.reset();
  });

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    login = Completer<Response<dynamic>>();
    sessionSaved = Completer<void>();
    when(
      () => network.request<dynamic>(
        Api.loginUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) => login.future);
    when(() => auth.saveSession(any())).thenAnswer((_) => sessionSaved.future);
    await biometrics.loadBiometricStatus();
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.logIn,
      routes: [
        GoRoute(
          path: AppRoutes.logIn,
          builder: (_, _) => const Scaffold(body: LoginSocialButtons()),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const Scaffold(body: Text('existing home')),
        ),
        GoRoute(
          path: AppRoutes.loginOtp,
          builder: (_, state) {
            otpArgs = state.extra as LoginOtpRouteArgs;
            return const Scaffold(body: Text('existing OTP'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: biometrics),
          BlocProvider.value(value: config),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, {bool face = false}) async {
    await tester.tap(find.text(face ? 'face id' : 'fingerprint'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  void completeLogin({bool mfa = false}) {
    login.complete(
      Response<dynamic>(
        requestOptions: RequestOptions(path: Api.loginUrl),
        data: mfa
            ? {'mfa_token': 'test-mfa'}
            : {
                'access_token': 'test-access',
                'refresh_token': 'test-refresh',
                'expires_in': 3600,
                'refresh_expires_in': 86400,
              },
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  testWidgets('fingerprint welcomes only after login and session completion', (
    tester,
  ) async {
    await open(tester);
    await tap(tester);
    expect(find.text('Welcome!'), findsNothing);
    expect(find.text('existing home'), findsNothing);
    expect(biometrics.state.isSessionAuthenticated, isFalse);
    completeLogin();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    verify(() => auth.saveSession(any())).called(1);
    expect(find.text('Welcome!'), findsNothing);
    sessionSaved.complete();
    await tester.pumpAndSettle();
    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('existing home'), findsOneWidget);
    expect(biometrics.state.isSessionAuthenticated, isTrue);
    verify(() => account.fetchAccountInfo(forceRefresh: true)).called(1);
    verify(() => devices.loadDeviceLimits(forceRefresh: true)).called(1);
    verify(() => role.fetchRoleId(456)).called(1);
    await tester.pump();
    expect(find.text('Welcome!'), findsOneWidget);
    await settle(tester);
  });

  for (final face in [false, true]) {
    for (final result in [
      BiometricAuthResult.failed,
      BiometricAuthResult.userRequestedFallback,
      BiometricAuthResult.cancelled,
      BiometricAuthResult.error,
      BiometricAuthResult.biometricsNotAvailable,
      BiometricAuthResult.biometricsNotEnrolled,
      BiometricAuthResult.deviceNotSupported,
    ]) {
      testWidgets('${result.name} face=$face does not welcome or call login', (
        tester,
      ) async {
        await open(tester);
        when(
          () => repository.authenticate(reason: any(named: 'reason')),
        ).thenAnswer((_) async => result);
        await tap(tester, face: face);
        expect(find.text('Welcome!'), findsNothing);
        expect(find.text('existing home'), findsNothing);
        expect(biometrics.state.isSessionAuthenticated, isFalse);
        expect(credentialReads, isEmpty);
        verifyZeroInteractions(network);
        verifyZeroInteractions(auth);
        verifyZeroInteractions(account);
        verifyZeroInteractions(devices);
        verifyZeroInteractions(role);
        expect(
          find.text('Fingerprint not recognized. Please try again.'),
          !face && result == BiometricAuthResult.failed
              ? findsOneWidget
              : findsNothing,
        );
        expect(
          find.text('Face not detected. Try again.'),
          face && result == BiometricAuthResult.failed
              ? findsOneWidget
              : findsNothing,
        );
        expect(
          find.text(
            'Too many failed attempts. Please log in with your password.',
          ),
          findsNothing,
        );
        if (result == BiometricAuthResult.userRequestedFallback) {
          expect(
            find.text('Authentication failed. Please try again.'),
            findsNothing,
          );
        }
        expect(
          tester
              .widget<OutlinedButton>(
                find.widgetWithText(
                  OutlinedButton,
                  face ? 'face id' : 'fingerprint',
                ),
              )
              .onPressed,
          isNotNull,
        );
        await settle(tester);
      });
    }
  }

  testWidgets('Face ID welcomes only after login and session completion', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, face: true);
    expect(find.text('Welcome!'), findsNothing);
    expect(find.text('existing home'), findsNothing);
    expect(biometrics.state.isSessionAuthenticated, isFalse);
    completeLogin();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    verify(() => auth.saveSession(any())).called(1);
    expect(find.text('Welcome!'), findsNothing);
    sessionSaved.complete();
    await tester.pumpAndSettle();
    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('existing home'), findsOneWidget);
    expect(biometrics.state.isSessionAuthenticated, isTrue);
    verify(() => account.fetchAccountInfo(forceRefresh: true)).called(1);
    verify(() => devices.loadDeviceLimits(forceRefresh: true)).called(1);
    verify(() => role.fetchRoleId(456)).called(1);
    await tester.pump();
    expect(find.text('Welcome!'), findsOneWidget);
    await settle(tester);
  });

  for (final face in [false, true]) {
    testWidgets(
      'MFA face=$face keeps OTP navigation without an early welcome',
      (tester) async {
        await open(tester);
        await tap(tester, face: face);
        completeLogin(mfa: true);
        await tester.pumpAndSettle();
        expect(find.text('Welcome!'), findsNothing);
        expect(find.text('existing OTP'), findsOneWidget);
        expect(otpArgs!.mfaToken, 'test-mfa');
        expect(otpArgs!.apiPhoneNumber, '2428011616');
        expect(biometrics.state.isSessionAuthenticated, isFalse);
        verifyZeroInteractions(auth);
      },
    );

    for (final failCompletion in [false, true]) {
      testWidgets(
        'login/completion failure $failCompletion face=$face never welcomes',
        (tester) async {
          await open(tester);
          await tap(tester, face: face);
          if (failCompletion) {
            when(
              () => account.fetchAccountInfo(forceRefresh: true),
            ).thenThrow(Exception('account load failed'));
            completeLogin();
            sessionSaved.complete();
          } else {
            login.completeError(Exception('login failed'));
          }
          await tester.pumpAndSettle();
          expect(find.text('Welcome!'), findsNothing);
          expect(find.text('existing home'), findsNothing);
          expect(
            find.text('Sign-in failed. Please try again.'),
            findsOneWidget,
          );
          expect(biometrics.state.isSessionAuthenticated, isFalse);
          await settle(tester);
        },
      );
    }
  }

  testWidgets('missing cached credentials retains password sign-in fallback', (
    tester,
  ) async {
    credentials.clear();
    await open(tester);
    await tap(tester);
    expect(
      find.text('Please sign in with your password first.'),
      findsOneWidget,
    );
    expect(find.text('Welcome!'), findsNothing);
    verifyZeroInteractions(network);
    verifyZeroInteractions(auth);
    await settle(tester);
  });
}
