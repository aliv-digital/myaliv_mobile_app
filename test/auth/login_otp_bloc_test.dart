import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';

import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/services/auth_completion_service.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_resend_response_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_verify_response_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/repository/base_login_otp_repository.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

class MockOtpRepository extends Mock implements BaseLoginOtpRepository {}

class FakeAuthCompletionService extends Fake implements AuthCompletionService {
  @override
  Future<void> complete({
    required TokenSession session,
    required AppUiConfigCubit appUiConfigCubit,
  }) async {}
}

class FakeAnalyticsService extends Fake implements AnalyticsService {
  @override
  Future<void> logLogin() async {}
}

class _FakeInternetConnection extends Fake implements InternetConnection {
  final bool isConnected;
  _FakeInternetConnection({required this.isConnected});

  @override
  Future<bool> get hasInternetAccess async => isConnected;
}

TokenSession _fakeSession() => TokenSession(
      accessToken: 'access',
      refreshToken: 'refresh',
      accessExpiresAt: DateTime.now().add(const Duration(hours: 1)),
      refreshExpiresAt: DateTime.now().add(const Duration(days: 30)),
    );

LoginOtpBloc _buildBloc({
  required MockOtpRepository repository,
  bool connected = true,
  String initialMfaToken = 'mfa_token',
  String initialApiPhoneNumber = '2427654321',
}) {
  return LoginOtpBloc(
    repository: repository,
    appUiConfigCubit: AppUiConfigCubit(),
    authCompletionService: FakeAuthCompletionService(),
    analyticsService: FakeAnalyticsService(),
    internetConnection: _FakeInternetConnection(isConnected: connected),
    initialMfaToken: initialMfaToken,
    initialApiPhoneNumber: initialApiPhoneNumber,
    initialPhoneNumber: '242-765-4321',
  );
}

