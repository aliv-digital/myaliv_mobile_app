import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_resend_response_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/base_login_otp_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/view/login_otp_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/theme/login_otp_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/widgets/otp_code_fields.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class _Repository extends Mock implements BaseLoginOtpRepository {}

class _Connected extends Fake implements InternetConnection {
  bool connected = true;
  Completer<bool>? pending;

  @override
  Future<bool> get hasInternetAccess =>
      pending?.future ?? Future.value(connected);
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
  Future<void> logOtpRequested({
    String otpChannel = AnalyticsOtpChannel.sms,
  }) async {}

  @override
  Future<void> logOtpVerified({
    String otpChannel = AnalyticsOtpChannel.sms,
  }) async {}

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

void main() {
  late _Repository repository;
  late AppUiConfigCubit config;
  late LoginOtpBloc bloc;
  late Completer<LoginOtpResendResponse> response;
  late _Connected connection;

  setUp(() {
    repository = _Repository();
    config = AppUiConfigCubit();
    response = Completer<LoginOtpResendResponse>();
    connection = _Connected();
    when(
      () => repository.resendCode(
        phoneNumber: '2427654321',
        mfaToken: 'original-challenge',
      ),
    ).thenAnswer((_) => response.future);
    bloc = LoginOtpBloc(
      repository: repository,
      appUiConfigCubit: config,
      internetConnection: connection,
      analyticsService: _Analytics(),
      initialMfaToken: 'original-challenge',
      initialApiPhoneNumber: '2427654321',
    );
  });

  tearDown(() async {
    await bloc.close();
    await config.close();
  });

  Future<void> pumpView(
    WidgetTester tester, {
    required bool passwordLogin,
  }) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: rootNavigatorKey,
        home: Builder(
          builder: (context) {
            final screen =
                LoginOtpScreen(clearCodeOnResend: passwordLogin).build(context)
                    as BlocProvider<LoginOtpBloc>;
            return BlocProvider.value(value: bloc, child: screen.child!);
          },
        ),
      ),
    );
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pumpAndSettle();
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    expect(bloc.state.code, '123456');
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
    await tester.enterText(find.byType(TextField).last, '');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('verify'));
    await tester.tap(find.text('verify'));
    await tester.runAsync(() async {
      if (bloc.state.status != LoginOtpStatus.failure) {
        await bloc.stream
            .firstWhere((state) => state.status == LoginOtpStatus.failure)
            .timeout(const Duration(seconds: 5));
      }
    });
    await tester.pumpAndSettle();
    expect(bloc.state.status, LoginOtpStatus.failure);
    expect(redBorders(tester), 6);
    await tester.pump(const Duration(seconds: 3));
  }

  Future<void> awaitResend(
    WidgetTester tester,
    LoginOtpResendStatus status,
  ) async {
    await tester.runAsync(() async {
      if (bloc.state.resendStatus != status) {
        await bloc.stream
            .firstWhere((state) => state.resendStatus == status)
            .timeout(const Duration(seconds: 5));
      }
    });
    await tester.pump();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox.shrink());
  }

  for (final succeeds in [true, false]) {
    testWidgets(
      'password login clears immediately and stays empty after resend ${succeeds ? 'success' : 'failure'}',
      (tester) async {
        await pumpView(tester, passwordLogin: true);
        await failValidation(tester);
        final originalControllers = controllers(tester);
        final resend = find
            .ancestor(
              of: find.text('resend code'),
              matching: find.byType(GestureDetector),
            )
            .first;
        // Invoke the actual enabled callback and assert before any pump/API result.
        tester.widget<GestureDetector>(resend).onTap!();
        expect(originalControllers.map((c) => c.text), everyElement(isEmpty));
        expect(bloc.state.mfaToken, 'original-challenge');
        await awaitResend(tester, LoginOtpResendStatus.loading);
        verify(
          () => repository.resendCode(
            phoneNumber: '2427654321',
            mfaToken: 'original-challenge',
          ),
        ).called(1);
        expect(bloc.state.resendStatus, LoginOtpResendStatus.loading);
        expect(controllers(tester), orderedEquals(originalControllers));
        expect(bloc.state.code, isEmpty);
        expect(bloc.state.codeFieldError, isFalse);
        expect(bloc.state.errorMessage, isNull);
        expect(redBorders(tester), 0);

        if (succeeds) {
          response.complete(
            const LoginOtpResendResponse(mfaToken: 'rotated-challenge'),
          );
        } else {
          response.completeError(
            NetworkException('Two Factor Key Invalid', statusCode: 400),
          );
        }
        await awaitResend(tester, LoginOtpResendStatus.idle);
        expect(controllers(tester).map((c) => c.text), everyElement(isEmpty));
        expect(bloc.state.code, isEmpty);
        expect(bloc.state.resendStatus, LoginOtpResendStatus.idle);
        expect(redBorders(tester), 0);
        expect(
          bloc.state.mfaToken,
          succeeds ? 'rotated-challenge' : 'original-challenge',
        );
        expect(
          find.text(
            succeeds
                ? 'Verification code resent successfully.'
                : 'Two Factor Key Invalid',
          ),
          findsOneWidget,
        );
        await tester.pump(const Duration(seconds: 3));
        await tester.ensureVisible(find.text('verify'));
        final validation = bloc.stream.firstWhere(
          (state) => state.errorType == LoginOtpErrorType.emptyCode,
        );
        await tester.tap(find.text('verify'));
        await tester.runAsync(() async {
          await validation.timeout(const Duration(seconds: 5));
        });
        await tester.pump();
        expect(bloc.state.errorType, LoginOtpErrorType.emptyCode);
        expect(bloc.state.errorMessage, 'Please enter the code');
        await tester.pump();
        expect(find.text('Please enter the code'), findsOneWidget);
        expect(controllers(tester).map((c) => c.text), everyElement(isEmpty));
        verifyNever(
          () => repository.verifyCode(
            phoneNumber: any(named: 'phoneNumber'),
            mfaToken: any(named: 'mfaToken'),
            otpCode: any(named: 'otpCode'),
          ),
        );
        await finish(tester);
      },
    );

    testWidgets(
      'non-password flow clears digits and red borders before resend ${succeeds ? 'success' : 'failure'}',
      (tester) async {
        await pumpView(tester, passwordLogin: false);
        await failValidation(tester);
        await tester.ensureVisible(find.text('resend code'));
        await tester.tap(find.text('resend code'));
        await awaitResend(tester, LoginOtpResendStatus.loading);
        expect(bloc.state.code, isEmpty);
        expect(controllers(tester).map((c) => c.text), everyElement(isEmpty));
        expect(bloc.state.status, LoginOtpStatus.initial);
        expect(bloc.state.codeFieldError, isFalse);
        expect(bloc.state.errorMessage, isNull);
        expect(redBorders(tester), 0);
        if (succeeds) {
          response.complete(
            const LoginOtpResendResponse(mfaToken: 'rotated-challenge'),
          );
        } else {
          response.completeError(Exception('Two Factor Key Invalid'));
        }
        await awaitResend(tester, LoginOtpResendStatus.idle);
        expect(bloc.state.code, isEmpty);
        expect(controllers(tester).map((c) => c.text), everyElement(isEmpty));
        expect(redBorders(tester), 0);
        await finish(tester);
      },
    );
  }

  testWidgets(
    'resend clears old input/errors before connectivity is resolved',
    (tester) async {
      await pumpView(tester, passwordLogin: false);
      await failValidation(tester);
      final connectivity = Completer<bool>();
      connection.pending = connectivity;
      await tester.ensureVisible(find.text('resend code'));
      await tester.tap(find.text('resend code'));
      await tester.runAsync(() async {
        if (bloc.state.code.isNotEmpty) {
          await bloc.stream
              .firstWhere((state) => state.code.isEmpty)
              .timeout(const Duration(seconds: 5));
        }
      });
      await tester.pumpAndSettle();
      expect(bloc.state.code, isEmpty);
      expect(bloc.state.codeFieldError, isFalse);
      expect(bloc.state.errorMessage, isNull);
      expect(controllers(tester).map((c) => c.text), everyElement(isEmpty));
      expect(redBorders(tester), 0);
      verifyNever(
        () => repository.resendCode(
          phoneNumber: any(named: 'phoneNumber'),
          mfaToken: any(named: 'mfaToken'),
        ),
      );
      connectivity.complete(false);
      await tester.runAsync(() async {
        if (bloc.state.errorMessage != 'No Internet Connection') {
          await bloc.stream
              .firstWhere(
                (state) => state.errorMessage == 'No Internet Connection',
              )
              .timeout(const Duration(seconds: 5));
        }
      });
      await tester.pumpAndSettle();
      expect(bloc.state.errorMessage, 'No Internet Connection');
      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(redBorders(tester), 0);
      expect(bloc.state.mfaToken, 'original-challenge');
      await finish(tester);
    },
  );

  testWidgets(
    'clearing resend presentation retains wrong-attempt count on failure',
    (tester) async {
      when(
        () => repository.verifyCode(
          phoneNumber: any(named: 'phoneNumber'),
          mfaToken: any(named: 'mfaToken'),
          otpCode: any(named: 'otpCode'),
        ),
      ).thenThrow(
        NetworkException(
          'Two Factor Key Invalid',
          statusCode: 400,
          data: {'ErrorCode': 202, 'ErrorCodeName': 'TwoFactorKeyInvalid'},
        ),
      );
      await pumpView(tester, passwordLogin: false);
      await tester.ensureVisible(find.text('verify'));
      await tester.tap(find.text('verify'));
      await tester.runAsync(() async {
        if (bloc.state.status != LoginOtpStatus.failure) {
          await bloc.stream
              .firstWhere((state) => state.status == LoginOtpStatus.failure)
              .timeout(const Duration(seconds: 5));
        }
      });
      await tester.pumpAndSettle();
      expect(bloc.state.incorrectAttempts, 1);
      expect(redBorders(tester), 6);
      await tester.pump(const Duration(seconds: 3));
      await tester.ensureVisible(find.text('resend code'));
      await tester.tap(find.text('resend code'));
      await awaitResend(tester, LoginOtpResendStatus.loading);
      expect(bloc.state.incorrectAttempts, 1);
      expect(bloc.state.code, isEmpty);
      expect(redBorders(tester), 0);
      response.completeError(NetworkException('Request timeout'));
      await awaitResend(tester, LoginOtpResendStatus.idle);
      expect(bloc.state.incorrectAttempts, 1);
      expect(bloc.state.mfaToken, 'original-challenge');
      expect(bloc.state.errorMessage, 'Request timeout');
      expect(redBorders(tester), 0);
      await finish(tester);
    },
  );

  testWidgets(
    'disabled resend does not clear newly entered code or send another request',
    (tester) async {
      await pumpView(tester, passwordLogin: true);
      await tester.ensureVisible(find.text('resend code'));
      await tester.tap(find.text('resend code'));
      await awaitResend(tester, LoginOtpResendStatus.loading);
      await tester.enterText(find.byType(TextField).first, '654321');
      await tester.pumpAndSettle();
      final sending = find
          .ancestor(
            of: find.text('sending...'),
            matching: find.byType(GestureDetector),
          )
          .first;
      expect(tester.widget<GestureDetector>(sending).onTap, isNull);
      expect(bloc.state.code, '654321');
      verify(
        () => repository.resendCode(
          phoneNumber: '2427654321',
          mfaToken: 'original-challenge',
        ),
      ).called(1);
      response.complete(
        const LoginOtpResendResponse(mfaToken: 'rotated-challenge'),
      );
      await awaitResend(tester, LoginOtpResendStatus.idle);
      expect(bloc.state.code, '654321');
      expect(controllers(tester).map((c) => c.text).join(), '654321');
      await finish(tester);
    },
  );
}
