import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/bloc/change_password_prepaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/widgets/change_password_prepaid_password_field.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/myProfile/prepaid/bloc/my_profile_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/myProfile/prepaid/bloc/my_profile_prepaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/myProfile/prepaid/view/my_profile_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_otp_screen.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verified_result.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultBackButton.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import 'support/change_password_flow_harness.dart';

void flowTest(
  String name,
  Future<void> Function(WidgetTester, ChangePasswordFlowHarness) body,
) {
  testWidgets(
    name,
    (tester) => withChangePasswordFlow(tester, (h) => body(tester, h)),
  );
}

void main() {
  setUpAll(loadChangePasswordTestFonts);

  for (final failure in [
    'wrong',
    'expired',
    'backend',
    'network',
    'offline',
    'storage',
    'malformed',
  ]) {
    flowTest('$failure OTP cannot open the form', (tester, h) async {
      await h.start(tester);
      await h.select(tester);
      if (failure == 'storage') {
        h.failSave = true;
      } else if (failure == 'offline') {
        h.offline = true;
      } else if (failure == 'malformed') {
        h.pendingVerification = Completer()
          ..complete(h.response(Api.verifyOtpUrl, {'Success': true}));
      } else {
        h.verificationError = DioException(
          requestOptions: RequestOptions(path: Api.verifyOtpUrl),
          type: failure == 'network'
              ? DioExceptionType.connectionError
              : DioExceptionType.badResponse,
          response: h.response(Api.verifyOtpUrl, {
            'Message': failure == 'expired' ? 'OTP expired' : '$failure OTP',
          })..statusCode = failure == 'backend' ? 500 : 401,
        );
      }
      await h.verify(tester);
      h.expectLocked();
      expect(find.byType(ActionOtpScreen), findsOneWidget);
      expect(h.otp(tester).state.status, LoginOtpStatus.failure);
      expect(h.saves, failure == 'storage' ? 1 : 0);
    });
  }

  for (final back in ['header', 'system']) {
    flowTest('$back OTP Back grants nothing and re-entry challenges again', (
      tester,
      h,
    ) async {
      await h.start(tester);
      await h.select(tester);
      if (back == 'header') {
        await tester.tap(
          find.descendant(
            of: find.byType(DefaultBackButton),
            matching: find.byType(IconButton),
          ),
        );
      } else {
        await tester.binding.handlePopRoute();
      }
      await tester.pumpAndSettle();
      h.expectLocked();
      expect(find.byType(MyProfilePrepaidScreen), findsOneWidget);
      await h.select(tester);
      expect(h.challenges, 2);
      h.expectLocked();
    });
  }

  flowTest('challenge failure returns to Profile without form access', (
    tester,
    h,
  ) async {
    h.challengeError = StateError('synthetic challenge failure');
    await h.start(tester);
    await h.select(tester);
    h.expectLocked();
    expect(find.byType(MyProfilePrepaidScreen), findsOneWidget);
    expect(h.verifications, 0);
  });

  for (final during in ['OTP', 'form']) {
    for (final change in [
      'logout',
      'session replacement',
      'account switch',
      'device switch',
      'away and back',
    ]) {
      flowTest('$change during $during invalidates authorization', (
        tester,
        h,
      ) async {
        if (during == 'OTP') {
          h.pendingVerification = Completer();
        }
        await h.start(tester);
        await h.select(tester);
        await h.verify(tester);
        switch (change) {
          case 'logout':
            h.current = null;
          case 'session replacement':
            h.current = testSession();
          case 'account switch':
            h.changeAccount(2);
          case 'device switch':
            h.changeDevice(456);
          case 'away and back':
            final original = h.accountState;
            h.changeAccount(2);
            h.accountState = original;
            h.accountChanges.add(original);
        }
        if (during == 'OTP') {
          h.pendingVerification!.complete(h.verificationResponse());
          await tester.pump();
          await tester.pump(const Duration(seconds: 2));
          await tester.pumpAndSettle();
          h.expectLocked();
          expect(h.saves, 0);
          h.router.pop();
        } else {
          final form = h.formBloc(tester);
          form.add(const ChangePasswordPrepaidNewChanged('Synthetic123!'));
          form.add(const ChangePasswordPrepaidConfirmChanged('Synthetic123!'));
          form.add(const ChangePasswordPrepaidSubmitPressed());
        }
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
        h.expectLocked();
        expect(h.challenges, 1);
        expect(find.byType(MyProfilePrepaidScreen), findsOneWidget);
      });
    }
  }

  flowTest('abandoned OTP response cannot authorize a later route', (
    tester,
    h,
  ) async {
    h.pendingVerification = Completer();
    await h.start(tester);
    await h.select(tester);
    await h.verify(tester);
    h.router.go(AppRoutes.myProfilePrepaidScreen);
    await tester.pumpAndSettle();
    h.pendingVerification!.complete(h.verificationResponse());
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    h.expectLocked();
    expect(h.saves, 0);
    h.pendingVerification = null;
    await h.select(tester);
    h.expectLocked();
    expect(h.challenges, 2);
  });

  flowTest('session replacement after OTP persistence cannot expose the form', (
    tester,
    h,
  ) async {
    await h.start(tester);
    await h.select(tester);
    final otp = h.otp(tester);
    otp.add(const LoginOtpCodeChanged('123456'));
    await tester.pump();
    otp.add(const LoginOtpSubmitted());
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
    expect(h.saves, 1);
    h.current = testSession();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    h.expectLocked();
    expect(find.byType(MyProfilePrepaidScreen), findsOneWidget);
  });

  flowTest(
    'Back from authorized form revokes access; route rebuild retains only its own journey',
    (tester, h) async {
      await h.start(tester);
      await h.select(tester);
      await h.verify(tester);
      h.config.showCurrentPlansView();
      await tester.pumpAndSettle();
      expect(h.challenges, 1);
      expect(find.byType(ChangePasswordPrepaidPasswordField), findsNWidgets(2));
      h.router.pop();
      await tester.pumpAndSettle();
      await h.select(tester);
      h.expectLocked();
      expect(h.challenges, 2);
      expect(find.byType(ActionOtpScreen), findsOneWidget);
    },
  );

  for (final alternative in ['deep link', 'forged extras', 'legacy OTP']) {
    flowTest('$alternative cannot bypass the destination gate', (
      tester,
      h,
    ) async {
      await h.start(
        tester,
        location: alternative == 'deep link'
            ? AppRoutes.changePasswordPrepaidScreen
            : alternative == 'legacy OTP'
            ? AppRoutes.otpProfilePrepaidScreen
            : AppRoutes.myProfilePrepaidScreen,
      );
      if (alternative == 'forged extras') {
        h.router.push(
          AppRoutes.changePasswordPrepaidScreen,
          extra: ActionVerifiedResult<ProtectedAccountAction>(
            attemptId: Object(),
            paymentMethod: ProtectedAccountAction.changePassword,
            canConsume: () => true,
          ),
        );
      } else if (alternative == 'legacy OTP') {
        await tester.ensureVisible(find.text('verify'));
        await tester.tap(find.text('verify'));
      }
      await tester.pumpAndSettle();
      h.expectLocked();
      expect(h.challenges, 1);
      expect(find.byType(ActionOtpScreen), findsOneWidget);
    });
  }

  flowTest('unauthenticated direct route fails closed', (tester, h) async {
    h.current = null;
    await h.start(tester, location: AppRoutes.changePasswordPrepaidScreen);
    h.expectLocked();
    expect(h.challenges, 0);
    expect(find.text('home destination'), findsOneWidget);
  });

  for (final failure in ['backend', 'network']) {
    flowTest(
      '$failure update error preserves copy; consumed result cannot update twice',
      (tester, h) async {
        h.updateSuccess = false;
        if (failure == 'network') {
          h.updateError = StateError('synthetic connection error');
        }
        await h.start(tester);
        await h.select(tester);
        await h.verify(tester);
        await h.enterPasswords(tester);
        await h.submit(tester);
        expect(
          find.text('failed to update password. please try again.'),
          findsOneWidget,
        );
        expect(
          find.text('Your password has been changed successfully.'),
          findsNothing,
        );
        expect(h.challenges, 1);
        expect(h.updates, 1);
        await h.submit(tester);
        expect(h.updates, 1);
        expect(h.verifications, 1);
        expect(find.byType(MyProfilePrepaidScreen), findsOneWidget);
      },
    );
  }
}