void main() {
  late MockOtpRepository repository;

  setUp(() {
    repository = MockOtpRepository();
  });

  group('LoginOtpBloc — code changed event', () {
    blocTest<LoginOtpBloc, LoginOtpState>(
      'updates code and resets error state',
      build: () => _buildBloc(repository: repository),
      act: (bloc) => bloc.add(const LoginOtpCodeChanged('123456')),
      expect: () => [
        isA<LoginOtpState>()
            .having((s) => s.code, 'code', '123456')
            .having((s) => s.status, 'status', LoginOtpStatus.initial)
            .having((s) => s.errorType, 'errorType', LoginOtpErrorType.none)
            .having((s) => s.codeFieldError, 'codeFieldError', false),
      ],
    );
  });

  group('LoginOtpBloc — submit local validation', () {
    blocTest<LoginOtpBloc, LoginOtpState>(
      'emits missingVerificationContext when mfaToken is empty',
      build: () => _buildBloc(
        repository: repository,
        initialMfaToken: '',
        initialApiPhoneNumber: '',
      ),
      seed: () => const LoginOtpState(
        code: '123456',
        mfaToken: '',
        apiPhoneNumber: '',
      ),
      act: (bloc) => bloc.add(const LoginOtpSubmitted()),
      expect: () => [
        isA<LoginOtpState>()
            .having((s) => s.status, 'status', LoginOtpStatus.failure)
            .having(
              (s) => s.errorType,
              'errorType',
              LoginOtpErrorType.missingVerificationContext,
            ),
      ],
    );

    blocTest<LoginOtpBloc, LoginOtpState>(
      'emits emptyCode error when code is blank',
      build: () => _buildBloc(repository: repository),
      seed: () => const LoginOtpState(
        code: '',
        mfaToken: 'tok',
        apiPhoneNumber: '2427654321',
      ),
      act: (bloc) => bloc.add(const LoginOtpSubmitted()),
      expect: () => [
        isA<LoginOtpState>()
            .having((s) => s.status, 'status', LoginOtpStatus.failure)
            .having((s) => s.errorType, 'errorType', LoginOtpErrorType.emptyCode)
            .having((s) => s.codeFieldError, 'codeFieldError', true),
      ],
    );

    blocTest<LoginOtpBloc, LoginOtpState>(
      'emits incompleteCode error when code has fewer than 6 digits',
      build: () => _buildBloc(repository: repository),
      seed: () => const LoginOtpState(
        code: '123',
        mfaToken: 'tok',
        apiPhoneNumber: '2427654321',
      ),
      act: (bloc) => bloc.add(const LoginOtpSubmitted()),
      expect: () => [
        isA<LoginOtpState>()
            .having((s) => s.status, 'status', LoginOtpStatus.failure)
            .having(
              (s) => s.errorType,
              'errorType',
              LoginOtpErrorType.incompleteCode,
            )
            .having((s) => s.codeFieldError, 'codeFieldError', true),
      ],
    );

    blocTest<LoginOtpBloc, LoginOtpState>(
      'does not call repository on validation failure',
      build: () => _buildBloc(repository: repository),
      seed: () => const LoginOtpState(
        code: '',
        mfaToken: 'tok',
        apiPhoneNumber: '2427654321',
      ),
      act: (bloc) => bloc.add(const LoginOtpSubmitted()),
      verify: (_) => verifyNever(() => repository.verifyCode(
            phoneNumber: any(named: 'phoneNumber'),
            mfaToken: any(named: 'mfaToken'),
            otpCode: any(named: 'otpCode'),
          )),
    );
  });

  group('LoginOtpBloc — submit with network', () {
    blocTest<LoginOtpBloc, LoginOtpState>(
      'emits failure with no internet message when offline',
      build: () => _buildBloc(repository: repository, connected: false),
      seed: () => const LoginOtpState(
        code: '123456',
        mfaToken: 'tok',
        apiPhoneNumber: '2427654321',
      ),
      act: (bloc) => bloc.add(const LoginOtpSubmitted()),
      expect: () => [
        isA<LoginOtpState>()
            .having((s) => s.status, 'status', LoginOtpStatus.failure)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('No Internet'),
            ),
      ],
    );

    blocTest<LoginOtpBloc, LoginOtpState>(
      'emits [loading, success] on valid OTP',
      build: () {
        when(() => repository.verifyCode(
              phoneNumber: any(named: 'phoneNumber'),
              mfaToken: any(named: 'mfaToken'),
              otpCode: any(named: 'otpCode'),
            )).thenAnswer(
          (_) async => LoginOtpVerifyResponse(session: _fakeSession()),
        );
        return _buildBloc(repository: repository);
      },
      seed: () => const LoginOtpState(
        code: '123456',
        mfaToken: 'tok',
        apiPhoneNumber: '2427654321',
      ),
      act: (bloc) => bloc.add(const LoginOtpSubmitted()),
      wait: const Duration(milliseconds: 2000),
      expect: () => [
        isA<LoginOtpState>().having((s) => s.status, 'status', LoginOtpStatus.loading),
        isA<LoginOtpState>().having((s) => s.status, 'status', LoginOtpStatus.success),
      ],
    );

    blocTest<LoginOtpBloc, LoginOtpState>(
      'emits [loading, failure(invalidCode)] on wrong OTP',
      build: () {
        when(() => repository.verifyCode(
              phoneNumber: any(named: 'phoneNumber'),
              mfaToken: any(named: 'mfaToken'),
              otpCode: any(named: 'otpCode'),
            )).thenThrow(Exception('Invalid OTP code'));
        return _buildBloc(repository: repository);
      },
      seed: () => const LoginOtpState(
        code: '000000',
        mfaToken: 'tok',
        apiPhoneNumber: '2427654321',
      ),
      act: (bloc) => bloc.add(const LoginOtpSubmitted()),
      expect: () => [
        isA<LoginOtpState>().having((s) => s.status, 'status', LoginOtpStatus.loading),
        isA<LoginOtpState>()
            .having((s) => s.status, 'status', LoginOtpStatus.failure)
            .having((s) => s.errorType, 'errorType', LoginOtpErrorType.invalidCode)
            .having((s) => s.codeFieldError, 'codeFieldError', true),
      ],
    );

    blocTest<LoginOtpBloc, LoginOtpState>(
      'emits [loading, failure] on two-factor related error message',
      build: () {
        when(() => repository.verifyCode(
              phoneNumber: any(named: 'phoneNumber'),
              mfaToken: any(named: 'mfaToken'),
              otpCode: any(named: 'otpCode'),
            )).thenThrow(Exception('two factor verification failed'));
        return _buildBloc(repository: repository);
      },
      seed: () => const LoginOtpState(
        code: '000000',
        mfaToken: 'tok',
        apiPhoneNumber: '2427654321',
      ),
      act: (bloc) => bloc.add(const LoginOtpSubmitted()),
      expect: () => [
        isA<LoginOtpState>().having((s) => s.status, 'status', LoginOtpStatus.loading),
        isA<LoginOtpState>()
            .having((s) => s.status, 'status', LoginOtpStatus.failure)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Invalid OTP',
            ),
      ],
    );
  });

  group('LoginOtpBloc — resend OTP', () {
    blocTest<LoginOtpBloc, LoginOtpState>(
      'emits [resendLoading, resendDone, resendIdle] on success',
      build: () {
        when(() => repository.resendCode(
              phoneNumber: any(named: 'phoneNumber'),
              mfaToken: any(named: 'mfaToken'),
            )).thenAnswer(
          (_) async => const LoginOtpResendResponse(mfaToken: 'new_mfa_token'),
        );
        return _buildBloc(repository: repository);
      },
      seed: () => const LoginOtpState(
        mfaToken: 'old_token',
        apiPhoneNumber: '2427654321',
      ),
      act: (bloc) => bloc.add(const LoginOtpResendRequested()),
      expect: () => [
        isA<LoginOtpState>().having(
          (s) => s.resendStatus,
          'resendStatus',
          LoginOtpResendStatus.loading,
        ),
        isA<LoginOtpState>()
            .having((s) => s.resendStatus, 'resendStatus', LoginOtpResendStatus.done)
            .having((s) => s.mfaToken, 'mfaToken', 'new_mfa_token'),
        isA<LoginOtpState>()
            .having((s) => s.resendStatus, 'resendStatus', LoginOtpResendStatus.idle)
            .having((s) => s.mfaToken, 'mfaToken', 'new_mfa_token'),
      ],
    );

    blocTest<LoginOtpBloc, LoginOtpState>(
      'emits idle with error message on resend failure',
      build: () {
        when(() => repository.resendCode(
              phoneNumber: any(named: 'phoneNumber'),
              mfaToken: any(named: 'mfaToken'),
            )).thenThrow(Exception('Resend failed'));
        return _buildBloc(repository: repository);
      },
      seed: () => const LoginOtpState(
        mfaToken: 'tok',
        apiPhoneNumber: '2427654321',
      ),
      act: (bloc) => bloc.add(const LoginOtpResendRequested()),
      expect: () => [
        isA<LoginOtpState>().having(
          (s) => s.resendStatus,
          'resendStatus',
          LoginOtpResendStatus.loading,
        ),
        isA<LoginOtpState>()
            .having((s) => s.resendStatus, 'resendStatus', LoginOtpResendStatus.idle)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('Resend failed'),
            ),
      ],
    );

    blocTest<LoginOtpBloc, LoginOtpState>(
      'emits idle with error when context is missing for resend',
      build: () => _buildBloc(
        repository: repository,
        initialMfaToken: '',
        initialApiPhoneNumber: '',
      ),
      seed: () => const LoginOtpState(mfaToken: '', apiPhoneNumber: ''),
      act: (bloc) => bloc.add(const LoginOtpResendRequested()),
      expect: () => [
        isA<LoginOtpState>()
            .having((s) => s.resendStatus, 'resendStatus', LoginOtpResendStatus.idle)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });
}
