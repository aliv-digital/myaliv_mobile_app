import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_resend_response_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_route_args.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/base_login_otp_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/theme/login_otp_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/view/login_otp_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/widgets/otp_code_fields.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Repository extends Mock implements BaseLoginOtpRepository {}

class _Connection extends Fake implements InternetConnection {
  bool connected = true;

  @override
  Future<bool> get hasInternetAccess async => connected;
}

class _Analytics extends Fake implements AnalyticsService {
  @override
  Future<void> logLogin({
    required String userId,
    String method = AnalyticsLoginMethod.otp,
  }) async {}

  @override
  Future<void> logLoginFailure({
    required String method,
    required String failureReason,
  }) async {}

  @override
  Future<void> logOtpRequested({String otpChannel = AnalyticsOtpChannel.sms}) async {}

  @override
  Future<void> logOtpVerified({String otpChannel = AnalyticsOtpChannel.sms}) async {}

  @override
  Future<void> logOtpFailed({
    required String failureReason,
    String otpChannel = AnalyticsOtpChannel.sms,
  }) async {}

  @override
  Future<void> logPasswordResetStarted() async {}

  @override
  Future<void> logPasswordResetCompleted() async {}

  @override
  Future<void> logPasswordResetFailed({required String failureReason}) async {}

  @override
  Future<void> setLoggedIn() async {}
}

class _RouteState extends Fake implements GoRouterState {
  @override
  final Object? extra;

  _RouteState(this.extra);
}

