import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/account_info_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/verification/auto_top_up_submission.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/view/auto_top_up_authorization_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/auto_topup/auto_topup_tab.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/auto_topup/auto_topup_sections.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_otp_screen.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verified_result.dart';
import 'package:myaliv_mobile_app/app/common/verification/protected_account_access_verification_session.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import 'helpers/auto_top_up_otp_fixture.dart';

class _Devices extends Mock implements DeviceLimitsCubit {}

class _Account extends Mock implements AccountInfoCubit {}

class _Cards extends Mock implements SavedCardsCubit {}

DeviceLimitsState _state({bool configured = false, int id = 123}) =>
    DeviceLimitsState(
      status: DeviceLimitsStatus.loaded,
      allDeviceLimits: [
        DeviceLimitsModel.fromJson({
          'DeviceID': id,
          'BalanceThreshold': 20,
          'AutoTopUpAmount': 25,
          'AutoTopUp': configured ? 'synthetic-card' : '',
        }),
      ],
    );

AutoTopUpSubmissionSnapshot _snapshot({
  Object? attemptId,
  double threshold = 20,
  double amount = 25,
  String card = 'synthetic-card',
  String signature = 'Test Subscriber',
}) => AutoTopUpSubmissionSnapshot(
  attemptId: attemptId ?? Object(),
  deviceId: 123,
  balanceThreshold: threshold,
  autoTopUpAmount: amount,
  cardToken: card,
  signature: signature,
);

ActionVerifiedResult<ProtectedAccountAction> _verified(
  Object attemptId, {
  ProtectedAccountAction purpose = ProtectedAccountAction.autoTopUp,
  bool Function()? canConsume,
}) => ActionVerifiedResult<ProtectedAccountAction>(
  attemptId: attemptId,
  paymentMethod: purpose,
  canConsume: canConsume ?? () => true,
);

class _Harness {
  _Harness({
    bool configured = false,
    bool policyA = false,
    this.threshold = 20,
    this.amount = 25,
    this.card = 'synthetic-card',
  }) {
    state = _state(configured: configured);
    when(() => devices.state).thenAnswer((_) => state);
    when(() => devices.stream).thenAnswer((_) => const Stream.empty());
    when(() => devices.loadDeviceLimits()).thenAnswer((_) async {});
    when(
      () => devices.updateBalanceThresholdSettings(
        balanceThreshold: any(named: 'balanceThreshold'),
        autoTopUpAmount: any(named: 'autoTopUpAmount'),
        cardToken: any(named: 'cardToken'),
      ),
    ).thenAnswer((invocation) async {
      mutations++;
      payloads.add(invocation.namedArguments);
      otp.trace.add('mutation');
      return mutationSuccess;
    });
    when(() => account.state).thenReturn(
      const AccountInfoState(
        accountInfo: AccountInfoModel(
          idAcc: 42,
          fName: 'Test',
          lName: 'Subscriber',
        ),
      ),
    );
    when(() => cards.state).thenReturn(
      SavedCardsState(
        status: SavedCardsStatus.success,
        cards: [SavedCardModel(token: card, number: '************1234')],
      ),
    );
    when(() => cards.stream).thenAnswer((_) => const Stream.empty());
    when(() => cards.fetchSavedCards()).thenAnswer((_) async {});
    instance.registerSingleton<DeviceLimitsCubit>(devices);
    instance.registerSingleton<AccountInfoCubit>(account);
    if (policyA) {
      access.markVerified();
    }
    instance.registerSingleton<ProtectedAccountAccessVerificationSession>(
      access,
    );
  }

  final otp = AutoTopUpOtpFixture();
  final double threshold, amount;
  final String card;
  final devices = _Devices();
  final account = _Account();
  final cards = _Cards();
  final access = ProtectedAccountAccessVerificationSession(
    accountContext: () => (42, 'subscriber'),
  );
  late DeviceLimitsState state;
  late GoRouter router;
  int mutations = 0;
  bool mutationSuccess = true;
  final payloads = <Map<Symbol, dynamic>>[];

