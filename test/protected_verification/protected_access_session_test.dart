import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/common/verification/protected_account_access_verification_session.dart';
import 'package:myaliv_mobile_app/app/common/verification/protected_access_session_completion_service.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

class _Auth extends Mock implements AuthManager {}

TokenSession _token() => TokenSession(
  accessToken: 'synthetic-access',
  refreshToken: 'synthetic-refresh',
  accessExpiresAt: DateTime.utc(2030),
  refreshExpiresAt: DateTime.utc(2031),
);

void main() {
  setUpAll(() => registerFallbackValue(_token()));
  late DateTime now;
  Object? identity;
  late ProtectedAccountAccessVerificationSession access;
  setUp(() {
    now = DateTime.utc(2026, 10, 7, 15);
    identity = (1, 'subscriber');
    access = ProtectedAccountAccessVerificationSession(
      now: () => now,
      accountContext: () => identity,
    );
  });
  tearDown(() => access.dispose());

  test('cold instance has no persisted grant', () {
    expect(access.isVerified, isFalse);
    expect(access.expiresAt, isNull);
    access.markVerified();
    final cold = ProtectedAccountAccessVerificationSession(
      accountContext: () => identity,
    );
    expect(cold.isVerified, isFalse);
    cold.dispose();
  });

  test(
    'fixed window expires exactly at 20 minutes and reads never slide it',
    () {
      access.markVerified();
      final expiry = now.add(const Duration(minutes: 20));
      for (final minutes in [5, 12, 19]) {
        now = DateTime.utc(2026, 10, 7, 15, minutes);
        expect(access.isVerified, isTrue);
        expect(access.expiresAt, expiry);
      }
      now = expiry;
      expect(access.isVerified, isFalse);
      now = expiry.add(const Duration(seconds: 1));
      expect(access.isVerified, isFalse);
    },
  );

  test('background elapsed real time counts without lifecycle timers', () {
    access.markVerified();
    now = now.add(const Duration(minutes: 15));
    expect(access.isVerified, isTrue);
    now = now.add(const Duration(minutes: 10));
    expect(access.isVerified, isFalse);
  });

  test('reset invalidates grant and pending verification generation', () {
    final generation = access.generation;
    access.markVerified();
    access.reset();
    expect(access.isVerified, isFalse);
    expect(access.expiresAt, isNull);
    expect(access.markVerified(expectedGeneration: generation), isFalse);
  });

  test('account switch clears grant without hard logout', () {
    access.markVerified();
    final generation = access.generation;
    identity = (2, 'other');
    expect(access.isVerified, isFalse);
    identity = (1, 'subscriber');
    expect(access.isVerified, isFalse);
    expect(access.markVerified(expectedGeneration: generation), isFalse);
  });

  test(
    'account stream invalidates even if switched away and back before entry',
    () async {
      final changes = StreamController<Object?>();
      final scoped = ProtectedAccountAccessVerificationSession(
        now: () => now,
        accountContext: () => identity,
        accountChanges: changes.stream,
      );
      scoped.markVerified();
      identity = (2, 'other');
      changes.add(identity);
      await Future<void>.delayed(Duration.zero);
      identity = (1, 'subscriber');
      changes.add(identity);
      await Future<void>.delayed(Duration.zero);
      expect(scoped.isVerified, isFalse);
      scoped.dispose();
      await changes.close();
    },
  );

  test('same account refresh does not invalidate or extend access', () {
    access.markVerified();
    final expiry = access.expiresAt;
    final generation = access.generation;
    identity = (1, 'subscriber');
    expect(access.isVerified, isTrue);
    expect(access.generation, generation);
    expect(access.expiresAt, expiry);
  });

  test('no authenticated identity cannot receive a grant', () {
    identity = null;
    expect(access.markVerified(), isFalse);
    expect(access.isVerified, isFalse);
  });

  for (final outcome in [
    'success',
    'save failure',
    'logout',
    'account switch',
  ]) {
    test('$outcome: access starts only when persistence completes', () async {
      final auth = _Auth();
      final config = AppUiConfigCubit();
      final pendingSave = Completer<void>();
      when(() => auth.saveSession(any())).thenAnswer((_) => pendingSave.future);
      final service = ProtectedAccessSessionCompletionService(
        authManager: auth,
        accessSession: access,
      );
      final completion = service.complete(
        session: _token(),
        appUiConfigCubit: config,
      );
      expect(access.isVerified, isFalse);
      now = now.add(const Duration(minutes: 3));
      if (outcome == 'save failure') {
        final assertion = expectLater(completion, throwsStateError);
        pendingSave.completeError(StateError('synthetic storage failure'));
        await assertion;
      } else {
        if (outcome == 'logout') {
          access.reset();
        }
        if (outcome == 'account switch') {
          identity = (2, 'other');
        }
        final assertion = outcome == 'success'
            ? completion
            : expectLater(completion, throwsStateError);
        pendingSave.complete();
        await assertion;
      }
      expect(access.isVerified, outcome == 'success');
      expect(
        access.expiresAt,
        outcome == 'success' ? now.add(const Duration(minutes: 20)) : null,
      );
      await config.close();
    });
  }
}
