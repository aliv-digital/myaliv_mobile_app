import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/bloc/auto_renew_auth_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/bloc/auto_renew_auth_prepaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/bloc/auto_renew_auth_prepaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/repository/auto_renew_auth_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/verification/auto_renew_authorization_otp_route_args.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/verification/auto_renew_authorization_submission.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewAuth/prepaid/verification/auto_renew_authorization_verification_coordinator.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

class _Auth extends Mock implements AuthManager {}

class _Challenge extends Mock implements CallLogsVerificationRepository {}

TokenSession session(String label) => TokenSession(
  accessToken: 'test-$label',
  refreshToken: 'test-refresh-$label',
  accessExpiresAt: DateTime(2030),
  refreshExpiresAt: DateTime(2031),
);

const _content = AutoRenewAuthContent(
  title: 'authorization',
  paragraph1: 'terms',
  consentTitle: 'consent',
  paragraph2: 'terms',
  signatureName: 'Test Subscriber',
  expectedName: 'Test Subscriber',
  nameLabel: 'name',
  nameHint: 'name',
  submitText: 'submit',
);

class _Repository implements AutoRenewAuthPrepaidRepository {
  final submissions = <(String, AutoRenewPaymentMethodType, String?)>[];
  bool success = true;
  Object? failure;
  @override
  Future<AutoRenewAuthContent> fetchContent({String? cardLastDigits}) async =>
      _content;
  @override
  Future<bool> submitAuthorization({
    required String name,
    required AutoRenewPaymentMethodType paymentMethod,
    String? cardToken,
  }) async {
    submissions.add((name, paymentMethod, cardToken));
    if (failure != null) {
      throw failure!;
    }
    return success;
  }
}

