import 'dart:convert';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:finger_face_security/finger_face_security.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/bloc/auth_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/bloc/auth_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/bloc/auth_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/repository/auth_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/services/auth_completion_service.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/view/login_page.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

const _lockedBody = {
  'error': 'FailedUsernameIsLocked',
  'error_description': 'FailedUsernameIsLocked',
};
const _lockedMessage =
    'your account is locked out, please try again in 15 minutes';
const _seed = LoginState(
  phone: '2423241234',
  password: 'test-password',
  errorToastId: 7,
);

class _MockAuthManager extends Mock implements AuthManager {}

class _MockBiometrics extends MockCubit<FingerFaceSecurityState>
    implements FingerFaceSecurityCubit {}

class _Connected extends Fake implements InternetConnection {
  @override
  Future<bool> get hasInternetAccess async => true;
}

class _Completion extends Fake implements AuthCompletionService {
  int calls = 0;
  TokenSession? session;

  @override
  Future<void> complete({
    required TokenSession session,
    required AppUiConfigCubit appUiConfigCubit,
  }) async {
    calls++;
    this.session = session;
  }
}

// Real Dio status validation and decoding run against an in-memory transport.
// JSON content type produces a Map; text/plain leaves the same JSON as a String.
class _ResponseAdapter implements HttpClientAdapter {
  _ResponseAdapter(this.body, this.status, {required this.asJson});

