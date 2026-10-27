import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:finger_face_security/finger_face_security.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
// Mock the pinned biometric plugin used by finger_face_security.
// ignore: depend_on_referenced_packages
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/view/login_page.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_route_args.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _LocalAuthentication extends LocalAuthentication {
  _LocalAuthentication(this.code);

  final LocalAuthExceptionCode? code;
  int calls = 0;

  @override
  Future<bool> isDeviceSupported() async => true;

  @override
  Future<bool> get canCheckBiometrics async => true;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async => [
    BiometricType.fingerprint,
    BiometricType.face,
  ];

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<Object> authMessages = const [],
    bool biometricOnly = false,
    bool sensitiveTransaction = true,
    bool persistAcrossBackgrounding = false,
  }) async {
    calls++;
    if (code != null) {
      throw LocalAuthException(code: code!);
    }
    return false;
  }
}

class _Network extends Mock implements NetworkService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const row42 = 'Too many failed attempts. Please log in with your password.';
  const row41 = 'Fingerprint not recognized. Please try again.';
  const storageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  late _Network network;
  late AppUiConfigCubit config;
  late FingerFaceSecurityCubit biometrics;
  late _LocalAuthentication localAuth;
  late List<MethodCall> storageCalls;
  LoginOtpRouteArgs? otpArgs;

  setUpAll(() async {
    registerFallbackValue(HttpMethod.post);
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() async {
    await instance.reset();
    SharedPreferences.setMockInitialValues({
      'biometric_enabled': true,
      'biometric_fingerprint_enabled': true,
      'biometric_face_enabled': true,
    });
    storageCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, (call) async {
          storageCalls.add(call);
          return null;
        });
    network = _Network();
    config = AppUiConfigCubit();
    instance.registerSingleton<NetworkService>(network);
    otpArgs = null;
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(storageChannel, null);
    await biometrics.close();
    await config.close();
    await instance.reset();
  });

  Future<void> open(
    WidgetTester tester,
    LocalAuthExceptionCode? code, {
    double width = 390,
  }) async {
    tester.view.physicalSize = Size(width, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    localAuth = _LocalAuthentication(code);
    biometrics = FingerFaceSecurityCubit(
      FingerFaceSecurityRepositoryImpl(
        service: BiometricAuthService(localAuth: localAuth),
      ),
    );
    instance.registerSingleton<FingerFaceSecurityCubit>(biometrics);
    await biometrics.loadBiometricStatus();
    final router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.logIn,
      routes: [
        GoRoute(path: AppRoutes.logIn, builder: (_, _) => const LoginScreen()),
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
      BlocProvider.value(
        value: config,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    storageCalls.clear();
  }

  Future<void> dismissToast(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
  }

  for (final face in [false, true]) {
    for (final code in [
      LocalAuthExceptionCode.temporaryLockout,
      LocalAuthExceptionCode.biometricLockout,
      null,
      LocalAuthExceptionCode.systemCanceled,
      LocalAuthExceptionCode.userRequestedFallback,
    ]) {
      testWidgets('OS $code face=$face preserves login error boundaries', (
        tester,
      ) async {
        await open(tester, code);
        await tester.tap(find.text(face ? 'face id' : 'fingerprint'));
        await tester.pumpAndSettle();

        final lockedOut =
            code == LocalAuthExceptionCode.temporaryLockout ||
            code == LocalAuthExceptionCode.biometricLockout;
        expect(
          find.text(row42),
          lockedOut && !face ? findsOneWidget : findsNothing,
        );
        expect(
          find.text(row41),
          code == null && !face ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('Face not detected. Try again.'),
          code == null && face ? findsOneWidget : findsNothing,
        );
        expect(
          biometrics.state.lastAuthResult,
          lockedOut
              ? BiometricAuthResult.lockedOut
              : code == null
              ? BiometricAuthResult.failed
              : code == LocalAuthExceptionCode.userRequestedFallback
              ? BiometricAuthResult.userRequestedFallback
              : BiometricAuthResult.error,
        );
        expect(
          biometrics.state.errorMessage,
          lockedOut || code == LocalAuthExceptionCode.systemCanceled
              ? 'An authentication error occurred. Please try again.'
              : 'Authentication failed. Please try again.',
        );
        expect(biometrics.state.isSessionAuthenticated, isFalse);
        expect(
          find.text('An authentication error occurred. Please try again.'),
          findsNothing,
        );
        expect(
          find.text('Authentication failed. Please try again.'),
          findsNothing,
        );
        expect(find.text('Welcome!'), findsNothing);
        expect(find.byType(SnackBar), findsNothing);
        expect(find.byType(Dialog), findsNothing);
        expect(find.text('existing OTP'), findsNothing);
        expect(localAuth.calls, 1);
        expect(storageCalls, isEmpty);
        verifyZeroInteractions(network);
        final password = tester.widget<TextField>(find.byType(TextField).last);
        expect(password.enabled, isNot(false));
        expect(password.readOnly, isFalse);
        expect(
          tester
              .widget<ElevatedButton>(
                find.widgetWithText(ElevatedButton, 'sign in'),
              )
              .onPressed,
          isNotNull,
        );

        // Additional rebuilds must not emit another toast or authenticate again.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(
          find.text(row42),
          lockedOut && !face ? findsOneWidget : findsNothing,
        );
        expect(localAuth.calls, 1);
        verifyZeroInteractions(network);
        expect(tester.takeException(), isNull);
        await dismissToast(tester);
      });
    }
  }

  for (final code in [
    LocalAuthExceptionCode.temporaryLockout,
    LocalAuthExceptionCode.biometricLockout,
  ]) {
    for (final width in [390.0, 430.0]) {
      testWidgets('password login succeeds after $code at width $width', (
        tester,
      ) async {
        await http.runWithClient(() async {
          await open(tester, code, width: width);
          when(
            () => network.request<dynamic>(
              Api.loginUrl,
              method: HttpMethod.post,
              data: any(named: 'data'),
              options: any(named: 'options'),
            ),
          ).thenAnswer(
            (_) async => Response<dynamic>(
              requestOptions: RequestOptions(path: Api.loginUrl),
              data: {'mfa_token': 'test-mfa'},
            ),
          );
          await tester.tap(find.text('fingerprint'));
          await tester.pumpAndSettle();
          expect(find.text(row42), findsOneWidget);
          verifyZeroInteractions(network);
          await tester.pump(const Duration(seconds: 5));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField).first, '2428011616');
          await tester.enterText(find.byType(TextField).last, 'test-password');
          await tester.pumpAndSettle();
          tester.testTextInput.hide();
          await tester.pumpAndSettle();
          await tester.tap(find.text('sign in'));
          await tester.pumpAndSettle();
          expect(find.text('existing OTP'), findsOneWidget);
          expect(find.text('OTP sent successfully'), findsOneWidget);
          expect(otpArgs?.mfaToken, 'test-mfa');
          expect(otpArgs?.apiPhoneNumber, '2428011616');
          verify(
            () => network.request<dynamic>(
              Api.loginUrl,
              method: HttpMethod.post,
              data: {
                'Username': '2428011616',
                'Password': 'test-password',
                'Channel': kAuthChannel,
              },
              options: any(named: 'options'),
            ),
          ).called(1);
          verifyNoMoreInteractions(network);
          expect(localAuth.calls, 1);
          expect(tester.takeException(), isNull);
          await dismissToast(tester);
        }, () => MockClient((_) async => http.Response('', 200)));
      });
    }
  }
}
