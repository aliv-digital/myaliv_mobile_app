import 'dart:async' show Completer;

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/logic/password_recovery_otp_attempts.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/repository/password_recovery_otp_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/services/auth_completion_service.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/login_otp_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/services/login_otp_api_client.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

import 'support/recovery_otp_network_harness.dart';

class _Auth extends Mock implements AuthManager {}

class _Connected extends Fake implements InternetConnection {
  @override
  Future<bool> get hasInternetAccess async => true;
}

class _Completion extends Fake implements AuthCompletionService {
  @override
  Future<void> complete({
    required TokenSession session,
    required AppUiConfigCubit appUiConfigCubit,
  }) async {}
}

class _Analytics extends Fake implements AnalyticsService {
  @override
  Future<void> logLogin() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RecoveryOtpNetworkHarness harness;
  late PasswordRecoveryOtpAttempts attempts;
  late PasswordRecoveryOtpRepository repository;
  late LoginOtpRepository delegate;
  LoginOtpBloc? bloc;
  AppUiConfigCubit? config;

  setUp(() async {
    harness = RecoveryOtpNetworkHarness(authManager: _Auth());
    await harness
        .open(); // Includes the real disk-cookie interceptor in these tests.
    attempts = PasswordRecoveryOtpAttempts(mfaToken: 'original-challenge');
    delegate = LoginOtpRepository(
      apiClient: LoginOtpApiClient(networkService: harness.network),
    );
    repository = PasswordRecoveryOtpRepository(
      delegate: delegate,
      attempts: attempts,
    );
    bloc = null;
    config = null;
  });

  tearDown(() async {
    harness.transport.pendingVerification?.complete();
    await bloc?.close();
    await config?.close();
    await harness.close();
  });

  Future<PasswordRecoveryInvalidOtpException> incorrect({
    String token = 'original-challenge',
  }) async {
    try {
      await repository.verifyCode(
        phoneNumber: '2427654321',
        mfaToken: token,
        otpCode: '000000',
      );
      fail('Expected confirmed invalid OTP');
    } on PasswordRecoveryInvalidOtpException catch (error) {
      return error;
    }
  }

  Future<void> fourIncorrect() async {
    for (var i = 1; i <= 4; i++) {
      final error = await incorrect();
      expect(error.feedback?.incorrectAttempts, i);
      expect(error.toString(), 'Two Factor Key Invalid');
    }
  }

  for (final jsonContent in [true, false]) {
    test(
      'real HTTP 400 code 202 maps to a typed invalid OTP for JSON=$jsonContent',
      () async {
        harness.transport.jsonContentType = jsonContent;
        final error = await incorrect();
        expect(error.cause.statusCode, 400);
        expect(
          error.cause.data,
          jsonContent ? invalidRecoveryOtpBody : isA<String>(),
        );
        expect(error.feedback?.incorrectAttempts, 1);
        expect(error.toString(), 'Two Factor Key Invalid');
        expect(harness.transport.verifyRequests.single.data, {
          'PhoneNumber': '2427654321',
          'mfa_token': 'original-challenge',
          'otp_code': '000000',
          'Channel': kAuthChannel,
        });
        expect(
          harness.transport.verifyRequests.single.extra['skipAuth'],
          isTrue,
        );
        expect(harness.hardLogouts, 0);
      },
    );
  }

  test(
    'fifth actual HTTP 400 result selects the notice, not a sixth request',
    () async {
      await fourIncorrect();
      final fifth = await incorrect();
      expect(fifth.feedback?.incorrectAttempts, 5);
      expect(fifth.toString(), requiredRecoveryOtpMessage);
      expect(harness.transport.verifyRequests.length, 5);
      expect((await incorrect()).toString(), requiredRecoveryOtpMessage);
    },
  );