  final Map<String, dynamic> body;
  final int status;
  final bool asJson;
  DioExceptionType? failureType;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    if (failureType != null) {
      throw DioException(requestOptions: options, type: failureType!);
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [asJson ? 'application/json' : 'text/plain'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  const storageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  late Directory directory;
  late NetworkService network;
  late _MockAuthManager authManager;
  late AppUiConfigCubit config;
  late _Completion completion;
  late LoginBloc bloc;
  var hardLogoutCalls = 0;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('login_error_test_');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      pathChannel,
      (_) async => directory.path,
    );
    messenger.setMockMethodCallHandler(storageChannel, (_) async => null);
    authManager = _MockAuthManager();
    hardLogoutCalls = 0;
    network = NetworkService(
      authManager: authManager,
      onHardLogout: () async {
        hardLogoutCalls++;
      },
    );
    await network.init();
    config = AppUiConfigCubit();
    completion = _Completion();
    bloc = LoginBloc(
      repository: LoginRepository(networkService: network),
      appUiConfigCubit: config,
      authCompletionService: completion,
      internetConnection: _Connected(),
    );
  });

  tearDown(() async {
    await bloc.close();
    await config.close();
    network.dio.close(force: true);
    await directory.delete(recursive: true);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(pathChannel, null);
    messenger.setMockMethodCallHandler(storageChannel, null);
  });

  Matcher failure(String message) => isA<LoginState>()
      .having((s) => s.status, 'status', LoginStatus.failure)
      .having((s) => s.errorMessage, 'exact message', message)
      .having((s) => s.errorToastId, 'toast trigger increment', 8)
      .having((s) => s.outcome, 'outcome', LoginOutcome.none)
      .having((s) => s.phoneFieldError, 'phoneFieldError', false)
      .having((s) => s.passwordFieldError, 'passwordFieldError', false)
      .having((s) => s.mfaToken, 'mfaToken', isNull);

  void verifyLoginRequest(_ResponseAdapter adapter) {
    expect(adapter.request?.uri.toString(), Api.loginUrl);
    expect(adapter.request?.method, 'POST');
    expect(adapter.request?.data, {
      'Username': '2423241234',
      'Password': 'test-password',
      'Channel': kAuthChannel,
    });
    expect(adapter.request?.extra['skipAuth'], true);
    expect(adapter.request?.headers.containsKey('Authorization'), false);
    expect(hardLogoutCalls, 0);
    verifyNever(() => authManager.refreshIfNeeded());
  }

  for (final status in [400, 401]) {
    for (final asJson in [true, false]) {
      final shape = asJson ? 'Map' : 'JSON string';
      late _ResponseAdapter adapter;

      blocTest<LoginBloc, LoginState>(
        'HTTP $status $shape locked response triggers exact toast message',
        build: () {
          adapter = _ResponseAdapter(_lockedBody, status, asJson: asJson);
          network.dio.httpClientAdapter = adapter;
          return bloc;
        },
        seed: () => _seed,
        act: (bloc) async {
          final finished = bloc.stream.firstWhere(
            (state) =>
                state.status == LoginStatus.failure ||
                state.status == LoginStatus.success,
          );
          bloc.add(const LoginSubmitted());
          await finished;
        },
        expect: () => [
          isA<LoginState>().having(
            (s) => s.status,
            'status',
            LoginStatus.loading,
          ),
          failure(_lockedMessage),
        ],
        verify: (_) {
          verifyLoginRequest(adapter);
          expect(completion.calls, 0);
        },
      );

      test(
        'HTTP $status $shape preserves decoded error body and status',
        () async {
          network.dio.httpClientAdapter = _ResponseAdapter(
            _lockedBody,
            status,
            asJson: asJson,
          );
          await expectLater(
            LoginRepository(
              networkService: network,
            ).login(username: '2423241234', password: 'test-password'),
            throwsA(
              isA<NetworkException>()
                  .having((e) => e.statusCode, 'HTTP status', status)
                  .having(
                    (e) => e.message,
                    'backend code',
                    'FailedUsernameIsLocked',
                  )
                  .having(
                    (e) => e.data,
                    'body',
                    asJson ? _lockedBody : jsonEncode(_lockedBody),
                  ),
            ),
          );
        },
      );

      testWidgets('HTTP $status $shape renders exact toast in login view', (
        tester,
      ) async {
        network.dio.httpClientAdapter = _ResponseAdapter(
          _lockedBody,
          status,
          asJson: asJson,
        );
        final biometrics = _MockBiometrics();
        when(
          () => biometrics.state,
        ).thenReturn(const FingerFaceSecurityState());
        addTearDown(biometrics.close);

        instance.registerSingleton<NetworkService>(network);
        instance.registerSingleton<FingerFaceSecurityCubit>(biometrics);
        addTearDown(() async {
          instance.unregister<NetworkService>();
          instance.unregister<FingerFaceSecurityCubit>();
        });
        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider.value(value: config, child: const LoginScreen()),
          ),
        );
        await tester.pump();
        // Reuse the production view with an injected, connected LoginBloc.
        // LoginScreen's public constructor does not expose dependency overrides.
        final view = tester.widget(
          find.byWidgetPredicate(
            (widget) => widget.runtimeType.toString() == '_LoginView',
          ),
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
          MaterialApp(
            navigatorKey: rootNavigatorKey,
            home: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: bloc),
                BlocProvider<FingerFaceSecurityCubit>.value(value: biometrics),
              ],
              child: view,
            ),
          ),
        );
        final fields = find.byType(TextField);
        await tester.enterText(fields.at(0), '2423241234');
        await tester.enterText(fields.at(1), 'test-password');
        tester.testTextInput.hide();
        await tester.pump();
        await tester.ensureVisible(find.text('sign in'));
        final finished = bloc.stream.firstWhere(
          (s) => s.status == LoginStatus.failure,
        );
        await tester.tap(find.text('sign in'));
        await tester.runAsync(() async {
          await finished;
        });
        await tester.pump();
        expect(find.text(_lockedMessage), findsOneWidget);
        expect(bloc.state.errorToastId, 1);
        expect(completion.calls, 0);
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  for (final entry in {
    'FailedUsernameOrPassword': 'Invalid Credentials',
    'FailedSimpleValidation': 'The number you entered is invalid',
    'UnknownBackendError': 'UnknownBackendError',
    'failedusernameislocked': 'failedusernameislocked',
    'FailedUsernameIsLockedExtra': 'FailedUsernameIsLockedExtra',
  }.entries) {
    blocTest<LoginBloc, LoginState>(
      '${entry.key} retains existing behavior',
      build: () {
        network.dio.httpClientAdapter = _ResponseAdapter(
          {'error': entry.key, 'error_description': entry.key},
          400,
          asJson: true,
        );
        return bloc;
      },
      seed: () => _seed,
      act: (bloc) async {
        final finished = bloc.stream.firstWhere(
          (state) =>
              state.status == LoginStatus.failure ||
              state.status == LoginStatus.success,
        );
        bloc.add(const LoginSubmitted());
        await finished;
      },
      expect: () => [
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.loading,
        ),
        failure(entry.value),
      ],
      verify: (_) => expect(completion.calls, 0),
    );
  }

  blocTest<LoginBloc, LoginState>(
    'transport timeout retains Request timeout message',
    build: () {
      network.dio.httpClientAdapter = _ResponseAdapter({}, 200, asJson: true)
        ..failureType = DioExceptionType.receiveTimeout;
      return bloc;
    },
    seed: () => _seed,
    act: (bloc) async {
      final finished = bloc.stream.firstWhere(
        (state) =>
            state.status == LoginStatus.failure ||
            state.status == LoginStatus.success,
      );
      bloc.add(const LoginSubmitted());
      await finished;
    },
    expect: () => [
      isA<LoginState>().having((s) => s.status, 'status', LoginStatus.loading),
      failure('Request timeout'),
    ],
    verify: (_) => expect(completion.calls, 0),
  );

  blocTest<LoginBloc, LoginState>(
    'HTTP 500 retains backend server message',
    build: () {
      network.dio.httpClientAdapter = _ResponseAdapter(
        {'message': 'Service unavailable'},
        500,
        asJson: true,
      );
      return bloc;
    },
    seed: () => _seed,
    act: (bloc) async {
      final finished = bloc.stream.firstWhere(
        (state) =>
            state.status == LoginStatus.failure ||
            state.status == LoginStatus.success,
      );
      bloc.add(const LoginSubmitted());
      await finished;
    },
    expect: () => [
      isA<LoginState>().having((s) => s.status, 'status', LoginStatus.loading),
      failure('Service unavailable'),
    ],
  );

  for (final asJson in [true, false]) {
    blocTest<LoginBloc, LoginState>(
      'HTTP 200 locked ${asJson ? 'Map' : 'JSON string'} is currently a missing-token error',
      build: () {
        network.dio.httpClientAdapter = _ResponseAdapter(
          _lockedBody,
          200,
          asJson: asJson,
        );
        return bloc;
      },
      seed: () => _seed,
      act: (bloc) async {
        final finished = bloc.stream.firstWhere(
          (state) =>
              state.status == LoginStatus.failure ||
              state.status == LoginStatus.success,
        );
        bloc.add(const LoginSubmitted());
        await finished;
      },
      expect: () => [
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.loading,
        ),
        failure(
          'FormatException: Login response missing both access_token and mfa_token',
        ),
      ],
      verify: (_) => expect(completion.calls, 0),
    );
  }

  blocTest<LoginBloc, LoginState>(
    'HTTP 200 token response still completes direct login without error toast',
    build: () {
      network.dio.httpClientAdapter = _ResponseAdapter(
        {
          'access_token': 'test-access',
          'refresh_token': 'test-refresh',
          'expires_in': 3600,
          'refresh_expires_in': 86400,
        },
        200,
        asJson: true,
      );
      return bloc;
    },
    seed: () => _seed,
    act: (bloc) async {
      final finished = bloc.stream.firstWhere(
        (state) =>
            state.status == LoginStatus.failure ||
            state.status == LoginStatus.success,
      );
      bloc.add(const LoginSubmitted());
      await finished;
    },
    expect: () => [
      isA<LoginState>().having((s) => s.status, 'status', LoginStatus.loading),
      isA<LoginState>()
          .having((s) => s.status, 'status', LoginStatus.success)
          .having((s) => s.outcome, 'outcome', LoginOutcome.authenticated)
          .having((s) => s.errorMessage, 'errorMessage', isNull)
          .having((s) => s.errorToastId, 'no error toast', 7),
    ],
    verify: (_) {
      expect(completion.calls, 1);
      expect(completion.session?.accessToken, 'test-access');
    },
  );
}
