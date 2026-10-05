import 'dart:async';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/bloc/forget_password_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/bloc/forget_password_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/repository/forgetpassword_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/view/forget_password_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/widgets/forget_password_keyboard_done_toolbar.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/widgets/forgetpass_phone_row.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_route_args.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _MockNetworkService extends Mock implements NetworkService {}

class _MockForgetPasswordRepository extends Mock
    implements ForgetPasswordRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockNetworkService networkService;

  setUp(() async {
    await instance.reset();
    networkService = _MockNetworkService();
    instance.registerSingleton<NetworkService>(networkService);
  });

  tearDown(() async {
    await instance.reset();
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('$platform Done appears with phone focus and only dismisses', (
      tester,
    ) async {
      addTearDown(tester.view.resetViewInsets);
      await _pumpScreen(tester, platform: platform);

      final phoneField = _phoneField();
      final textField = tester.widget<TextField>(phoneField);
      expect(textField.keyboardType, TextInputType.phone);
      expect(textField.textInputAction, isNull);
      expect(find.text('Done'), findsNothing);

      await tester.enterText(phoneField, '2425550101');
      final formattedPhone = _phoneText(tester);
      final bloc = tester.element(phoneField).read<ForgetPasswordBloc>();
      expect(bloc.state.phone, formattedPhone);

      await tester.showKeyboard(phoneField);
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      await tester.pump();

      expect(find.text('Done'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('Done'),
          matching: find.byType(ExcludeFocus),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Done'));
      await tester.pump();

      expect(tester.widget<TextField>(phoneField).focusNode!.hasFocus, isFalse);
      expect(find.text('Done'), findsNothing);
      expect(_phoneText(tester), formattedPhone);
      expect(bloc.state.phone, formattedPhone);
      verifyNever(
        () => networkService.request<dynamic>(
          Api.forgotPasswordUrl,
          method: HttpMethod.post,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      );
    });
  }

  testWidgets('toolbar hides when phone loses focus', (tester) async {
    addTearDown(tester.view.resetViewInsets);
    await _pumpScreen(tester);

    final phoneField = _phoneField();
    await tester.showKeyboard(phoneField);
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    await tester.pump();
    expect(find.text('Done'), findsOneWidget);

    tester.widget<TextField>(phoneField).focusNode!.unfocus();
    await tester.pump();
    expect(find.text('Done'), findsNothing);
  });

  testWidgets('toolbar hides when software keyboard closes', (tester) async {
    addTearDown(tester.view.resetViewInsets);
    await _pumpScreen(tester);

    final phoneField = _phoneField();
    await tester.showKeyboard(phoneField);
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    await tester.pump();
    expect(find.text('Done'), findsOneWidget);

    tester.view.resetViewInsets();
    await tester.pump();
    expect(tester.widget<TextField>(phoneField).focusNode!.hasFocus, isTrue);
    expect(find.text('Done'), findsNothing);
  });

  testWidgets('Send retains its API request and loading disable', (
    tester,
  ) async {
    final pendingResponse = Completer<Response<dynamic>>();
    when(
      () => networkService.request<dynamic>(
        Api.forgotPasswordUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) => pendingResponse.future);
    await _pumpScreen(tester);

    await tester.enterText(_phoneField(), '2425550101');
    await tester.tap(find.text('send'));
    await tester.pump();

    final bloc = tester.element(_phoneField()).read<ForgetPasswordBloc>();
    expect(bloc.state.status, ForgetPasswordStatus.loading);
    expect(
      tester.widget<DefaultButton>(find.byType(DefaultButton)).isLoading,
      isTrue,
    );
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNull,
    );
    verify(
      () => networkService.request<dynamic>(
        Api.forgotPasswordUrl,
        method: HttpMethod.post,
        data: {'Username': '2425550101', 'Channel': 'SelfCare'},
        options: any(named: 'options'),
      ),
    ).called(1);

    pendingResponse.complete(
      Response<dynamic>(
        requestOptions: RequestOptions(path: Api.forgotPasswordUrl),
        data: {'mfa_token': 'test-mfa-token'},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('OTP placeholder'), findsOneWidget);
  });

  testWidgets('empty Send retains existing validation without an API call', (
    tester,
  ) async {
    await _pumpScreen(tester);

    await tester.tap(find.text('send'));
    await tester.pump();

    final bloc = tester.element(_phoneField()).read<ForgetPasswordBloc>();
    expect(bloc.state.status, ForgetPasswordStatus.failure);
    expect(bloc.state.errorMessage, 'Please enter your phone number.');
    verifyNever(
      () => networkService.request<dynamic>(
        Api.forgotPasswordUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    );
  });

  testWidgets('phone row and toolbar do not dispose the parent FocusNode', (
    tester,
  ) async {
    final phoneFocusNode = FocusNode();
    addTearDown(phoneFocusNode.dispose);
    final bloc = ForgetPasswordBloc(
      repository: _MockForgetPasswordRepository(),
    );
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ForgetPasswordBloc>.value(
          value: bloc,
          child: Scaffold(
            body: ForgetPasswordKeyboardDoneToolbar(
              phoneFocusNode: phoneFocusNode,
              child: ForgetPasswordPhoneRow(focusNode: phoneFocusNode),
            ),
          ),
        ),
      ),
    );
    expect(
      tester.widget<TextField>(_phoneField()).focusNode,
      same(phoneFocusNode),
    );
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    void listener() {}
    expect(() => phoneFocusNode.addListener(listener), returnsNormally);
    phoneFocusNode.removeListener(listener);
  });
}

Finder _phoneField() => find.byWidgetPredicate(
  (widget) =>
      widget is TextField &&
      widget.decoration?.hintText == 'eg: (242)-899-9999',
);

String _phoneText(WidgetTester tester) => tester
    .widget<EditableText>(
      find.descendant(of: _phoneField(), matching: find.byType(EditableText)),
    )
    .controller
    .text;

Future<void> _pumpScreen(
  WidgetTester tester, {
  TargetPlatform? platform,
}) async {
  final router = GoRouter(
    initialLocation: AppRoutes.forgetPassword,
    routes: [
      GoRoute(
        path: AppRoutes.forgetPassword,
        builder: (context, state) => const ForgetPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgetPasswordOtp,
        builder: (context, state) {
          expect(state.extra, isA<LoginOtpRouteArgs>());
          return const Scaffold(body: Text('OTP placeholder'));
        },
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(
      theme: platform == null ? null : ThemeData(platform: platform),
      routerConfig: router,
    ),
  );
  await tester.pump();
}