  final unrelated = <String, OtpHttpReply>{
    'HTTP 400 alone': const OtpHttpReply(400, {
      'Message': 'Two Factor Key Invalid',
    }),
    'different error code': const OtpHttpReply(400, {
      'ErrorCode': 203,
      'ErrorCodeName': 'TwoFactorKeyInvalid',
      'Message': 'Different error',
    }),
    'different error name': const OtpHttpReply(400, {
      'ErrorCode': 202,
      'ErrorCodeName': 'TwoFactorKeyExpired',
      'Message': 'OTP expired',
    }),
    'expired OTP': const OtpHttpReply(400, {
      'ErrorCode': 203,
      'ErrorCodeName': 'TwoFactorKeyExpired',
      'Message': 'OTP expired',
    }),
    'unauthorized': const OtpHttpReply(401, invalidRecoveryOtpBody),
    'server error': const OtpHttpReply(503, invalidRecoveryOtpBody),
    'backend lock': const OtpHttpReply(423, invalidRecoveryOtpBody),
    'backend retry limit': const OtpHttpReply(429, {
      'Message': 'Too many attempts. Try again later.',
    }),
  };
  for (final entry in unrelated.entries) {
    test(
      '${entry.key} is not counted and retains the existing sequence',
      () async {
        await fourIncorrect();
        harness.transport.verifyReplies.add(entry.value);
        await expectLater(
          repository.verifyCode(
            phoneNumber: '2427654321',
            mfaToken: 'original-challenge',
            otpCode: '000000',
          ),
          throwsA(isA<NetworkException>()),
        );
        expect((await incorrect()).feedback?.incorrectAttempts, 5);
      },
    );
  }

  for (final type in [
    DioExceptionType.connectionError,
    DioExceptionType.receiveTimeout,
  ]) {
    test('$type does not increment or reset the invalid count', () async {
      await fourIncorrect();
      harness.transport.transportFailure = type;
      await expectLater(
        repository.verifyCode(
          phoneNumber: '2427654321',
          mfaToken: 'original-challenge',
          otpCode: '000000',
        ),
        throwsA(isA<NetworkException>()),
      );
      harness.transport.transportFailure = null;
      expect((await incorrect()).feedback?.incorrectAttempts, 5);
    });
  }

  test(
    'structured code mapping does not rely on the human-readable Message',
    () async {
      harness.transport.invalidReply = OtpHttpReply(400, {
        ...invalidRecoveryOtpBody,
        'Message': 'Different localized message',
      });
      for (var i = 1; i <= 5; i++) {
        final error = await incorrect();
        expect(error.feedback?.incorrectAttempts, i);
        expect(
          error.toString(),
          i == 5 ? requiredRecoveryOtpMessage : 'Different localized message',
        );
      }
    },
  );

  test('a valid repository response ends the sequence', () async {
    await fourIncorrect();
    harness.transport.successfulAttempt = 5;
    final result = await repository.verifyCode(
      phoneNumber: '2427654321',
      mfaToken: 'original-challenge',
      otpCode: '123456',
    );
    expect(result.session.accessToken, 'test-access');
    expect((await incorrect()).feedback?.incorrectAttempts, 1);
  });

  test(
    'successful rotated resend starts a new challenge and ignores late old-token failures',
    () async {
      await fourIncorrect();
      await repository.resendCode(
        phoneNumber: '2427654321',
        mfaToken: 'original-challenge',
      );
      expect(attempts.mfaToken, 'replacement-challenge');
      expect((await incorrect()).feedback, isNull);
      for (var i = 1; i <= 5; i++) {
        final error = await incorrect(token: 'replacement-challenge');
        expect(error.feedback?.incorrectAttempts, i);
        expect(
          error.feedback?.message,
          i == 5 ? requiredRecoveryOtpMessage : null,
        );
      }
    },
  );

  for (final reply in [
    const OtpHttpReply(429, {'Message': 'Please wait before resending.'}),
    const OtpHttpReply(200, {'mfa_token': ''}),
  ]) {
    test(
      'failed resend status=${reply.status} does not reset tracking',
      () async {
        await fourIncorrect();
        harness.transport.resendReply = reply;
        await expectLater(
          repository.resendCode(
            phoneNumber: '2427654321',
            mfaToken: 'original-challenge',
          ),
          throwsException,
        );
        expect(attempts.mfaToken, 'original-challenge');
        expect((await incorrect()).feedback?.incorrectAttempts, 5);
      },
    );
  }