  /// Pumps the tab, fills the setup form, and taps "apply". When the OTP
  /// screen is expected after apply, settles afterwards so the OTP route is
  /// mounted and ready for [otp.verify].
  Future<void> pump(WidgetTester tester, {bool tapApply = true}) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const AutoTopupTab()),
        otp.otpRoute,
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const Scaffold(body: Text('home destination')),
        ),
      ],
    );
    await tester.pumpWidget(
      otp.wrap(
        BlocProvider<SavedCardsCubit>.value(
          value: cards,
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );
    await tester.pumpAndSettle();
    tester
        .widget<AutoTopupCardSection>(find.byType(AutoTopupCardSection))
        .onCardSelected(cards.state.cards.first);
    await tester.pump();
    await tester.enterText(
      find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            w.decoration?.hintText == 'enter threshold amount',
      ),
      threshold.toInt().toString(),
    );
    await tester.enterText(
      find.byWidgetPredicate(
        (w) =>
            w is TextField && w.decoration?.hintText == 'enter a custom amount',
      ),
      amount.toInt().toString(),
    );
    if (!tapApply) return;
    await tester.ensureVisible(find.text('apply'));
    await tester.tap(find.text('apply'));
    await tester.pumpAndSettle();
  }

  /// Called from the Setup tab (after [pump]) to re-trigger "apply".
  Future<void> apply(WidgetTester tester) async {
    await tester.ensureVisible(find.text('apply'));
    await tester.tap(find.text('apply'));
    await tester.pumpAndSettle();
  }

  /// Enters the signature into the Authorization screen's TextField.
  Future<void> enterSignature(
    WidgetTester tester, {
    String name = 'Test Subscriber',
  }) async {
    await tester.enterText(
      find.descendant(
        of: find.byType(AutoTopUpAuthorizationScreen),
        matching: find.byType(TextField),
      ),
      name,
    );
    await tester.pump();
    await tester.ensureVisible(find.text('submit'));
  }

  /// Taps the Authorization screen's "submit" button (does not re-trigger OTP).
  Future<void> submit(WidgetTester tester, {int taps = 1}) async {
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'submit'),
    );
    for (var i = 0; i < taps; i++) {
      button.onPressed!();
    }
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 25));
    }
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  }

  Future<void> dispose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
    router.dispose();
    access.dispose();
    await otp.dispose();
    await instance.reset();
    await tester.binding.setSurfaceSize(null);
  }
}

