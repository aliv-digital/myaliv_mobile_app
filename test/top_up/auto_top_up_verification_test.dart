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
  double threshold = 20,
  double amount = 25,
  String card = 'synthetic-card',
  String signature = 'Test Subscriber',
}) => AutoTopUpSubmissionSnapshot(
  deviceId: 123,
  balanceThreshold: threshold,
  autoTopUpAmount: amount,
  cardToken: card,
  signature: signature,
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

  Future<void> pump(WidgetTester tester) async {
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
    await tester.ensureVisible(find.text('apply'));
    await tester.tap(find.text('apply'));
    await tester.pumpAndSettle();
    expect(find.byType(AutoTopUpAuthorizationScreen), findsOneWidget);
    expect(
      ModalRoute.of(tester.element(find.byType(AutoTopUpAuthorizationScreen))),
      isA<MaterialPageRoute<dynamic>>(),
    );
    await tester.enterText(find.byType(TextField), 'Test Subscriber');
    await tester.ensureVisible(find.text('submit'));
  }

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
      submission = AutoTopUpSubmission(deviceLimitsCubit: devices);
    });
    tearDown(() => submission.close());

    for (final type in ['enable', 'threshold', 'amount', 'card']) {
      test(
        '$type requires its own verification and preserves original arguments',
        () async {
          final snapshot = _snapshot(
            threshold: type == 'threshold' ? 30 : 20,
            amount: type == 'amount' ? 35 : 25,
            card: type == 'card' ? 'synthetic-other-card' : 'synthetic-card',
          );
          var requests = 0;
          expect(
            await submission.submit(
              snapshot: snapshot,
              isCurrent: (_) => true,
              verifyAction: (pending) async {
                requests++;
                expect(mutations, 0);
                return ActionVerifiedResult(
                  attemptId: pending.attemptId,
                  paymentMethod: ProtectedAccountAction.autoTopUp,
                  canConsume: () => true,
                );
              },
            ),
            isTrue,
          );
          expect(requests, 1);
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
      'cancel',
      'forged attempt',
      'wrong purpose',
      'consumed',
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
        final result = await submission.submit(
          snapshot: snapshot,
          isCurrent: (_) => current,
          verifyAction: (pending) async {
            if (invalidation == 'cancel') {
              return null;
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
            final result = ActionVerifiedResult(
              attemptId: invalidation == 'forged attempt'
                  ? Object()
                  : pending.attemptId,
              paymentMethod: invalidation == 'wrong purpose'
                  ? ProtectedAccountAction.changePassword
                  : ProtectedAccountAction.autoTopUp,
              canConsume: () => true,
            );
            if (invalidation == 'consumed') {
              result.consume();
            }
            return result;
          },
        );
        expect(result, isNull);
        expect(mutations, 0);
      });
    }
    test('concurrent submit and replay cannot invoke mutation twice', () async {
      final snapshot = _snapshot();
      final pending =
          Completer<ActionVerifiedResult<ProtectedAccountAction>?>();
      final first = submission.submit(
        snapshot: snapshot,
        isCurrent: (_) => true,
        verifyAction: (_) => pending.future,
      );
      expect(
        await submission.submit(
          snapshot: snapshot,
          isCurrent: (_) => true,
          verifyAction: (_) => throw StateError('duplicate'),
        ),
        isNull,
      );
      final result = ActionVerifiedResult(
        attemptId: snapshot.attemptId,
        paymentMethod: ProtectedAccountAction.autoTopUp,
        canConsume: () => true,
      );
      pending.complete(result);
      expect(await first, isTrue);
      expect(
        await submission.submit(
          snapshot: snapshot,
          isCurrent: (_) => true,
          verifyAction: (_) async => result,
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
          await h.pump(tester);
          await body(tester, h);
        } finally {
          await h.dispose(tester);
          debugDefaultTargetPlatformOverride = null;
        }
      }),
    );
  }

  flow(
    'iOS mixed navigation success returns to the authorization owner',
    (tester, h) async {
      await h.submit(tester);
      expect(h.mutations, 0);
      await h.otp.verify(tester);
      await h.finish(tester);
      expect(h.mutations, 1);
      expect(find.text('home destination'), findsOneWidget);
    },
    platform: TargetPlatform.iOS,
  );
  flow(
    'iOS mixed navigation cancel retains the same form',
    (tester, h) async {
      await h.submit(tester);
      h.router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(AutoTopUpAuthorizationScreen), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Test Subscriber',
      );
      expect(h.mutations, 0);
    },
    platform: TargetPlatform.iOS,
  );

  for (final change in ['threshold', 'amount', 'card']) {
    flow(
      'existing configuration $change change requests fresh Challenge',
      (tester, h) async {
        await h.submit(tester);
        expect(h.otp.challenges, 1);
        expect(h.mutations, 0);
        await h.otp.verify(tester);
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
      'mixed navigation success awaits persistence; Policy A=$policyA unchanged',
      (tester, h) async {
        final expiry = h.access.expiresAt;
        h.otp.saveGate = Completer<void>();
        await h.submit(tester, taps: 3);
        expect(h.otp.challenges, 1);
        expect(h.mutations, 0);
        expect(find.byType(ActionOtpScreen), findsOneWidget);
        await h.otp.verify(tester, taps: 3);
        expect(h.otp.verifies, 1);
        expect(h.mutations, 0);
        h.otp.saveGate!.complete();
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
  flow(
    'mixed navigation cancel preserves configuration/signature; retry is fresh',
    (tester, h) async {
      await h.submit(tester);
      h.router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(AutoTopUpAuthorizationScreen), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Test Subscriber',
      );
      final screen = tester.widget<AutoTopUpAuthorizationScreen>(
        find.byType(AutoTopUpAuthorizationScreen),
      );
      expect(screen.balanceThreshold, 20);
      expect(screen.autoTopUpAmount, 25);
      expect(screen.cardToken, 'synthetic-card');
      expect(h.mutations, 0);
      await h.submit(tester);
      expect(h.otp.challenges, 2);
      await h.otp.verify(tester);
      await h.finish(tester);
      expect(h.mutations, 1);
    },
  );
  for (final failure in [
    'challenge',
    'invalid OTP',
    'verification transport',
    'save',
  ]) {
    flow('$failure failure has zero mutations and no false success', (
      tester,
      h,
    ) async {
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
      await h.submit(tester);
      if (failure != 'challenge') {
        await h.otp.verify(tester);
      }
      await h.finish(tester);
      expect(h.mutations, 0);
      expect(find.text('home destination'), findsNothing);
      expect(find.text('auto top-up successfully started'), findsNothing);
    });
  }
  for (final change in ['logout', 'replacement', 'dispose', 'signature']) {
    flow('$change during OTP rejects delayed verification', (tester, h) async {
      await h.submit(tester);
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
      if (change == 'signature') {
        final field = tester.widget<TextField>(
          find.descendant(
            of: find.byType(AutoTopUpAuthorizationScreen, skipOffstage: false),
            matching: find.byType(TextField, skipOffstage: false),
            skipOffstage: false,
          ),
        );
        field.controller!.text = 'Different Subscriber';
      }
      h.otp.verifyGate!.complete();
      await h.finish(tester);
      expect(h.mutations, 0);
    });
  }
  flow('backend failure preserves error and permits another fresh attempt', (
    tester,
    h,
  ) async {
    h.mutationSuccess = false;
    await h.submit(tester);
    await h.otp.verify(tester);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();
    expect(
      find.text('Failed to update settings. Please try again.'),
      findsOneWidget,
    );
    expect(h.mutations, 1);
    await h.submit(tester);
    expect(h.otp.challenges, 2);
  });

  for (final change in ['threshold', 'amount', 'card']) {
    flow('changed $change snapshot during session save cannot mutate', (
      tester,
      h,
    ) async {
      await h.submit(tester);
      h.otp.saveGate = Completer<void>();
      await h.otp.verify(tester);
      final element =
          tester.element(
                find.byType(AutoTopUpAuthorizationScreen, skipOffstage: false),
              )
              as StatefulElement;
      element.owner!.buildScope(
        element,
        () => element.update(
          AutoTopUpAuthorizationScreen(
            balanceThreshold: change == 'threshold' ? 30 : 20,
            autoTopUpAmount: change == 'amount' ? 35 : 25,
            cardToken: change == 'card'
                ? 'synthetic-other-card'
                : 'synthetic-card',
            cardLastDigits: '1234',
          ),
        ),
      );
      h.otp.saveGate!.complete();
      await h.finish(tester);
      expect(h.mutations, 0);
      expect(find.byType(AutoTopUpAuthorizationScreen), findsOneWidget);
    });
  }
  flow('session-save failure can retry without a false prior mutation', (
    tester,
    h,
  ) async {
    h.otp.saveFailure = StateError('synthetic storage failure');
    await h.submit(tester);
    await h.otp.verify(tester);
    expect(h.mutations, 0);
    h.otp.saveFailure = null;
    await h.otp.verify(tester);
    await h.finish(tester);
    expect(h.otp.saves, 2);
    expect(h.mutations, 1);
  });
  flow('forged route result without persisted OTP is rejected', (
    tester,
    h,
  ) async {
    await h.submit(tester);
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
  });
  flow('disposed authorization ignores a late Challenge', (tester, h) async {
    h.otp.challengeGate = Completer<CallLogsChallenge>();
    await h.submit(tester, taps: 3);
    expect(h.otp.challenges, 1);
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
  });
}