  test(
    'successful same-token resend does not invent a replacement challenge',
    () async {
      await fourIncorrect();
      harness.transport.resendReply = const OtpHttpReply(200, {
        'mfa_token': 'original-challenge',
      });
      await repository.resendCode(
        phoneNumber: '2427654321',
        mfaToken: 'original-challenge',
      );
      expect((await incorrect()).feedback?.incorrectAttempts, 5);
    },
  );

  test(
    'recreating the repository for the same challenge retains its counter',
    () async {
      await fourIncorrect();
      repository = PasswordRecoveryOtpRepository(
        delegate: delegate,
        attempts: attempts,
      );
      expect((await incorrect()).feedback?.incorrectAttempts, 5);
    },
  );

  test(
    'normal Login repository keeps the original NetworkException beyond five',
    () async {
      for (var i = 0; i < 6; i++) {
        await expectLater(
          delegate.verifyCode(
            phoneNumber: '2427654321',
            mfaToken: 'original-challenge',
            otpCode: '000000',
          ),
          throwsA(
            isA<NetworkException>().having(
              (error) => error.data,
              'original body',
              invalidRecoveryOtpBody,
            ),
          ),
        );
      }
      expect((await incorrect()).feedback?.incorrectAttempts, 1);
    },
  );

  LoginOtpBloc openBloc() {
    config = AppUiConfigCubit();
    return bloc = LoginOtpBloc(
      repository: repository,
      appUiConfigCubit: config!,
      authCompletionService: _Completion(),
      analyticsService: _Analytics(),
      internetConnection: _Connected(),
      initialMfaToken: 'original-challenge',
      initialApiPhoneNumber: '2427654321',
      preventDuplicateSubmissions: true,
      resetValidationOnResend: true,
    );
  }

  Future<LoginOtpState> submit({String code = '000000'}) async {
    if (bloc!.state.code != code) {
      final changed = bloc!.stream.firstWhere((state) => state.code == code);
      bloc!.add(LoginOtpCodeChanged(code));
      await changed;
    }
    final done = bloc!.stream.firstWhere(
      (state) =>
          state.status == LoginOtpStatus.failure ||
          state.status == LoginOtpStatus.success,
    );
    bloc!.add(const LoginOtpSubmitted());
    final result = await done.timeout(const Duration(seconds: 10));
    await Future<void>.delayed(Duration.zero);
    return result;
  }

  test('incomplete submissions do not reach HTTP or the tracker', () async {
    openBloc();
    for (var i = 0; i < 4; i++) {
      expect((await submit()).errorMessage, 'Invalid OTP');
    }
    expect(
      (await submit(code: '123')).errorType,
      LoginOtpErrorType.incompleteCode,
    );
    expect((await submit(code: '')).errorType, LoginOtpErrorType.emptyCode);
    expect(harness.transport.verifyRequests.length, 4);
    expect((await submit()).errorMessage, requiredRecoveryOtpMessage);
  });

  test(
    'duplicate Verify events produce one HTTP request and one count',
    () async {
      openBloc();
      for (var i = 0; i < 3; i++) {
        await submit();
      }
      final gate = Completer<void>();
      harness.transport.pendingVerification = gate;
      final started = Completer<void>();
      harness.transport.verificationStarted = started;
      final loaded = bloc!.stream.firstWhere(
        (state) => state.status == LoginOtpStatus.loading,
      );
      final pending = submit();
      await loaded;
      await started.future;
      for (var i = 0; i < 8; i++) {
        bloc!.add(const LoginOtpSubmitted());
      }
      await Future<void>.delayed(Duration.zero);
      expect(harness.transport.verifyRequests.length, 4);
      gate.complete();
      harness.transport.pendingVerification = null;
      expect((await pending).errorMessage, 'Invalid OTP');
      expect((await submit()).errorMessage, requiredRecoveryOtpMessage);
      expect(harness.transport.verifyRequests.length, 5);
    },
  );

  test('the UI notice does not create a security lockout', () async {
    await fourIncorrect();
    expect((await incorrect()).toString(), requiredRecoveryOtpMessage);
    harness.transport.successfulAttempt = 6;
    final result = await repository.verifyCode(
      phoneNumber: '2427654321',
      mfaToken: 'original-challenge',
      otpCode: '123456',
    );
    expect(result.session.accessToken, 'test-access');
  });
}