class _Context extends Fake implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Repository repository;
  late _Connection connection;
  late AppUiConfigCubit config;
  late GoRouter router;
  LoginOtpBloc? bloc;
  late Completer<LoginOtpResendResponse> response;
  const args = LoginOtpRouteArgs(
    mfaToken: 'original-challenge',
    phoneNumber: '242-765-4321',
    apiPhoneNumber: '2427654321',
  );

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    repository = _Repository();
    connection = _Connection();
    config = AppUiConfigCubit();
    router = AppRouter().router;
    bloc = null;
    response = Completer<LoginOtpResendResponse>();
    when(
      () => repository.resendCode(
        phoneNumber: '2427654321',
        mfaToken: 'original-challenge',
      ),
    ).thenAnswer((_) => response.future);
  });

  tearDown(() async {
    if (!response.isCompleted) {
      response.complete(
        const LoginOtpResendResponse(mfaToken: 'rotated-challenge'),
      );
    }
    await bloc?.close();
    await config.close();
    router.dispose();
  });

  Future<void> open(
    WidgetTester tester, {
    double width = 390,
    String routePath = AppRoutes.forgetPasswordOtp,
  }) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final route = router.configuration.routes.whereType<GoRoute>().singleWhere(
      (route) => route.path == routePath,
    );
    late LoginOtpScreen screen;
    await tester.runAsync(() async {
      response = Completer<LoginOtpResendResponse>();
      screen = route.builder!(_Context(), _RouteState(args)) as LoginOtpScreen;
      bloc = LoginOtpBloc(
        repository: repository,
        appUiConfigCubit: config,
        internetConnection: connection,
        analyticsService: _Analytics(),
        initialMfaToken: screen.initialMfaToken,
        initialPhoneNumber: screen.initialPhoneNumber,
        initialApiPhoneNumber: screen.initialApiPhoneNumber,
        resetValidationOnResend: screen.resetValidationOnResend,
      );
    });
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: rootNavigatorKey,
        home: Builder(
          builder: (context) {
            final provider =
                screen.build(context) as BlocProvider<LoginOtpBloc>;
            return BlocProvider.value(value: bloc!, child: provider.child!);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  List<TextEditingController> controllers(WidgetTester tester) => tester
      .widgetList<TextField>(find.byType(TextField))
      .map((field) => field.controller!)
      .toList();

  int redBorders(WidgetTester tester) => tester
      .widgetList<Container>(
        find.descendant(
          of: find.byType(OtpCodeFields),
          matching: find.byType(Container),
        ),
      )
      .where((container) {
        final decoration = container.decoration;
        return decoration is BoxDecoration &&
            decoration.border is Border &&
            (decoration.border! as Border).top.color ==
                LoginOtpColors.otpBoxBorderError;
      })
      .length;

  Future<void> failValidation(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).first, '123');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('verify'));
    await tester.tap(find.text('verify'));
    await tester.runAsync(() async {
      if (bloc!.state.status != LoginOtpStatus.failure) {
        await bloc!.stream
            .firstWhere((state) => state.status == LoginOtpStatus.failure)
            .timeout(const Duration(seconds: 5));
      }
    });
    await tester.pumpAndSettle();
    expect(bloc!.state.status, LoginOtpStatus.failure);
    expect(bloc!.state.codeFieldError, isTrue);
    expect(redBorders(tester), 6);
    await tester.pump(const Duration(seconds: 3));
  }

  Future<void> waitForResend(
    WidgetTester tester,
    LoginOtpResendStatus status,
  ) async {
    await tester.pump();
    await tester.runAsync(() async {
      if (bloc!.state.resendStatus != status) {
        await bloc!.stream
            .firstWhere((state) => state.resendStatus == status)
            .timeout(const Duration(seconds: 5));
      }
    });
    await tester.pump();
    expect(bloc!.state.resendStatus, status);
  }

  Future<void> resend(WidgetTester tester) async {
    await tester.ensureVisible(find.text('resend code'));
    await tester.tap(find.text('resend code'));
    await waitForResend(tester, LoginOtpResendStatus.loading);
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox.shrink());
  }

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets(
      'Forgot Password resend clears code and red borders at $width',
      (tester) async {
        await open(tester, width: width);
        await failValidation(tester);
        final originalControllers = controllers(tester);
        await resend(tester);
        expect(controllers(tester), orderedEquals(originalControllers));
        expect(
          originalControllers.map((controller) => controller.text),
          everyElement(isEmpty),
        );
        expect(bloc!.state.code, isEmpty);
        expect(bloc!.state.status, LoginOtpStatus.initial);
        expect(bloc!.state.errorType, LoginOtpErrorType.none);
        expect(bloc!.state.errorMessage, isNull);
        expect(redBorders(tester), 0);

        response.complete(
          const LoginOtpResendResponse(mfaToken: 'rotated-challenge'),
        );
        await waitForResend(tester, LoginOtpResendStatus.idle);
        expect(
          find.text('Verification code resent successfully.'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.check), findsOneWidget);
        expect(redBorders(tester), 0);
        expect(bloc!.state.mfaToken, 'rotated-challenge');
        expect(bloc!.state.code, isEmpty);
        verify(
          () => repository.resendCode(
            phoneNumber: '2427654321',
            mfaToken: 'original-challenge',
          ),
        ).called(1);
        expect(tester.takeException(), isNull);
        await finish(tester);
      },
    );
  }

  testWidgets('resend without a prior error still clears all six digits', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pumpAndSettle();
    expect(bloc!.state.code, '123456');
    await resend(tester);
    response.complete(
      const LoginOtpResendResponse(mfaToken: 'rotated-challenge'),
    );
    await waitForResend(tester, LoginOtpResendStatus.idle);
    expect(
      controllers(tester).map((controller) => controller.text),
      everyElement(isEmpty),
    );
    expect(find.text('Verification code resent successfully.'), findsOneWidget);
    await finish(tester);
  });

  testWidgets(
    'a real resend failure is shown without restoring old red borders',
    (tester) async {
      await open(tester);
      await failValidation(tester);
      await resend(tester);
      response.completeError(
        NetworkException('Request timeout. Please try again.'),
      );
      await waitForResend(tester, LoginOtpResendStatus.idle);
      expect(find.text('Request timeout. Please try again.'), findsOneWidget);
      expect(find.text('Verification code resent successfully.'), findsNothing);
      expect(bloc!.state.mfaToken, 'original-challenge');
      expect(bloc!.state.code, isEmpty);
      expect(redBorders(tester), 0);
      await finish(tester);
    },
  );

  testWidgets(
    'offline resend clears stale validation and keeps the retry error',
    (tester) async {
      await open(tester);
      await failValidation(tester);
      connection.connected = false;
      await tester.ensureVisible(find.text('resend code'));
      await tester.tap(find.text('resend code'));
      await tester.runAsync(() async {
        if (bloc!.state.errorMessage != 'No Internet Connection') {
          await bloc!.stream
              .firstWhere(
                (state) => state.errorMessage == 'No Internet Connection',
              )
              .timeout(const Duration(seconds: 5));
        }
      });
      await tester.pumpAndSettle();
      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(find.text('Verification code resent successfully.'), findsNothing);
      expect(bloc!.state.code, isEmpty);
      expect(redBorders(tester), 0);
      verifyNever(
        () => repository.resendCode(
          phoneNumber: any(named: 'phoneNumber'),
          mfaToken: any(named: 'mfaToken'),
        ),
      );
      await finish(tester);
    },
  );

  testWidgets(
    'disabled resend preserves new input while the request is pending',
    (tester) async {
      await open(tester);
      await failValidation(tester);
      await resend(tester);
      await tester.enterText(find.byType(TextField).first, '654321');
      await tester.pumpAndSettle();
      final sending = find.ancestor(
        of: find.text('sending...'),
        matching: find.byType(GestureDetector),
      );
      expect(tester.widget<GestureDetector>(sending.first).onTap, isNull);
      response.complete(
        const LoginOtpResendResponse(mfaToken: 'rotated-challenge'),
      );
      await waitForResend(tester, LoginOtpResendStatus.idle);
      expect(bloc!.state.code, '654321');
      expect(
        controllers(tester).map((controller) => controller.text).join(),
        '654321',
      );
      verify(
        () => repository.resendCode(
          phoneNumber: '2427654321',
          mfaToken: 'original-challenge',
        ),
      ).called(1);
      await finish(tester);
    },
  );

  testWidgets(
    'the login OTP route also clears entered digits and old red borders',
    (tester) async {
      await open(tester, routePath: AppRoutes.loginOtp);
      await failValidation(tester);
      await resend(tester);
      response.complete(
        const LoginOtpResendResponse(mfaToken: 'rotated-challenge'),
      );
      await waitForResend(tester, LoginOtpResendStatus.idle);
      expect(bloc!.state.code, isEmpty);
      expect(bloc!.state.status, LoginOtpStatus.initial);
      expect(redBorders(tester), 0);
      expect(controllers(tester).map((c) => c.text), everyElement(isEmpty));
      await finish(tester);
    },
  );
}
