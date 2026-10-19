import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/bloc/change_password_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/bloc/change_password_prepaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/bloc/change_password_prepaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/repository/change_password_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_state.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/device_limits_model.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/models/update_limits_request.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/verification/upgrade_credit_limit_submission.dart';
import 'package:myaliv_mobile_app/app/common/verification/action_verified_result.dart';

class _PasswordRepository extends Mock
    implements ChangePasswordPrepaidRepository {}

class _Devices extends Mock implements DeviceLimitsCubit {}

Future<void> _flush() async {
  for (var i = 0; i < 8; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

ActionVerifiedResult<ProtectedAccountAction> _verified(
  Object id,
  ProtectedAccountAction purpose,
) => ActionVerifiedResult(
  attemptId: id,
  paymentMethod: purpose,
  canConsume: () => true,
);

const _request = UpdateLimitsRequest(
  maxAllowedInternational: 1,
  maxAllowedRoaming: 2,
  maxAllowedLocalVoice: 3,
  maxAllowedLocalData: 4,
  maxAllowedLocalText: 5,
);

void main() {
  setUpAll(() => registerFallbackValue(_request));
  group('Change Password single-use entry authorization', () {
    late _PasswordRepository repository;
    late ChangePasswordPrepaidBloc bloc;
    Completer<ActionVerifiedResult<ProtectedAccountAction>?>? pending;
    late Object attempt;
    int challenges = 0;
    int cancellations = 0;
    bool contextCurrent = true;
    bool capabilityCurrent = true;
    String outcome = 'success';
    setUp(() {
      repository = _PasswordRepository();
      pending = null;
      challenges = cancellations = 0;
      contextCurrent = capabilityCurrent = true;
      outcome = 'success';
      when(
        () => repository.changePassword(newPassword: any(named: 'newPassword')),
      ).thenAnswer((_) async => true);
      bloc = ChangePasswordPrepaidBloc(
        repository,
        verifyAction: (id) async {
          challenges++;
          attempt = id;
          if (pending != null) {
            return pending!.future;
          }
          if (outcome == 'challenge failure' || outcome == 'save failure') {
            throw StateError('synthetic verification failure');
          }
          if (outcome == 'cancel' || outcome == 'invalid OTP') {
            return null;
          }
          return ActionVerifiedResult(
            attemptId: outcome == 'wrong attempt' ? Object() : id,
            paymentMethod: outcome == 'wrong purpose'
                ? ProtectedAccountAction.upgradeCreditLimit
                : ProtectedAccountAction.changePassword,
            canConsume: () => capabilityCurrent,
          );
        },
        cancelVerification: () => cancellations++,
        isAuthorizationCurrent: () => contextCurrent,
      );
    });
    tearDown(() async {
      if (!bloc.isClosed) {
        await bloc.close();
      }
    });
    Future<void> start() async {
      bloc.add(const ChangePasswordPrepaidStarted());
      await _flush();
    }

    Future<void> values([
      String password = 'Synthetic123!',
      String? confirm,
    ]) async {
      bloc.add(ChangePasswordPrepaidNewChanged(password));
      bloc.add(ChangePasswordPrepaidConfirmChanged(confirm ?? password));
      await _flush();
    }

    Future<void> submit() async {
      bloc.add(const ChangePasswordPrepaidSubmitPressed());
      await _flush();
    }

    test('unverified Submit cannot update or initiate a second OTP', () async {
      await values();
      await submit();
      verifyZeroInteractions(repository);
      expect(challenges, 0);
      expect(
        bloc.state.status,
        ChangePasswordPrepaidStatus.verificationCancelled,
      );
    });

    test(
      'duplicate Started and Submit wait for one entry verification',
      () async {
        pending = Completer();
        await start();
        await start();
        await values();
        await submit();
        expect(challenges, 1);
        expect(bloc.state.status, ChangePasswordPrepaidStatus.verifying);
        verifyZeroInteractions(repository);
        pending!.complete(
          _verified(attempt, ProtectedAccountAction.changePassword),
        );
        await _flush();
        expect(bloc.state.status, ChangePasswordPrepaidStatus.ready);
        verifyZeroInteractions(repository);
        bloc.add(const ChangePasswordPrepaidSubmitPressed());
        bloc.add(const ChangePasswordPrepaidSubmitPressed());
        await _flush();
        expect(challenges, 1);
        verify(
          () => repository.changePassword(newPassword: 'Synthetic123!'),
        ).called(1);
        await submit();
        verifyNoMoreInteractions(repository);
      },
    );

    for (final scenario in [
      (password: '', confirm: '', error: 'New password is required.'),
      (
        password: 'abc',
        confirm: 'abc',
        error: 'password does not meet the requirement',
      ),
      (
        password: 'a' * 65,
        confirm: 'a' * 65,
        error: 'password does not meet the requirement',
      ),
      (
        password: 'abcdefgh',
        confirm: '',
        error: 'Please re-enter your password.',
      ),
      (
        password: 'abcdefgh',
        confirm: 'abcdEfgh',
        error: 'Passwords do not match. Try again.',
      ),
    ]) {
      test(
        'validation retains the entry capability: ${scenario.error}',
        () async {
          await start();
          await values(scenario.password, scenario.confirm);
          await submit();
          expect([
            bloc.state.newPasswordError,
            bloc.state.confirmPasswordError,
          ], contains(scenario.error));
          expect(bloc.state.status, ChangePasswordPrepaidStatus.ready);
          verifyZeroInteractions(repository);
          await values();
          await submit();
          expect(challenges, 1);
          verify(
            () => repository.changePassword(newPassword: 'Synthetic123!'),
          ).called(1);
        },
      );
    }

    for (final password in [
      'abcdefgh',
      'a' * 64,
      '12345678',
      '!@#\$%^&*',
      '  abcdefgh  ',
    ]) {
      test(
        'existing accepted password length ${password.length} is trimmed',
        () async {
          await start();
          await values(password);
          await submit();
          expect(challenges, 1);
          expect(bloc.state.status, ChangePasswordPrepaidStatus.success);
          verify(
            () => repository.changePassword(newPassword: password.trim()),
          ).called(1);
        },
      );
    }

    for (final failure in [
      'challenge failure',
      'save failure',
      'invalid OTP',
      'cancel',
      'wrong attempt',
      'wrong purpose',
    ]) {
      test('$failure cannot authorize entry or mutation', () async {
        outcome = failure;
        await start();
        expect(
          bloc.state.status,
          ChangePasswordPrepaidStatus.verificationCancelled,
        );
        await values();
        await submit();
        verifyZeroInteractions(repository);
        expect(challenges, 1);
      });
    }

    for (final invalidation in ['context', 'capability', 'explicit reset']) {
      test(
        '$invalidation invalidation prevents deferred consumption',
        () async {
          await start();
          await values();
          if (invalidation == 'context') {
            contextCurrent = false;
          }
          if (invalidation == 'capability') {
            capabilityCurrent = false;
          }
          if (invalidation == 'explicit reset') {
            bloc.add(const ChangePasswordPrepaidAuthorizationInvalidated());
            await _flush();
          }
          await submit();
          verifyZeroInteractions(repository);
          expect(challenges, 1);
          expect(
            bloc.state.status,
            ChangePasswordPrepaidStatus.verificationCancelled,
          );
        },
      );
    }

    for (final throwsError in [false, true]) {
      test(
        'update failure consumes authorization and keeps existing error (throws=$throwsError)',
        () async {
          when(
            () => repository.changePassword(
              newPassword: any(named: 'newPassword'),
            ),
          ).thenAnswer((_) async {
            if (throwsError) {
              throw StateError('synthetic update failure');
            }
            return false;
          });
          await start();
          await values();
          await submit();
          expect(bloc.state.status, ChangePasswordPrepaidStatus.failure);
          expect(
            bloc.state.errorMessage,
            'failed to update password. please try again.',
          );
          await submit();
          verify(
            () => repository.changePassword(newPassword: 'Synthetic123!'),
          ).called(1);
          expect(challenges, 1);
        },
      );
    }

    test('disposed entry ignores a late verified result', () async {
      pending = Completer();
      await start();
      final closing = bloc.close();
      pending!.complete(
        _verified(attempt, ProtectedAccountAction.changePassword),
      );
      await closing;
      expect(cancellations, 1);
      verifyZeroInteractions(repository);
    });
  });

  group('Upgrade Credit Limit action gate', () {
    late _Devices devices;
    late UpgradeCreditLimitSubmission submission;
    late DeviceLimitsState state;
    late Object attempt;
    int challenges = 0;
    bool ownerActive = true;
    String outcome = 'success';
    Completer<ActionVerifiedResult<ProtectedAccountAction>?>? pending;
    setUp(() {
      devices = _Devices();
      state = DeviceLimitsState(
        status: DeviceLimitsStatus.loaded,
        allDeviceLimits: [
          DeviceLimitsModel.fromJson({'DeviceID': 123}),
        ],
      );
      when(() => devices.state).thenAnswer((_) => state);
      when(
        () => devices.updateLimits(
          deviceAccountId: any(named: 'deviceAccountId'),
          request: any(named: 'request'),
        ),
      ).thenAnswer((_) async => true);
      submission = UpgradeCreditLimitSubmission(deviceLimitsCubit: devices);
      challenges = 0;
      ownerActive = true;
      outcome = 'success';
      pending = null;
    });
    tearDown(() => submission.close());
    Future<bool> submit() => submission.submit(
      deviceId: 123,
      request: _request,
      isOwnerActive: () => ownerActive,
      verifyAction: (id) async {
        challenges++;
        attempt = id;
        if (pending != null) {
          return pending!.future;
        }
        if (outcome == 'challenge failure' || outcome == 'save failure') {
          throw StateError('synthetic verification failure');
        }
        return outcome == 'success'
            ? _verified(id, ProtectedAccountAction.upgradeCreditLimit)
            : null;
      },
    );
    test(
      'waits for verification and duplicate Proceed submits snapshot exactly once',
      () async {
        pending = Completer();
        final first = submit();
        await _flush();
        expect(await submit(), isFalse);
        expect(challenges, 1);
        verifyNever(
          () => devices.updateLimits(
            deviceAccountId: any(named: 'deviceAccountId'),
            request: any(named: 'request'),
          ),
        );
        pending!.complete(
          _verified(attempt, ProtectedAccountAction.upgradeCreditLimit),
        );
        expect(await first, isTrue);
        verify(
          () => devices.updateLimits(deviceAccountId: 123, request: _request),
        ).called(1);
      },
    );
    test('each new submission requires a fresh result', () async {
      expect(await submit(), isTrue);
      expect(await submit(), isTrue);
      expect(challenges, 2);
      verify(
        () => devices.updateLimits(deviceAccountId: 123, request: _request),
      ).called(2);
    });
    for (final failure in [
      'challenge failure',
      'invalid OTP',
      'save failure',
      'cancel',
    ]) {
      test('$failure makes no credit-limit mutation', () async {
        outcome = failure;
        if (failure == 'challenge failure' || failure == 'save failure') {
          await expectLater(submit(), throwsStateError);
        } else {
          expect(await submit(), isFalse);
        }
        verifyNever(
          () => devices.updateLimits(
            deviceAccountId: any(named: 'deviceAccountId'),
            request: any(named: 'request'),
          ),
        );
      });
    }
    for (final change in ['owner inactive', 'device changed', 'disposed']) {
      test('$change ignores late successful verification', () async {
        pending = Completer();
        final first = submit();
        await _flush();
        if (change == 'owner inactive') {
          ownerActive = false;
        }
        if (change == 'device changed') {
          state = DeviceLimitsState(
            status: DeviceLimitsStatus.loaded,
            allDeviceLimits: [
              DeviceLimitsModel.fromJson({'DeviceID': 456}),
            ],
          );
        }
        if (change == 'disposed') {
          submission.close();
        }
        pending!.complete(
          _verified(attempt, ProtectedAccountAction.upgradeCreditLimit),
        );
        expect(await first, isFalse);
        verifyNever(
          () => devices.updateLimits(
            deviceAccountId: any(named: 'deviceAccountId'),
            request: any(named: 'request'),
          ),
        );
      });
    }
    test(
      'backend failure returns unchanged result for existing UI error handling',
      () async {
        when(
          () => devices.updateLimits(
            deviceAccountId: any(named: 'deviceAccountId'),
            request: any(named: 'request'),
          ),
        ).thenAnswer((_) async => false);
        expect(await submit(), isFalse);
        verify(
          () => devices.updateLimits(deviceAccountId: 123, request: _request),
        ).called(1);
      },
    );
  });
}
