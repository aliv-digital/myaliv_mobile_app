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
  group('Change Password action gate', () {
    late _PasswordRepository repository;
    late ChangePasswordPrepaidBloc bloc;
    Completer<ActionVerifiedResult<ProtectedAccountAction>?>? pending;
    late Object attempt;
    int challenges = 0;
    String outcome = 'success';
    int cancellations = 0;
    setUp(() {
      repository = _PasswordRepository();
      pending = null;
      challenges = cancellations = 0;
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
          if (outcome != 'success') {
            return null;
          }
          return _verified(id, ProtectedAccountAction.changePassword);
        },
        cancelVerification: () => cancellations++,
      );
    });
    tearDown(() async {
      if (!bloc.isClosed) {
        await bloc.close();
      }
    });
    Future<void> valid() async {
      bloc.add(const ChangePasswordPrepaidNewChanged('Synthetic123!'));
      bloc.add(const ChangePasswordPrepaidConfirmChanged('Synthetic123!'));
      await _flush();
    }

    test('existing validation runs before any challenge', () async {
      bloc.add(const ChangePasswordPrepaidSubmitPressed());
      await _flush();
      expect(challenges, 0);
      expect(
        bloc.state.newPasswordError,
        'password does not meet the requirement',
      );
      verifyNever(
        () => repository.changePassword(newPassword: any(named: 'newPassword')),
      );
    });

    test(
      'waits for verification; password remains form-local; rapid taps submit once',
      () async {
        pending = Completer();
        await valid();
        bloc.add(const ChangePasswordPrepaidSubmitPressed());
        bloc.add(const ChangePasswordPrepaidSubmitPressed());
        await _flush();
        expect(bloc.state.status, ChangePasswordPrepaidStatus.verifying);
        expect(challenges, 1);
        verifyNever(
          () =>
              repository.changePassword(newPassword: any(named: 'newPassword')),
        );
        pending!.complete(
          _verified(attempt, ProtectedAccountAction.changePassword),
        );
        await _flush();
        expect(bloc.state.status, ChangePasswordPrepaidStatus.success);
        verify(
          () => repository.changePassword(newPassword: 'Synthetic123!'),
        ).called(1);
      },
    );

    test(
      'immediate second submission requires a new verified attempt',
      () async {
        await valid();
        for (var i = 0; i < 2; i++) {
          bloc.add(const ChangePasswordPrepaidSubmitPressed());
          await _flush();
        }
        expect(challenges, 2);
        verify(
          () => repository.changePassword(newPassword: 'Synthetic123!'),
        ).called(2);
      },
    );

    for (final failure in [
      'challenge failure',
      'invalid OTP',
      'save failure',
      'cancel',
    ]) {
      test('$failure: no password mutation', () async {
        outcome = failure;
        await valid();
        bloc.add(const ChangePasswordPrepaidSubmitPressed());
        await _flush();
        expect(challenges, 1);
        verifyNever(
          () =>
              repository.changePassword(newPassword: any(named: 'newPassword')),
        );
      });
    }

    test(
      'changed form values invalidate the pending password snapshot',
      () async {
        pending = Completer();
        await valid();
        bloc.add(const ChangePasswordPrepaidSubmitPressed());
        await _flush();
        bloc.add(const ChangePasswordPrepaidNewChanged('Different123!'));
        await _flush();
        pending!.complete(
          _verified(attempt, ProtectedAccountAction.changePassword),
        );
        await _flush();
        verifyNever(
          () =>
              repository.changePassword(newPassword: any(named: 'newPassword')),
        );
        expect(bloc.state.status, ChangePasswordPrepaidStatus.ready);
      },
    );

    test('backend failure keeps existing error wording', () async {
      when(
        () => repository.changePassword(newPassword: any(named: 'newPassword')),
      ).thenAnswer((_) async => false);
      await valid();
      bloc.add(const ChangePasswordPrepaidSubmitPressed());
      await _flush();
      expect(
        bloc.state.errorMessage,
        'failed to update password. please try again.',
      );
      expect(bloc.state.status, ChangePasswordPrepaidStatus.failure);
    });

    test(
      'disposed form cancels verification and ignores late result',
      () async {
        pending = Completer();
        await valid();
        bloc.add(const ChangePasswordPrepaidSubmitPressed());
        await _flush();
        final closing = bloc.close();
        pending!.complete(
          _verified(attempt, ProtectedAccountAction.changePassword),
        );
        await closing;
        expect(cancellations, 1);
        verifyNever(
          () =>
              repository.changePassword(newPassword: any(named: 'newPassword')),
        );
      },
    );
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
