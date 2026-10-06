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
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/login_keyboard_next_toolbar.dart';
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

  testWidgets('phone native action focuses password', (tester) async {
    await _pumpHarness(tester, bloc);

    final phoneField = _fieldWithHint('eg: (242)-899-9999');
    final passwordField = _fieldWithHint('enter your password');

    expect(
      tester.widget<TextField>(phoneField).textInputAction,
      TextInputAction.unspecified,
    );
    expect(
      tester.widget<TextField>(passwordField).textInputAction,
      TextInputAction.done,
    );

    await tester.showKeyboard(phoneField);
    await tester.testTextInput.receiveAction(TextInputAction.unspecified);
    await tester.pump();

    expect(tester.widget<TextField>(phoneField).focusNode!.hasFocus, isFalse);
    expect(tester.widget<TextField>(passwordField).focusNode!.hasFocus, isTrue);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('$platform phone toolbar Next focuses password only', (
      tester,
    ) async {
      addTearDown(tester.view.resetViewInsets);

      final mockBloc = _MockLoginBloc();
      whenListen(
        mockBloc,
        const Stream<LoginState>.empty(),
        initialState: const LoginState(),
      );
      addTearDown(mockBloc.close);
      await _pumpHarness(tester, mockBloc, platform: platform);

      final phoneField = _fieldWithHint('eg: (242)-899-9999');
      final passwordField = _fieldWithHint('enter your password');
      expect(find.text('Next'), findsNothing);
      expect(
        tester.widget<TextField>(phoneField).textInputAction,
        TextInputAction.unspecified,
      );

      await tester.enterText(phoneField, '2425550101');
      final phoneValue = tester.widget<TextField>(phoneField).controller!.text;
      await tester.showKeyboard(phoneField);
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      await tester.pump();

      expect(find.text('Next'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('Next'),
          matching: find.byType(ExcludeFocus),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(tester.widget<TextField>(phoneField).focusNode!.hasFocus, isFalse);
      expect(
        tester.widget<TextField>(passwordField).focusNode!.hasFocus,
        isTrue,
      );
      expect(tester.widget<TextField>(phoneField).controller!.text, phoneValue);
      expect(find.text('Next'), findsNothing);
      verifyNever(() => mockBloc.add(const LoginSubmitted()));
    });
  }

  testWidgets('phone toolbar hides when software keyboard closes', (
    tester,
  ) async {
    await _pumpHarness(tester, bloc);

    final phoneField = _fieldWithHint('eg: (242)-899-9999');
    await tester.showKeyboard(phoneField);
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();

    expect(find.text('Next'), findsOneWidget);
    tester.view.resetViewInsets();
    await tester.pump();

    expect(tester.widget<TextField>(phoneField).focusNode!.hasFocus, isTrue);
    expect(find.text('Next'), findsNothing);
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

    expect(
      tester.widget<TextField>(passwordField).focusNode!.hasFocus,
      isFalse,
    );
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

  testWidgets('Login fields do not dispose parent-owned FocusNodes', (
    tester,
  ) async {
    final phoneFocusNode = FocusNode();
    final passwordFocusNode = FocusNode();
    addTearDown(phoneFocusNode.dispose);
    addTearDown(passwordFocusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LoginBloc>.value(
          value: bloc,
          child: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  LoginPhoneRow(
                    focusNode: phoneFocusNode,
                    onNext: passwordFocusNode.requestFocus,
                  ),
                  LoginPasswordField(
                    focusNode: passwordFocusNode,
                    onSubmitted: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    void listener() {}
    expect(() => phoneFocusNode.addListener(listener), returnsNormally);
    expect(() => passwordFocusNode.addListener(listener), returnsNormally);
    phoneFocusNode.removeListener(listener);
    passwordFocusNode.removeListener(listener);
  });
}

Finder _fieldWithHint(String hint) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.hintText == hint,
  );
}

Future<void> _pumpHarness(
  WidgetTester tester,
  LoginBloc bloc, {
  TargetPlatform? platform,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: platform == null ? null : ThemeData(platform: platform),
      home: BlocProvider<LoginBloc>.value(
        value: bloc,
        child: const _SignInKeyboardHarness(),
      ),
    ),
  );
  await tester.pump();
}

class _SignInKeyboardHarness extends StatefulWidget {
  const _SignInKeyboardHarness();

  @override
  State<_SignInKeyboardHarness> createState() => _SignInKeyboardHarnessState();
}

class _SignInKeyboardHarnessState extends State<_SignInKeyboardHarness> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void submitLogin() {
      context.read<LoginBloc>().add(const LoginSubmitted());
    }

    return LoginKeyboardNextToolbar(
      phoneFocusNode: _phoneFocusNode,
      onNext: _passwordFocusNode.requestFocus,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              LoginPhoneRow(
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                onNext: _passwordFocusNode.requestFocus,
              ),
              LoginPasswordField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                onSubmitted: submitLogin,
              ),
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
      ),
    );
  }
}