Future<void> flush() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  setUpAll(() => registerFallbackValue(session('fallback')));

  group('coordinator', () {
    late _Auth auth;
    late _Challenge challenge;
    late AppUiConfigCubit config;
    late TokenSession? current;
    late AutoRenewAuthorizationVerificationCoordinator coordinator;
    Object? account;
    bool active = true;
    int saves = 0;
    Completer<void>? saveGate;
    Object? saveFailure;

    setUp(() {
      auth = _Auth();
      challenge = _Challenge();
      config = AppUiConfigCubit();
      current = session('old');
      account = (1, 123);
      active = true;
      saves = 0;
      saveGate = null;
      saveFailure = null;
      when(() => auth.currentSession).thenAnswer((_) => current);
      when(() => auth.saveSession(any())).thenAnswer((invocation) async {
        saves++;
        current = invocation.positionalArguments.first as TokenSession;
        if (saveFailure != null) {
          throw saveFailure!;
        }
        await saveGate?.future;
      });
      when(() => challenge.requestChallenge()).thenAnswer(
        (_) async => const CallLogsChallenge(
          mfaToken: 'test-mfa',
          apiPhoneNumber: '2425550100',
        ),
      );
      coordinator = AutoRenewAuthorizationVerificationCoordinator(
        challengeRepository: challenge,
        authManager: auth,
        accountContext: () => account,
      );
    });
    tearDown(() async {
      coordinator.cancel();
      await config.close();
    });

    for (final mode in AutoRenewPaymentMethodType.values) {
      test('$mode waits for persistence and issues one-use result', () async {
        expect(mode.requiresAuthorizationOtp, isTrue);
        saveGate = Completer<void>();
        AutoRenewAuthorizationOtpRouteArgs? args;
        final navigation = Completer<AutoRenewAuthorizationVerifiedResult?>();
        final id = Object();
        final verification = coordinator.verify(
          paymentMethod: mode,
          attemptId: id,
          isOwnerActive: () => active,
          openOtp: (value) {
            args = value;
            return navigation.future;
          },
        );
        await flush();
        expect(args!.isValid, isTrue);
        final completion = args!.attempt.completeSession(
          session('new'),
          config,
        );
        await flush();
        expect(args!.attempt.verifiedResult, isNull);
        expect(saves, 1);
        saveGate!.complete();
        await completion;
        navigation.complete(args!.attempt.verifiedResult);
        final result = await verification;
        expect(result!.paymentMethod, mode);
        expect(identical(result.attemptId, id), isTrue);
        expect(result.consume(), isTrue);
        expect(result.consume(), isFalse);
      });
    }
    test('Challenge failure never opens OTP or saves a session', () async {
      when(
        () => challenge.requestChallenge(),
      ).thenThrow(const CallLogsVerificationException('Challenge failed'));
      var opens = 0;
      await expectLater(
        coordinator.verify(
          paymentMethod: AutoRenewPaymentMethodType.wallet,
          isOwnerActive: () => active,
          openOtp: (_) async {
            opens++;
            return null;
          },
        ),
        throwsA(isA<CallLogsVerificationException>()),
      );
      expect(opens, 0);
      expect(saves, 0);
    });
    test(
      'session-save failure issues no result; persistence retry required',
      () async {
        saveFailure = StateError('storage unavailable');
        final result = await coordinator.verify(
          paymentMethod: AutoRenewPaymentMethodType.card,
          isOwnerActive: () => active,
          openOtp: (args) async {
            await expectLater(
              args.attempt.completeSession(session('new'), config),
              throwsStateError,
            );
            expect(args.attempt.verifiedResult, isNull);
            return null;
          },
        );
        expect(result, isNull);
        expect(saves, 1);
      },
    );
    test(
      'duplicate launch is blocked and cancel needs fresh Challenge',
      () async {
        AutoRenewAuthorizationOtpRouteArgs? first;
        final pending = Completer<AutoRenewAuthorizationVerifiedResult?>();
        final verification = coordinator.verify(
          paymentMethod: AutoRenewPaymentMethodType.wallet,
          isOwnerActive: () => active,
          openOtp: (args) {
            first = args;
            return pending.future;
          },
        );
        await flush();
        expect(
          await coordinator.verify(
            paymentMethod: AutoRenewPaymentMethodType.wallet,
            isOwnerActive: () => active,
            openOtp: (_) async => throw StateError('duplicate opened'),
          ),
          isNull,
        );
        first!.attempt.cancel();
        expect(await verification, isNull);
        expect(first!.attempt.isActive, isFalse);
        await coordinator.verify(
          paymentMethod: AutoRenewPaymentMethodType.wallet,
          isOwnerActive: () => active,
          openOtp: (_) async => null,
        );
        verify(() => challenge.requestChallenge()).called(2);
        expect(saves, 0);
        pending.complete(null);
      },
    );
    test(
      'cancel releases a pending Challenge and ignores its late response',
      () async {
        final pending = Completer<CallLogsChallenge>();
        when(
          () => challenge.requestChallenge(),
        ).thenAnswer((_) => pending.future);
        var opens = 0;
        final verification = coordinator.verify(
          paymentMethod: AutoRenewPaymentMethodType.wallet,
          isOwnerActive: () => active,
          openOtp: (_) async {
            opens++;
            return null;
          },
        );
        coordinator.cancel();
        expect(await verification, isNull);
        pending.complete(
          const CallLogsChallenge(
            mfaToken: 'late',
            apiPhoneNumber: '2425550100',
          ),
        );
        await flush();
        expect(opens, 0);
        expect(saves, 0);
      },
    );
    for (final invalidation in [
      'owner',
      'account',
      'logout',
      'replacement-session',
    ]) {
      test('$invalidation blocks delayed result', () async {
        final result = await coordinator.verify(
          paymentMethod: AutoRenewPaymentMethodType.wallet,
          isOwnerActive: () => active,
          openOtp: (args) async {
            await args.attempt.completeSession(session('new'), config);
            final issued = args.attempt.verifiedResult;
            switch (invalidation) {
              case 'owner':
                active = false;
              case 'account':
                account = (2, 456);
              case 'logout':
                current = null;
              case 'replacement-session':
                current = session('other');
            }
            return issued;
          },
        );
        expect(result == null || !result.consume(), isTrue);
      });
    }
    test('forged route result cannot bypass persistence', () async {
      expect(
        await coordinator.verify(
          paymentMethod: AutoRenewPaymentMethodType.wallet,
          isOwnerActive: () => active,
          openOtp: (_) async => AutoRenewAuthorizationVerifiedResult(
            attemptId: Object(),
            paymentMethod: AutoRenewPaymentMethodType.wallet,
            canConsume: () => true,
          ),
        ),
        isNull,
      );
      expect(saves, 0);
    });
    test(
      'resend rotates Challenge and concurrent requests are coalesced',
      () async {
        var requests = 0;
        final pending = Completer<CallLogsChallenge>();
        when(() => challenge.requestChallenge()).thenAnswer((_) async {
          requests++;
          if (requests == 1) {
            return const CallLogsChallenge(
              mfaToken: 'first',
              apiPhoneNumber: '2425550100',
            );
          }
          return pending.future;
        });
        await coordinator.verify(
          paymentMethod: AutoRenewPaymentMethodType.wallet,
          isOwnerActive: () => active,
          openOtp: (args) async {
            final a = args.attempt.resendChallenge();
            final b = args.attempt.resendChallenge();
            pending.complete(
              const CallLogsChallenge(
                mfaToken: 'rotated',
                apiPhoneNumber: '2425550100',
              ),
            );
            expect((await a).mfaToken, 'rotated');
            expect((await b).mfaToken, 'rotated');
            return null;
          },
        );
        expect(requests, 2);
      },
    );
    test('duplicate completion cannot save twice', () async {
      saveGate = Completer<void>();
      await coordinator.verify(
        paymentMethod: AutoRenewPaymentMethodType.wallet,
        isOwnerActive: () => active,
        openOtp: (args) async {
          final completion = args.attempt.completeSession(
            session('new'),
            config,
          );
          await expectLater(
            args.attempt.completeSession(session('duplicate'), config),
            throwsA(isA<CallLogsVerificationException>()),
          );
          saveGate!.complete();
          await completion;
          return args.attempt.verifiedResult;
        },
      );
      expect(saves, 1);
    });
  });

  group('authorization form BLoC', () {
    late _Repository repository;
    AutoRenewAuthPrepaidBloc? bloc;
    setUp(() {
      repository = _Repository();
    });
    tearDown(() async {
      await bloc?.close();
      bloc = null;
    });

    Future<void> start(
      AutoRenewPaymentMethodType mode,
      Future<AutoRenewAuthorizationVerifiedResult?> Function(
        AutoRenewAuthorizationSubmission,
      )
      verify,
    ) async {
      bloc = AutoRenewAuthPrepaidBloc(
        repository: repository,
        verifyAuthorization: verify,
      );
      bloc!.add(
        AutoRenewAuthPrepaidStarted(
          paymentMethod: mode,
          cardToken: 'test-card-token',
        ),
      );
      await flush();
      bloc!.add(const AutoRenewAuthNameChanged('Test Subscriber'));
      await flush();
    }

    AutoRenewAuthorizationVerifiedResult result(
      AutoRenewAuthorizationSubmission s,
    ) => AutoRenewAuthorizationVerifiedResult(
      attemptId: s.attemptId,
      paymentMethod: s.paymentMethod,
      canConsume: () => true,
    );

    for (final mode in AutoRenewPaymentMethodType.values) {
      test(
        '$mode gates unchanged submitAuthorization arguments, exactly once',
        () async {
          final pending = Completer<AutoRenewAuthorizationVerifiedResult?>();
          AutoRenewAuthorizationSubmission? submitted;
          var verifies = 0;
          await start(mode, (s) {
            verifies++;
            submitted = s;
            return pending.future;
          });
          bloc!.add(const AutoRenewAuthSubmitPressed());
          bloc!.add(const AutoRenewAuthSubmitPressed());
          await flush();
          expect(bloc!.state.submitStatus, AutoRenewAuthSubmitStatus.verifying);
          expect(bloc!.state.canSubmit, isFalse);
          expect(repository.submissions, isEmpty);
          expect(verifies, 1);
          pending.complete(result(submitted!));
          await flush();
          expect(repository.submissions, [
            ('Test Subscriber', mode, 'test-card-token'),
          ]);
          expect(bloc!.state.navTarget, AutoRenewAuthNavTarget.success);
          bloc!.add(const AutoRenewAuthSubmitPressed());
          await flush();
          expect(repository.submissions.length, 1);
          expect(verifies, 1);
        },
      );
    }
    for (final (mode, name) in [
      for (final mode in AutoRenewPaymentMethodType.values)
        for (final name in ['', '   ', 'Wrong Name', 'Test Subscriber '])
          (mode, name),
    ]) {
      test('$mode existing name validation rejects "$name" before OTP', () async {
        var verifies = 0;
        await start(mode, (_) async {
          verifies++;
          return null;
        });
        bloc!.add(AutoRenewAuthNameChanged(name));
        await flush();
        bloc!.add(const AutoRenewAuthSubmitPressed());
        await flush();
        expect(verifies, 0);
        expect(repository.submissions, isEmpty);
        expect(
          bloc!.state.errorMessage,
          name.trim().isEmpty
              ? 'Please enter your name.'
              : 'Name does not match. Please enter your name exactly as displayed.',
        );
      });
    }
    test(
      'cancel keeps name/token, restores form and permits fresh verification',
      () async {
        var verifies = 0;
        await start(AutoRenewPaymentMethodType.card, (_) async {
          verifies++;
          return null;
        });
        bloc!.add(const AutoRenewAuthSubmitPressed());
        await flush();
        expect(bloc!.state.submitStatus, AutoRenewAuthSubmitStatus.idle);
        expect(bloc!.state.name, 'Test Subscriber');
        expect(bloc!.state.cardToken, 'test-card-token');
        expect(bloc!.state.canSubmit, isTrue);
        bloc!.add(const AutoRenewAuthSubmitPressed());
        await flush();
        expect(verifies, 2);
        expect(repository.submissions, isEmpty);
      },
    );
    test('verification error never submits', () async {
      await start(
        AutoRenewPaymentMethodType.postpaidInvoice,
        (_) async =>
            throw const CallLogsVerificationException('Challenge unavailable'),
      );
      bloc!.add(const AutoRenewAuthSubmitPressed());
      await flush();
      expect(bloc!.state.errorMessage, 'Challenge unavailable');
      expect(repository.submissions, isEmpty);
    });
    for (final change in ['name', 'method', 'attempt', 'consumed']) {
      test('rejects stale $change result', () async {
        final pending = Completer<AutoRenewAuthorizationVerifiedResult?>();
        AutoRenewAuthorizationSubmission? submission;
        await start(AutoRenewPaymentMethodType.card, (s) {
          submission = s;
          return pending.future;
        });
        bloc!.add(const AutoRenewAuthSubmitPressed());
        await flush();
        var verified = result(submission!);
        if (change == 'name') {
          bloc!.add(const AutoRenewAuthNameChanged('Other'));
        }
        if (change == 'method') {
          bloc!.add(
            const AutoRenewAuthPrepaidStarted(
              paymentMethod: AutoRenewPaymentMethodType.wallet,
            ),
          );
        }
        if (change == 'attempt') {
          verified = AutoRenewAuthorizationVerifiedResult(
            attemptId: Object(),
            paymentMethod: AutoRenewPaymentMethodType.card,
            canConsume: () => true,
          );
        }
        if (change == 'consumed') {
          verified.consume();
        }
        await flush();
        pending.complete(verified);
        await flush();
        expect(repository.submissions, isEmpty);
      });
    }
    for (final (requested, returned) in [
      (
        AutoRenewPaymentMethodType.card,
        AutoRenewPaymentMethodType.postpaidInvoice,
      ),
      (
        AutoRenewPaymentMethodType.postpaidInvoice,
        AutoRenewPaymentMethodType.wallet,
      ),
    ]) {
      test(
        '$returned result cannot complete $requested authorization',
        () async {
          await start(
            requested,
            (s) async => AutoRenewAuthorizationVerifiedResult(
              attemptId: s.attemptId,
              paymentMethod: returned,
              canConsume: () => true,
            ),
          );
          bloc!.add(const AutoRenewAuthSubmitPressed());
          await flush();
          expect(repository.submissions, isEmpty);
        },
      );
    }
    test(
      'disposed form cancels verification and ignores its late result',
      () async {
        final pending = Completer<AutoRenewAuthorizationVerifiedResult?>();
        AutoRenewAuthorizationSubmission? submission;
        var cancels = 0;
        bloc = AutoRenewAuthPrepaidBloc(
          repository: repository,
          verifyAuthorization: (s) {
            submission = s;
            return pending.future;
          },
          cancelVerification: () {
            cancels++;
            pending.complete(result(submission!));
          },
        );
        bloc!.add(
          const AutoRenewAuthPrepaidStarted(
            paymentMethod: AutoRenewPaymentMethodType.card,
          ),
        );
        await flush();
        bloc!.add(const AutoRenewAuthNameChanged('Test Subscriber'));
        await flush();
        bloc!.add(const AutoRenewAuthSubmitPressed());
        await flush();
        await bloc!.close();
        bloc = null;
        expect(cancels, 1);
        expect(repository.submissions, isEmpty);
      },
    );
    for (final failure in ['false', 'exception']) {
      test('business $failure preserves existing error handling', () async {
        repository.success = false;
        if (failure == 'exception') {
          repository.failure = StateError('failed');
        }
        await start(AutoRenewPaymentMethodType.card, (s) async => result(s));
        bloc!.add(const AutoRenewAuthSubmitPressed());
        await flush();
        expect(repository.submissions.length, 1);
        expect(
          bloc!.state.errorMessage,
          failure == 'false'
              ? 'Failed to enable auto-renew. Please try again.'
              : 'Failed to submit. Please try again.',
        );
      });
    }
  });
}
