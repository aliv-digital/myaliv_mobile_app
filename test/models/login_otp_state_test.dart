import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_state.dart';

void main() {
  group('LoginOtpState', () {
    const defaultState = LoginOtpState();

    test('initial values are correct', () {
      expect(defaultState.code, '');
      expect(defaultState.mfaToken, '');
      expect(defaultState.phoneNumber, '');
      expect(defaultState.apiPhoneNumber, '');
      expect(defaultState.status, LoginOtpStatus.initial);
      expect(defaultState.resendStatus, LoginOtpResendStatus.idle);
      expect(defaultState.errorType, LoginOtpErrorType.none);
      expect(defaultState.codeFieldError, false);
      expect(defaultState.errorMessage, isNull);
    });

    test('two identical instances are equal', () {
      const a = LoginOtpState(code: '123456', mfaToken: 'tok');
      const b = LoginOtpState(code: '123456', mfaToken: 'tok');
      expect(a, equals(b));
    });

    test('instances differing by code are not equal', () {
      const a = LoginOtpState(code: '111111');
      const b = LoginOtpState(code: '222222');
      expect(a, isNot(equals(b)));
    });

    test('instances differing by errorType are not equal', () {
      const a = LoginOtpState(errorType: LoginOtpErrorType.none);
      const b = LoginOtpState(errorType: LoginOtpErrorType.invalidCode);
      expect(a, isNot(equals(b)));
    });

    test('copyWith code only changes code field', () {
      const original = LoginOtpState(
        code: 'old',
        mfaToken: 'tok',
        status: LoginOtpStatus.loading,
      );
      final updated = original.copyWith(code: '123456');

      expect(updated.code, '123456');
      expect(updated.mfaToken, 'tok');
      expect(updated.status, LoginOtpStatus.loading);
    });

    test('copyWith status transition is reflected', () {
      const state = LoginOtpState();
      final loading = state.copyWith(status: LoginOtpStatus.loading);
      expect(loading.status, LoginOtpStatus.loading);
    });

    test('copyWith errorType reflects change', () {
      const state = LoginOtpState();
      final withError = state.copyWith(
        status: LoginOtpStatus.failure,
        errorType: LoginOtpErrorType.invalidCode,
        codeFieldError: true,
        errorMessage: 'Invalid OTP',
      );
      expect(withError.errorType, LoginOtpErrorType.invalidCode);
      expect(withError.codeFieldError, true);
      expect(withError.errorMessage, 'Invalid OTP');
    });

    test('copyWith clears errorMessage when passed null', () {
      const state = LoginOtpState(errorMessage: 'some error');
      final cleared = state.copyWith(errorMessage: null);
      expect(cleared.errorMessage, isNull);
    });

    test('resendStatus transitions are reflected', () {
      const state = LoginOtpState();
      final loading = state.copyWith(
        resendStatus: LoginOtpResendStatus.loading,
      );
      expect(loading.resendStatus, LoginOtpResendStatus.loading);

      final done = loading.copyWith(resendStatus: LoginOtpResendStatus.done);
      expect(done.resendStatus, LoginOtpResendStatus.done);
    });

    test('all LoginOtpErrorType values are distinct', () {
      final types = LoginOtpErrorType.values;
      expect(types.toSet().length, types.length);
    });
  });
}
