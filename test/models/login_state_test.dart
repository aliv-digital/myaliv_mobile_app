import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/bloc/auth_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/model/login_country_selection.dart';

void main() {
  group('LoginState', () {
    const defaultState = LoginState();

    test('initial values are correct', () {
      expect(defaultState.phone, '');
      expect(defaultState.password, '');
      expect(defaultState.status, LoginStatus.initial);
      expect(defaultState.outcome, LoginOutcome.none);
      expect(defaultState.errorMessage, isNull);
      expect(defaultState.mfaToken, isNull);
      expect(defaultState.phoneFieldError, false);
      expect(defaultState.passwordFieldError, false);
      expect(defaultState.errorToastId, 0);
      expect(
        defaultState.selectedCountry,
        LoginCountrySelection.defaultBahamas,
      );
    });

    test('two identical instances are equal', () {
      const a = LoginState(phone: '2421234567', password: 'secret');
      const b = LoginState(phone: '2421234567', password: 'secret');
      expect(a, equals(b));
    });

    test('instances differing by phone are not equal', () {
      const a = LoginState(phone: '2421234567');
      const b = LoginState(phone: '2429999999');
      expect(a, isNot(equals(b)));
    });

    test('instances differing by status are not equal', () {
      const a = LoginState(status: LoginStatus.loading);
      const b = LoginState(status: LoginStatus.success);
      expect(a, isNot(equals(b)));
    });

    test('copyWith phone only changes phone field', () {
      const original = LoginState(
        phone: 'old',
        password: 'pass',
        status: LoginStatus.loading,
      );
      final updated = original.copyWith(phone: 'new');

      expect(updated.phone, 'new');
      expect(updated.password, 'pass');
      expect(updated.status, LoginStatus.loading);
    });

    test('copyWith with no args returns equal state', () {
      const state = LoginState(phone: '242', password: 'pw');
      expect(state.copyWith(), equals(state));
    });

    test('copyWith clears nullable fields via sentinel', () {
      const state = LoginState(errorMessage: 'error', mfaToken: 'tok');
      final cleared = state.copyWith(errorMessage: null, mfaToken: null);
      expect(cleared.errorMessage, isNull);
      expect(cleared.mfaToken, isNull);
    });

    test('copyWith preserves errorMessage when not passed', () {
      const state = LoginState(errorMessage: 'oops');
      final updated = state.copyWith(phone: 'new');
      expect(updated.errorMessage, 'oops');
    });

    test('errorToastId increments correctly', () {
      const state = LoginState(errorToastId: 2);
      final updated = state.copyWith(errorToastId: state.errorToastId + 1);
      expect(updated.errorToastId, 3);
    });

    test('outcome transitions are preserved in copyWith', () {
      const state = LoginState();
      final mfa = state.copyWith(
        status: LoginStatus.success,
        outcome: LoginOutcome.needsOtp,
        mfaToken: 'token123',
      );
      expect(mfa.outcome, LoginOutcome.needsOtp);
      expect(mfa.mfaToken, 'token123');
    });
  });
}
