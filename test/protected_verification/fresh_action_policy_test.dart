import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/repository/auto_renew_auth_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_otp_route_args.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verification_coordinator.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verified_result.dart';
import 'package:myaliv_mobile_app/app/common/verification/protected_account_access_verification_session.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

class _Auth extends Mock implements AuthManager {}

class _Challenge extends Mock implements CallLogsVerificationRepository {}

TokenSession _token(int attempt) => TokenSession(
  accessToken: 'synthetic-access-$attempt',
  refreshToken: 'synthetic-refresh-$attempt',
  accessExpiresAt: DateTime.utc(2030),
  refreshExpiresAt: DateTime.utc(2031),
);

Future<void> _flush() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  setUpAll(() => registerFallbackValue(_token(0)));
  for (final purpose in <Object>[
    ...AutoRenewPaymentMethodType.values,
    ...ProtectedAccountAction.values,
  ]) {
    group('$purpose always fresh OTP', () {
      late _Auth auth;
      late _Challenge challenge;
      late ActionVerificationCoordinator<Object> coordinator;
      late AppUiConfigCubit config;
      late ProtectedAccountAccessVerificationSession access;
      TokenSession? current;
      int challenges = 0;
      int saves = 0;
      Object? saveFailure;
      setUp(() {
        auth = _Auth();
        challenge = _Challenge();
        config = AppUiConfigCubit();
        current = _token(0);
        challenges = saves = 0;
        saveFailure = null;
        when(() => auth.currentSession).thenAnswer((_) => current);
        when(() => auth.saveSession(any())).thenAnswer((invocation) async {
          saves++;
          current = invocation.positionalArguments.first as TokenSession;
          if (saveFailure != null) {
            throw saveFailure!;
          }
        });
        when(() => challenge.requestChallenge()).thenAnswer((_) async {
          challenges++;
          return const CallLogsChallenge(
            mfaToken: 'synthetic-mfa',
            apiPhoneNumber: '2425550100',
          );
        });
        coordinator = ActionVerificationCoordinator<Object>(
          authManager: auth,
          challengeRepository: challenge,
          accountContext: () => (1, 123),
        );
        access = ProtectedAccountAccessVerificationSession(
          accountContext: () => (1, 'subscriber'),
        );
      });
      tearDown(() async {
        coordinator.cancel();
        access.dispose();
        await config.close();
      });

      for (final accessVerified in [false, true]) {
        test(
          'two actions each challenge; shared access=$accessVerified never bypasses or slides',
          () async {
            if (accessVerified) {
              access.markVerified();
            }
            final expiry = access.expiresAt;
            var mutations = 0;
            for (var i = 1; i <= 2; i++) {
              final result = await coordinator.verifyAction(
                purpose: purpose,
                isOwnerActive: () => true,
                openOtp: (args) async {
                  expect(args.attempt.verifiedResult, isNull);
                  await args.attempt.completeSession(_token(i), config);
                  return args.attempt.verifiedResult;
                },
              );
              expect(result!.consume(), isTrue);
              mutations++;
              expect(result.consume(), isFalse);
            }
            expect(challenges, 2);
            expect(saves, 2);
            expect(mutations, 2);
            expect(access.isVerified, accessVerified);
            expect(access.expiresAt, expiry);
          },
        );
      }

      test('challenge failure cannot issue an action result', () async {
        when(
          () => challenge.requestChallenge(),
        ).thenThrow(const CallLogsVerificationException('synthetic failure'));
        await expectLater(
          coordinator.verifyAction(
            purpose: purpose,
            isOwnerActive: () => true,
            openOtp: (_) => throw StateError('must not open'),
          ),
          throwsA(isA<CallLogsVerificationException>()),
        );
        expect(saves, 0);
        expect(access.isVerified, isFalse);
      });

      for (final outcome in ['invalid OTP', 'save failure', 'cancel']) {
        test('$outcome cannot authorize mutation', () async {
          final result = await coordinator.verifyAction(
            purpose: purpose,
            isOwnerActive: () => true,
            openOtp: (args) async {
              if (outcome == 'save failure') {
                saveFailure = StateError('synthetic storage failure');
                await expectLater(
                  args.attempt.completeSession(_token(1), config),
                  throwsStateError,
                );
              } else if (outcome == 'cancel') {
                args.attempt.cancel();
              }
              // Invalid OTP never reaches session completion (real OTP screen
              // transport/Bloc failure coverage remains in authorization tests).
              expect(args.attempt.verifiedResult, isNull);
              return null;
            },
          );
          expect(result, isNull);
          expect(saves, outcome == 'save failure' ? 1 : 0);
          expect(access.isVerified, isFalse);
        });
      }

      test(
        'duplicate challenge/result and forged capability cannot authorize twice',
        () async {
          ActionOtpRouteArgs<Object>? args;
          final navigation = Completer<ActionVerifiedResult<Object>?>();
          final pending = coordinator.verifyAction(
            purpose: purpose,
            isOwnerActive: () => true,
            openOtp: (value) {
              args = value;
              return navigation.future;
            },
          );
          await _flush();
          expect(
            await coordinator.verifyAction(
              purpose: purpose,
              isOwnerActive: () => true,
              openOtp: (_) => throw StateError('duplicate navigation'),
            ),
            isNull,
          );
          await args!.attempt.completeSession(_token(1), config);
          navigation.complete(args!.attempt.verifiedResult);
          final result = await pending;
          expect(result!.consume(), isTrue);
          expect(result.consume(), isFalse);
          final replay = await coordinator.verifyAction(
            purpose: purpose,
            isOwnerActive: () => true,
            openOtp: (_) async => result,
          );
          expect(replay, isNull);
          expect(challenges, 2);
          expect(saves, 1);
        },
      );
    });
  }
}
