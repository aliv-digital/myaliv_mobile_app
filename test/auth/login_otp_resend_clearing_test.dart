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
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

class _Repository extends Mock implements BaseLoginOtpRepository {}

class _Connected extends Fake implements InternetConnection {
  @override
  Future<bool> get hasInternetAccess async => true;
}

class _Analytics extends Fake implements AnalyticsService {}

void main() {
  late _Repository repository;
  late AppUiConfigCubit config;
  late LoginOtpBloc bloc;
  late Completer<LoginOtpResendResponse> response;

  setUp(() {
    repository = _Repository();
    config = AppUiConfigCubit();
    response = Completer<LoginOtpResendResponse>();
    when(
      () => repository.resendCode(
        phoneNumber: '2427654321',
        mfaToken: 'original-challenge',
      ),
    ).thenAnswer((_) => response.future);
    bloc = LoginOtpBloc(
      repository: repository,
      appUiConfigCubit: config,
      internetConnection: _Connected(),
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
      'non-password flow preserves entered code after resend ${succeeds ? 'success' : 'failure'}',
      (tester) async {
        await pumpView(tester, passwordLogin: false);
        await tester.ensureVisible(find.text('resend code'));
        await tester.tap(find.text('resend code'));
        await awaitResend(tester, LoginOtpResendStatus.loading);
        expect(bloc.state.code, '123456');
        if (succeeds) {
          response.complete(
            const LoginOtpResendResponse(mfaToken: 'rotated-challenge'),
          );
        } else {
          response.completeError(Exception('Two Factor Key Invalid'));
        }
        await awaitResend(tester, LoginOtpResendStatus.idle);
        expect(bloc.state.code, '123456');
        expect(controllers(tester).map((c) => c.text).join(), '123456');
        await finish(tester);
      },
    );
  }

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
