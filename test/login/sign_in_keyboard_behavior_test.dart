import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/bloc/auth_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/bloc/auth_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/bloc/auth_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/repository/auth_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/services/auth_completion_service.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/login_password_field.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/login_phone_row.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';

class _MockLoginRepository extends Mock implements LoginRepository {}

class _MockLoginBloc extends MockBloc<LoginEvent, LoginState>
    implements LoginBloc {}

class _FakeAuthCompletionService extends Fake implements AuthCompletionService {
  @override
  Future<void> complete({
    required TokenSession session,
    required AppUiConfigCubit appUiConfigCubit,
  }) async {}
}

class _FakeInternetConnection extends Fake implements InternetConnection {
  @override
  Future<bool> get hasInternetAccess async => true;
}

void main() {
  late _MockLoginRepository repository;
  late AppUiConfigCubit appUiConfigCubit;
  late LoginBloc bloc;

  setUp(() {
    repository = _MockLoginRepository();
    appUiConfigCubit = AppUiConfigCubit();
    bloc = LoginBloc(
      repository: repository,
      appUiConfigCubit: appUiConfigCubit,
      authCompletionService: _FakeAuthCompletionService(),
      internetConnection: _FakeInternetConnection(),
    );
  });

  tearDown(() async {
    await bloc.close();
    await appUiConfigCubit.close();
  });

  testWidgets('phone Next focuses password', (tester) async {
    await _pumpHarness(tester, bloc);

    final phoneField = _fieldWithHint('eg: (242)-899-9999');
    final passwordField = _fieldWithHint('enter your password');

    expect(
      tester.widget<TextField>(phoneField).textInputAction,
      TextInputAction.next,
    );
    expect(
      tester.widget<TextField>(passwordField).textInputAction,
      TextInputAction.done,
    );

    await tester.showKeyboard(phoneField);
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    expect(tester.widget<TextField>(phoneField).focusNode!.hasFocus, isFalse);
    expect(tester.widget<TextField>(passwordField).focusNode!.hasFocus, isTrue);
  });

  testWidgets('password Done triggers the existing LoginSubmitted flow', (
    tester,
  ) async {
    final mockBloc = _MockLoginBloc();
    const initialState = LoginState();
    whenListen(
      mockBloc,
      const Stream<LoginState>.empty(),
      initialState: initialState,
    );
    addTearDown(mockBloc.close);
    await _pumpHarness(tester, mockBloc);

    final passwordField = _fieldWithHint('enter your password');
    await tester.showKeyboard(passwordField);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    verify(() => mockBloc.add(const LoginSubmitted())).called(1);
  });

  testWidgets('invalid input through Done uses existing validation errors', (
    tester,
  ) async {
    await _pumpHarness(tester, bloc);

    final passwordField = _fieldWithHint('enter your password');
    await tester.showKeyboard(passwordField);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(bloc.state.status, LoginStatus.failure);
    expect(bloc.state.errorMessage, 'enter phone number and password');
    expect(bloc.state.phoneFieldError, isTrue);
    expect(bloc.state.passwordFieldError, isTrue);
    verifyNever(
      () => repository.login(
        username: any(named: 'username'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('Done is ignored while LoginStatus is loading', (tester) async {
    final mockBloc = _MockLoginBloc();
    const loadingState = LoginState(status: LoginStatus.loading);
    whenListen(
      mockBloc,
      const Stream<LoginState>.empty(),
      initialState: loadingState,
    );
    addTearDown(mockBloc.close);
    await _pumpHarness(tester, mockBloc);

    final passwordField = _fieldWithHint('enter your password');
    await tester.showKeyboard(passwordField);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    verifyNever(() => mockBloc.add(const LoginSubmitted()));
  });
}

Finder _fieldWithHint(String hint) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.hintText == hint,
  );
}

Future<void> _pumpHarness(WidgetTester tester, LoginBloc bloc) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<LoginBloc>.value(
        value: bloc,
        child: const _SignInKeyboardHarness(),
      ),
    ),
  );
  await tester.pump();
}

class _SignInKeyboardHarness extends StatelessWidget {
  const _SignInKeyboardHarness();

  @override
  Widget build(BuildContext context) {
    void submitLogin() {
      context.read<LoginBloc>().add(const LoginSubmitted());
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const LoginPhoneRow(),
            LoginPasswordField(onSubmitted: submitLogin),
            BlocBuilder<LoginBloc, LoginState>(
              builder: (context, state) {
                return DefaultButton(
                  label: 'sign in',
                  isLoading: state.status == LoginStatus.loading,
                  onPressed: submitLogin,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
