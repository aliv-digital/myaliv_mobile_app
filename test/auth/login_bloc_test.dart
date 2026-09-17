import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:core/core.dart';

import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/bloc/auth_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/bloc/auth_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/bloc/auth_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/model/auth_response_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/repository/auth_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/services/auth_completion_service.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

class MockLoginRepository extends Mock implements LoginRepository {}

class FakeAuthCompletionService extends Fake implements AuthCompletionService {
  @override
  Future<void> complete({
    required TokenSession session,
    required AppUiConfigCubit appUiConfigCubit,
  }) async {}
}

class _FakeInternetConnection extends Fake implements InternetConnection {
  final bool isConnected;
  _FakeInternetConnection({required this.isConnected});

  @override
  Future<bool> get hasInternetAccess async => isConnected;
}

LoginBloc _buildBloc({
  required MockLoginRepository repository,
  bool connected = true,
  AuthCompletionService? completionService,
}) {
  return LoginBloc(
    repository: repository,
    appUiConfigCubit: AppUiConfigCubit(),
    authCompletionService: completionService ?? FakeAuthCompletionService(),
    internetConnection: _FakeInternetConnection(isConnected: connected),
  );
}

TokenSession _fakeSession() => TokenSession(
      accessToken: 'access',
      refreshToken: 'refresh',
      accessExpiresAt: DateTime.now().add(const Duration(hours: 1)),
      refreshExpiresAt: DateTime.now().add(const Duration(days: 30)),
    );

void main() {
  late MockLoginRepository repository;

  setUp(() {
    repository = MockLoginRepository();
  });

  group('LoginBloc — field events', () {
    blocTest<LoginBloc, LoginState>(
      'LoginPhoneChanged updates phone and clears errors',
      build: () => _buildBloc(repository: repository),
      act: (bloc) => bloc.add(const LoginPhoneChanged('2427654321')),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.phone, 'phone', '2427654321')
            .having((s) => s.status, 'status', LoginStatus.initial)
            .having((s) => s.phoneFieldError, 'phoneFieldError', false),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'LoginPasswordChanged updates password and clears errors',
      build: () => _buildBloc(repository: repository),
      act: (bloc) => bloc.add(const LoginPasswordChanged('secret')),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.password, 'password', 'secret')
            .having((s) => s.passwordFieldError, 'passwordFieldError', false),
      ],
    );
  });

  group('LoginBloc — field validation on submit', () {
    blocTest<LoginBloc, LoginState>(
      'emits failure with phone error when phone is empty',
      build: () => _buildBloc(repository: repository),
      seed: () => const LoginState(phone: '', password: 'secret'),
      act: (bloc) => bloc.add(const LoginSubmitted()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.failure)
            .having((s) => s.phoneFieldError, 'phoneFieldError', true)
            .having((s) => s.passwordFieldError, 'passwordFieldError', false),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits failure with password error when password is empty',
      build: () => _buildBloc(repository: repository),
      seed: () => const LoginState(phone: '2427654321', password: ''),
      act: (bloc) => bloc.add(const LoginSubmitted()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.failure)
            .having((s) => s.phoneFieldError, 'phoneFieldError', false)
            .having((s) => s.passwordFieldError, 'passwordFieldError', true),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits failure with both field errors when both are empty',
      build: () => _buildBloc(repository: repository),
      seed: () => const LoginState(phone: '', password: ''),
      act: (bloc) => bloc.add(const LoginSubmitted()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.phoneFieldError, 'phoneFieldError', true)
            .having((s) => s.passwordFieldError, 'passwordFieldError', true),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'does not call repository when fields are empty',
      build: () => _buildBloc(repository: repository),
      seed: () => const LoginState(phone: '', password: ''),
      act: (bloc) => bloc.add(const LoginSubmitted()),
      verify: (_) => verifyNever(() => repository.login(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )),
    );
  });

  group('LoginBloc — submit with valid Bahamas number', () {
    // 7-digit Bahamas number, which is valid for BS
    const validPhone = '3241234';
    const password = 'mypassword';

    blocTest<LoginBloc, LoginState>(
      'emits no internet failure when offline',
      build: () => _buildBloc(repository: repository, connected: false),
      seed: () => const LoginState(phone: validPhone, password: password),
      act: (bloc) => bloc.add(const LoginSubmitted()),
      expect: () => [
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.failure)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('No Internet'),
            ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [loading, success(needsOtp)] on MFA challenge',
      build: () {
        when(() => repository.login(
              username: any(named: 'username'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => const LoginMfaChallenge(mfaToken: 'mfa123'));
        return _buildBloc(repository: repository);
      },
      seed: () => const LoginState(phone: validPhone, password: password),
      act: (bloc) => bloc.add(const LoginSubmitted()),
      expect: () => [
        isA<LoginState>().having((s) => s.status, 'status', LoginStatus.loading),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.success)
            .having((s) => s.outcome, 'outcome', LoginOutcome.needsOtp)
            .having((s) => s.mfaToken, 'mfaToken', 'mfa123'),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [loading, success(authenticated)] on direct login',
      build: () {
        when(() => repository.login(
              username: any(named: 'username'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => LoginSuccess(_fakeSession()));
        return _buildBloc(repository: repository);
      },
      seed: () => const LoginState(phone: validPhone, password: password),
      act: (bloc) => bloc.add(const LoginSubmitted()),
      expect: () => [
        isA<LoginState>().having((s) => s.status, 'status', LoginStatus.loading),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.success)
            .having((s) => s.outcome, 'outcome', LoginOutcome.authenticated),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [loading, failure] with "Invalid Credentials" on FailedUsernameOrPassword',
      build: () {
        when(() => repository.login(
              username: any(named: 'username'),
              password: any(named: 'password'),
            )).thenThrow(Exception('FailedUsernameOrPassword'));
        return _buildBloc(repository: repository);
      },
      seed: () => const LoginState(phone: validPhone, password: password),
      act: (bloc) => bloc.add(const LoginSubmitted()),
      expect: () => [
        isA<LoginState>().having((s) => s.status, 'status', LoginStatus.loading),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.failure)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('Invalid Credentials'),
            ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [loading, failure] with lockout message on FailedUsernameIsLocked',
      build: () {
        when(() => repository.login(
              username: any(named: 'username'),
              password: any(named: 'password'),
            )).thenThrow(Exception('FailedUsernameIsLocked'));
        return _buildBloc(repository: repository);
      },
      seed: () => const LoginState(phone: validPhone, password: password),
      act: (bloc) => bloc.add(const LoginSubmitted()),
      expect: () => [
        isA<LoginState>().having((s) => s.status, 'status', LoginStatus.loading),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.failure)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('locked'),
            ),
      ],
    );
  });
}
