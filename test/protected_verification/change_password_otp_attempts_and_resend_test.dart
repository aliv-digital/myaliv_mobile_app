import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_state.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_otp_screen.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';

import 'support/change_password_flow_harness.dart';

Future<void> _verifyOtp(
  WidgetTester tester, {
  String code = '123456',
  String? expectedToast,
}) async {
  await tester.enterText(find.byType(TextField).first, code);
  tester.testTextInput.hide();
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  await tester.ensureVisible(find.text('verify'));
  await tester.tap(find.text('verify'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));

  if (expectedToast != null) {
    expect(find.text(expectedToast), findsOneWidget);
  }

  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadChangePasswordTestFonts);

  testWidgets(
    'Change Password OTP keeps its messages and redirects home on wrong attempt six',
    (tester) async {
      await withChangePasswordFlow(tester, (h) async {
        await h.start(tester);
        await h.select(tester);
        expect(find.byType(ActionOtpScreen), findsOneWidget);

        // Configure mock verification error: HTTP 400 TwoFactorKeyInvalid
        h.verificationError = DioException(
          requestOptions: RequestOptions(path: Api.verifyOtpUrl),
          type: DioExceptionType.badResponse,
          response: h.response(Api.verifyOtpUrl, {
            'ErrorCode': 202,
            'ErrorCodeName': 'TwoFactorKeyInvalid',
            'Message': 'Two Factor Key Invalid',
          })..statusCode = 400,
        );

        // Attempts 1 to 5: Each should show "Invalid OTP"
        for (var i = 1; i <= 5; i++) {
          await _verifyOtp(tester, expectedToast: 'Invalid OTP');
          expect(find.byType(ActionOtpScreen), findsOneWidget);
          expect(h.otp(tester).state.status, LoginOtpStatus.failure);
          expect(h.otp(tester).state.errorMessage, 'Invalid OTP');
        }

        // Attempt 6: Must show the exact required message
        await _verifyOtp(
          tester,
          expectedToast: 'Too many failed OTP attempts. Please try again.',
        );
        expect(find.byType(ActionOtpScreen), findsNothing);
        expect(find.text('home destination'), findsOneWidget);
        expect(h.router.canPop(), isFalse);
        expect(h.verifications, 6);
        expect(h.saves, 0);
        expect(h.updates, 0);
      });
    },
  );

  testWidgets(
    'Change Password OTP: non-OTP errors (network, timeout, 500, expired) do NOT increment failure counter',
    (tester) async {
      await withChangePasswordFlow(tester, (h) async {
        await h.start(tester);
        await h.select(tester);

        h.verificationError = DioException(
          requestOptions: RequestOptions(path: Api.verifyOtpUrl),
          type: DioExceptionType.badResponse,
          response: h.response(Api.verifyOtpUrl, {
            'ErrorCode': 202,
            'ErrorCodeName': 'TwoFactorKeyInvalid',
            'Message': 'Two Factor Key Invalid',
          })..statusCode = 400,
        );

        // 4 consecutive incorrect attempts
        for (var i = 1; i <= 4; i++) {
          await _verifyOtp(tester, expectedToast: 'Invalid OTP');
          expect(h.otp(tester).state.errorMessage, 'Invalid OTP');
        }

        // Non-OTP error: Timeout
        h.verificationError = DioException(
          requestOptions: RequestOptions(path: Api.verifyOtpUrl),
          type: DioExceptionType.connectionTimeout,
        );
        await _verifyOtp(tester);
        expect(
          h.otp(tester).state.errorMessage,
          isNot('Too many failed OTP attempts. Please try again.'),
        );

        // Non-OTP error: Server error (HTTP 500)
        h.verificationError = DioException(
          requestOptions: RequestOptions(path: Api.verifyOtpUrl),
          type: DioExceptionType.badResponse,
          response: h.response(Api.verifyOtpUrl, {
            'Message': 'Internal server error',
          })..statusCode = 500,
        );
        await _verifyOtp(tester);
        expect(
          h.otp(tester).state.errorMessage,
          isNot('Too many failed OTP attempts. Please try again.'),
        );

        // Non-OTP error: Expired OTP (ErrorCode 203)
        h.verificationError = DioException(
          requestOptions: RequestOptions(path: Api.verifyOtpUrl),
          type: DioExceptionType.badResponse,
          response: h.response(Api.verifyOtpUrl, {
            'ErrorCode': 203,
            'ErrorCodeName': 'TwoFactorKeyExpired',
            'Message': 'OTP expired',
          })..statusCode = 400,
        );
        await _verifyOtp(tester);
        expect(
          h.otp(tester).state.errorMessage,
          isNot('Too many failed OTP attempts. Please try again.'),
        );

        // Now resume incorrect attempts: 5th confirmed failure
        h.verificationError = DioException(
          requestOptions: RequestOptions(path: Api.verifyOtpUrl),
          type: DioExceptionType.badResponse,
          response: h.response(Api.verifyOtpUrl, {
            'ErrorCode': 202,
            'ErrorCodeName': 'TwoFactorKeyInvalid',
            'Message': 'Two Factor Key Invalid',
          })..statusCode = 400,
        );
        await _verifyOtp(tester, expectedToast: 'Invalid OTP');
        expect(h.otp(tester).state.errorMessage, 'Invalid OTP');

        // 6th confirmed failure: Now triggers the lockout message
        await _verifyOtp(
          tester,
          expectedToast: 'Too many failed OTP attempts. Please try again.',
        );
        expect(find.text('home destination'), findsOneWidget);
        expect(h.verifications, 9);
      });
    },
  );

  testWidgets(
    'Change Password OTP: tapping Resend Code immediately clears all visible digits and BLoC state',
    (tester) async {
      await withChangePasswordFlow(tester, (h) async {
        await h.start(tester);
        await h.select(tester);
        expect(find.byType(ActionOtpScreen), findsOneWidget);

        // Enter 6 digits
        await tester.enterText(find.byType(TextField).first, '123456');
        tester.testTextInput.hide();
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        expect(h.otp(tester).state.code, '123456');

        // Tap resend code
        await tester.ensureVisible(find.text('resend code'));
        await tester.tap(find.text('resend code'));
        await tester.pump();

        // Immediately, all text fields should be empty and BLoC code cleared
        final textFields = tester.widgetList<TextField>(find.byType(TextField));
        for (final tf in textFields) {
          expect(tf.controller?.text, isEmpty);
        }
        expect(h.otp(tester).state.code, isEmpty);

        await tester.pumpAndSettle();
      });
    },
  );

  testWidgets(
    'Change Password OTP: successful resend resets consecutive failure counter',
    (tester) async {
      await withChangePasswordFlow(tester, (h) async {
        await h.start(tester);
        await h.select(tester);

        h.verificationError = DioException(
          requestOptions: RequestOptions(path: Api.verifyOtpUrl),
          type: DioExceptionType.badResponse,
          response: h.response(Api.verifyOtpUrl, {
            'ErrorCode': 202,
            'ErrorCodeName': 'TwoFactorKeyInvalid',
            'Message': 'Two Factor Key Invalid',
          })..statusCode = 400,
        );

        // 5 consecutive incorrect attempts
        for (var i = 1; i <= 5; i++) {
          await _verifyOtp(tester, expectedToast: 'Invalid OTP');
          expect(h.otp(tester).state.errorMessage, 'Invalid OTP');
        }

        // Tap resend code -> rotates challenge
        await tester.ensureVisible(find.text('resend code'));
        await tester.tap(find.text('resend code'));
        await tester.pumpAndSettle();

        // Now attempts should start fresh from 1: attempts 1-5 show "Invalid OTP"
        for (var i = 1; i <= 5; i++) {
          await _verifyOtp(tester, expectedToast: 'Invalid OTP');
          expect(h.otp(tester).state.errorMessage, 'Invalid OTP');
        }

        // 6th attempt on new challenge triggers message
        await _verifyOtp(
          tester,
          expectedToast: 'Too many failed OTP attempts. Please try again.',
        );
        expect(find.text('home destination'), findsOneWidget);
        expect(h.verifications, 11);
      });
    },
  );
}