void main() {
  group('Auto Top-up one-use submission', () {
    late _Devices devices;
    late AutoTopUpSubmission submission;
    late DeviceLimitsState state;
    int mutations = 0;
    setUp(() {
      mutations = 0;
      devices = _Devices();
      state = _state();
      when(() => devices.state).thenAnswer((_) => state);
      when(
        () => devices.updateBalanceThresholdSettings(
          balanceThreshold: any(named: 'balanceThreshold'),
          autoTopUpAmount: any(named: 'autoTopUpAmount'),
          cardToken: any(named: 'cardToken'),
        ),
      ).thenAnswer((_) async {
        mutations++;
        return true;
      });
      // ActiveDevice.id() reads DeviceLimitsCubit from GetIt (and
      // AppUiConfigCubit, which is optional).
      if (instance.isRegistered<DeviceLimitsCubit>()) {
        instance.unregister<DeviceLimitsCubit>();
      }
      instance.registerSingleton<DeviceLimitsCubit>(devices);
      submission = AutoTopUpSubmission(deviceLimitsCubit: devices);
    });
    tearDown(() async {
      submission.close();
      await instance.reset();
    });

    for (final type in ['enable', 'threshold', 'amount', 'card']) {
      test(
        '$type consumes the verified result once and preserves arguments',
        () async {
          final snapshot = _snapshot(
            threshold: type == 'threshold' ? 30 : 20,
            amount: type == 'amount' ? 35 : 25,
            card: type == 'card' ? 'synthetic-other-card' : 'synthetic-card',
          );
          final result = _verified(snapshot.attemptId);
          expect(
            await submission.submit(
              snapshot: snapshot,
              isCurrent: (_) => true,
              verifiedResult: result,
            ),
            isTrue,
          );
          verify(
            () => devices.updateBalanceThresholdSettings(
              balanceThreshold: snapshot.balanceThreshold,
              autoTopUpAmount: snapshot.autoTopUpAmount,
              cardToken: snapshot.cardToken,
            ),
          ).called(1);
        },
      );
    }
    for (final invalidation in [
      'forged attempt',
      'wrong purpose',
      'consumed',
      'cannot consume',
      'closed',
      'device changed',
      'signature',
      'threshold',
      'amount',
      'card',
    ]) {
      test('$invalidation rejects result before mutation', () async {
        final snapshot = _snapshot();
        var current = true;
        var canConsume = true;
        final result = ActionVerifiedResult<ProtectedAccountAction>(
          attemptId: invalidation == 'forged attempt'
              ? Object()
              : snapshot.attemptId,
          paymentMethod: invalidation == 'wrong purpose'
              ? ProtectedAccountAction.changePassword
              : ProtectedAccountAction.autoTopUp,
          canConsume: () => canConsume,
        );
        if (invalidation == 'consumed') {
          result.consume();
        }
        if (invalidation == 'cannot consume') {
          canConsume = false;
        }
        if (invalidation == 'closed') {
          submission.close();
        }
        if (invalidation == 'device changed') {
          state = _state(id: 456);
        }
        if ([
          'signature',
          'threshold',
          'amount',
          'card',
        ].contains(invalidation)) {
          current = false;
        }
        final submitted = await submission.submit(
          snapshot: snapshot,
          isCurrent: (_) => current,
          verifiedResult: result,
        );
        // "device changed" is detected upfront and returns false (the mutation
        // target is wrong); the other invalidations return null (cancel/stale).
        expect(submitted, invalidation == 'device changed' ? isFalse : isNull);
        expect(mutations, 0);
      });
    }
    test('concurrent submit and replay cannot invoke mutation twice', () async {
      final snapshot = _snapshot();
      final result = _verified(snapshot.attemptId);
      final mutationCompleter = Completer<bool>();
      when(
        () => devices.updateBalanceThresholdSettings(
          balanceThreshold: any(named: 'balanceThreshold'),
          autoTopUpAmount: any(named: 'autoTopUpAmount'),
          cardToken: any(named: 'cardToken'),
        ),
      ).thenAnswer((_) {
        mutations++;
        return mutationCompleter.future;
      });
      final first = submission.submit(
        snapshot: snapshot,
        isCurrent: (_) => true,
        verifiedResult: result,
      );
      // Concurrent submit while first is still awaiting the mutation.
      expect(
        await submission.submit(
          snapshot: snapshot,
          isCurrent: (_) => true,
          verifiedResult: result,
        ),
        isNull,
      );
      mutationCompleter.complete(true);
      expect(await first, isTrue);
      // Replay after the first attempt completed: the result is now consumed.
      expect(
        await submission.submit(
          snapshot: snapshot,
          isCurrent: (_) => true,
          verifiedResult: result,
        ),
        isNull,
      );
      expect(mutations, 1);
    });
  });

  void flow(
    String name,
    Future<void> Function(WidgetTester, _Harness) body, {
    bool policyA = false,
    bool configured = false,
    double threshold = 20,
    double amount = 25,
    String card = 'synthetic-card',
    TargetPlatform platform = TargetPlatform.android,
    bool tapApply = true,
  }) {
    testWidgets(
      name,
      (tester) => autoTopUpOnline(() async {
        debugDefaultTargetPlatformOverride = platform;
        final h = _Harness(
          policyA: policyA,
          configured: configured,
          threshold: threshold,
          amount: amount,
          card: card,
        );
        try {
          await h.pump(tester, tapApply: tapApply);
          await body(tester, h);
        } finally {
          await h.dispose(tester);
          debugDefaultTargetPlatformOverride = null;
        }
      }),
    );
  }

  flow('six wrong Auto Top-Up OTPs show the final message and redirect home', (
    tester,
    h,
  ) async {
    const limitMessage = 'Too many failed OTP attempts. Please try again.';
    h.otp.verifyFailure = NetworkException(
      'Two Factor Key Invalid',
      statusCode: 400,
      data: {'ErrorCode': 202, 'ErrorCodeName': 'TwoFactorKeyInvalid'},
    );
    expect(h.otp.args!.attempt.paymentMethod, ProtectedAccountAction.autoTopUp);
    for (var attempt = 1; attempt <= 5; attempt++) {
      await h.otp.verify(tester);
      expect(h.otp.verifies, attempt);
      expect(find.text('Invalid OTP'), findsOneWidget);
      expect(find.text(limitMessage), findsNothing);
      expect(find.byType(ActionOtpScreen), findsOneWidget);
      expect(find.text('home destination'), findsNothing);
    }
    await h.otp.verify(tester);
    await tester.pumpAndSettle();
    expect(h.otp.verifies, 6);
    expect(find.text(limitMessage), findsOneWidget);
    expect(find.text('Invalid OTP'), findsNothing);
    expect(find.byType(ActionOtpScreen), findsNothing);
    expect(find.text('home destination'), findsOneWidget);
    expect(h.router.canPop(), isFalse);
    expect(find.byType(AutoTopUpAuthorizationScreen), findsNothing);
    expect(h.otp.saves, 0);
    expect(h.mutations, 0);
    expect(h.payloads, isEmpty);
  });

  flow('iOS mixed navigation success routes through OTP, then Authorization', (
    tester,
    h,
  ) async {
    // After pump: OTP is open on top of Setup. Authorization not yet pushed.
    expect(find.byType(ActionOtpScreen), findsOneWidget);
    expect(find.byType(AutoTopUpAuthorizationScreen), findsNothing);
    expect(h.mutations, 0);
    await h.otp.verify(tester);
    await tester.pumpAndSettle();
    // OTP returned, Setup pushed Authorization. No mutation yet.
    expect(find.byType(AutoTopUpAuthorizationScreen), findsOneWidget);
    expect(h.mutations, 0);
    await h.enterSignature(tester);
    await h.submit(tester);
    await h.finish(tester);
    expect(h.mutations, 1);
    expect(find.text('home destination'), findsOneWidget);
  }, platform: TargetPlatform.iOS);

  flow('iOS mixed navigation cancel on OTP returns to Setup with form intact', (
    tester,
    h,
  ) async {
    expect(find.byType(ActionOtpScreen), findsOneWidget);
    h.router.pop();
    await tester.pumpAndSettle();
    expect(find.byType(ActionOtpScreen), findsNothing);
    expect(find.byType(AutoTopUpAuthorizationScreen), findsNothing);
    expect(find.byType(AutoTopupTab), findsOneWidget);
    // Threshold and custom amount fields retained.
    expect(
      tester
          .widget<TextField>(
            find.byWidgetPredicate(
              (w) =>
                  w is TextField &&
                  w.decoration?.hintText == 'enter threshold amount',
            ),
          )
          .controller!
          .text,
      h.threshold.toInt().toString(),
    );
    expect(h.mutations, 0);
  }, platform: TargetPlatform.iOS);

  for (final change in ['threshold', 'amount', 'card']) {
    flow(
      'existing configuration $change change requests fresh Challenge',
      (tester, h) async {
        expect(h.otp.challenges, 1);
        expect(h.mutations, 0);
        await h.otp.verify(tester);
        await tester.pumpAndSettle();
        await h.enterSignature(tester);
        await h.submit(tester);
        await h.finish(tester);
        expect(h.mutations, 1);
        expect(h.payloads.single, {
          #balanceThreshold: h.threshold,
          #autoTopUpAmount: h.amount,
          #cardToken: h.card,
        });
      },
      configured: true,
      threshold: change == 'threshold' ? 30 : 20,
      amount: change == 'amount' ? 35 : 25,
      card: change == 'card' ? 'synthetic-other-card' : 'synthetic-card',
    );
  }

  for (final policyA in [false, true]) {
    flow(
      'success awaits persistence before Authorization; Policy A=$policyA unchanged',
      (tester, h) async {
        final expiry = h.access.expiresAt;
        h.otp.saveGate = Completer<void>();
        expect(h.otp.challenges, 1);
        expect(h.mutations, 0);
        expect(find.byType(ActionOtpScreen), findsOneWidget);
        await h.otp.verify(tester, taps: 3);
        expect(h.otp.verifies, 1);
        expect(h.mutations, 0);
        // Authorization is not pushed until the token save completes.
        expect(find.byType(AutoTopUpAuthorizationScreen), findsNothing);
        h.otp.saveGate!.complete();
        await tester.pumpAndSettle();
        expect(find.byType(AutoTopUpAuthorizationScreen), findsOneWidget);
        await h.enterSignature(tester);
        await h.submit(tester);
        await h.finish(tester);
        expect(h.otp.trace, [
          'challenge',
          'verify',
          'save-start',
          'saved',
          'mutation',
        ]);
        expect(h.mutations, 1);
        expect(h.payloads.single, {
          #balanceThreshold: 20.0,
          #autoTopUpAmount: 25.0,
          #cardToken: 'synthetic-card',
        });
        expect(h.access.isVerified, policyA);
        expect(h.access.expiresAt, expiry);
        expect(find.text('home destination'), findsOneWidget);
      },
      policyA: policyA,
    );
  }

  flow('cancel at OTP then retry issues a fresh Challenge', (tester, h) async {
    expect(h.otp.challenges, 1);
    h.router.pop();
    await tester.pumpAndSettle();
    expect(find.byType(AutoTopupTab), findsOneWidget);
    expect(h.mutations, 0);
    // Tap "apply" again from Setup: new OTP challenge, new attemptId.
    await h.apply(tester);
    expect(h.otp.challenges, 2);
    await h.otp.verify(tester);
    await tester.pumpAndSettle();
    await h.enterSignature(tester);
    await h.submit(tester);
    await h.finish(tester);
    expect(h.mutations, 1);
  });

  // Failures need their trigger set before "apply" fires, so these flows
  // bypass the harness's auto-apply and arm the fixture directly.
  for (final failure in [
    'challenge',
    'invalid OTP',
    'verification transport',
    'save',
  ]) {
    testWidgets(
      '$failure failure has zero mutations and no false success',
      (tester) => autoTopUpOnline(() async {
        final h = _Harness();
        try {
          if (failure == 'challenge') {
            h.otp.challengeFailure = const CallLogsVerificationException(
              'synthetic failure',
            );
          }
          if (failure == 'invalid OTP') {
            h.otp.verifyFailure = StateError('synthetic invalid OTP');
          }
          if (failure == 'verification transport') {
            h.otp.verifyFailure = TimeoutException();
          }
          if (failure == 'save') {
            h.otp.saveFailure = StateError('synthetic storage failure');
          }
          await h.pump(tester);
          if (failure != 'challenge') {
            await h.otp.verify(tester);
          }
          await h.finish(tester);
          expect(h.mutations, 0);
          expect(find.byType(AutoTopUpAuthorizationScreen), findsNothing);
          expect(find.text('home destination'), findsNothing);
          expect(find.text('auto top-up successfully started'), findsNothing);
        } finally {
          await h.dispose(tester);
        }
      }),
    );
  }

  for (final change in ['logout', 'replacement', 'dispose']) {
    flow('$change during OTP rejects delayed verification', (tester, h) async {
      h.otp.verifyGate = Completer<void>();
      await h.otp.verify(tester);
      if (change == 'logout') {
        h.otp.current = null;
      }
      if (change == 'replacement') {
        h.otp.current = autoTopUpTestSession('other');
      }
      if (change == 'dispose') {
        h.router.go(AppRoutes.home);
        await tester.pumpAndSettle();
      }
      h.otp.verifyGate!.complete();
      await h.finish(tester);
      expect(h.mutations, 0);
      expect(find.byType(AutoTopUpAuthorizationScreen), findsNothing);
    });
  }

  flow('backend failure pops back to Setup so retry starts a fresh challenge', (
    tester,
    h,
  ) async {
    h.mutationSuccess = false;
    await h.otp.verify(tester);
    await tester.pumpAndSettle();
    await h.enterSignature(tester);
    await h.submit(tester);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(
      find.text('Failed to update settings. Please try again.'),
      findsOneWidget,
    );
    expect(h.mutations, 1);
    // On failure the Authorization screen pops; user is back on Setup.
    expect(find.byType(AutoTopUpAuthorizationScreen), findsNothing);
    expect(find.byType(AutoTopupTab), findsOneWidget);
    await h.apply(tester);
    expect(h.otp.challenges, 2);
  });

  flow('session-save failure can retry without a false prior mutation', (
    tester,
    h,
  ) async {
    h.otp.saveFailure = StateError('synthetic storage failure');
    await h.otp.verify(tester);
    expect(h.mutations, 0);
    expect(find.byType(AutoTopUpAuthorizationScreen), findsNothing);
    h.otp.saveFailure = null;
    await h.otp.verify(tester);
    await tester.pumpAndSettle();
    expect(find.byType(AutoTopUpAuthorizationScreen), findsOneWidget);
    await h.enterSignature(tester);
    await h.submit(tester);
    await h.finish(tester);
    expect(h.otp.saves, 2);
    expect(h.mutations, 1);
  });

  flow('forged route result without persisted OTP is rejected', (
    tester,
    h,
  ) async {
    h.router.pop(
      ActionVerifiedResult(
        attemptId: Object(),
        paymentMethod: ProtectedAccountAction.autoTopUp,
        canConsume: () => true,
      ),
    );
    await h.finish(tester);
    expect(h.otp.saves, 0);
    expect(h.mutations, 0);
    expect(find.byType(AutoTopUpAuthorizationScreen), findsNothing);
  });

  testWidgets(
    'disposed setup ignores a late Challenge',
    (tester) => autoTopUpOnline(() async {
      final h = _Harness();
      try {
        h.otp.challengeGate = Completer<CallLogsChallenge>();
        // Pump but do not tap apply yet; we need the challenge gate in place
        // first so the apply tap pauses on the challenge.
        await h.pump(tester, tapApply: false);
        await h.apply(tester);
        expect(h.otp.challenges, 1);
        expect(find.byType(ActionOtpScreen), findsNothing);
        h.router.go(AppRoutes.home);
        await tester.pumpAndSettle();
        h.otp.challengeGate!.complete(
          const CallLogsChallenge(
            mfaToken: 'synthetic-late',
            apiPhoneNumber: '2425550100',
          ),
        );
        await h.finish(tester);
        expect(h.mutations, 0);
        expect(find.byType(ActionOtpScreen), findsNothing);
        expect(find.byType(AutoTopUpAuthorizationScreen), findsNothing);
      } finally {
        await h.dispose(tester);
      }
    }),
  );
}
