import 'dart:async';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/bloc/forget_password_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/bloc/forget_password_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/bloc/forget_password_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/repository/forgetpassword_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/view/forget_password_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/widgets/forget_password_keyboard_done_toolbar.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/forgetPassword/widgets/forgetpass_phone_row.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/model/login_otp_route_args.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/defaultButton.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
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

  testWidgets('empty Send shows FPW-001 inline without a toast or API call', (
    tester,
  ) async {
    await _pumpScreen(tester);

    await tester.tap(find.text('send'));
    await tester.pump();

    final bloc = tester.element(_phoneField()).read<ForgetPasswordBloc>();
    expect(bloc.state.status, ForgetPasswordStatus.failure);
    expect(bloc.state.errorMessage, 'enter your mobile number');
    expect(bloc.state.isEmptyNumberError, isTrue);
    expect(
      find.descendant(
        of: find.byType(CustomScrollView),
        matching: find.text('enter your mobile number'),
      ),
      findsOneWidget,
    );
    expect(find.text('enter your mobile number'), findsOneWidget);
    expect(find.text('Please enter your phone number.'), findsNothing);
    expect(find.byIcon(Icons.close), findsNothing);
    verifyNever(
      () => networkService.request<dynamic>(
        Api.forgotPasswordUrl,
        method: HttpMethod.post,
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    );

    await tester.tap(find.text('send'));
    await tester.pump();
    expect(find.text('enter your mobile number'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsNothing);
    verifyZeroInteractions(networkService);

    await tester.enterText(_phoneField(), '242');
    await tester.pump();
    expect(bloc.state.isEmptyNumberError, isFalse);
    expect(find.text('enter your mobile number'), findsNothing);
  });

  testWidgets('non-empty digitless value retains its original error toast', (
    tester,
  ) async {
    await _pumpScreen(tester);
    final bloc = tester.element(_phoneField()).read<ForgetPasswordBloc>();
    bloc.add(const ForgetPasswordPhoneChanged('abc'));
    await tester.pump();

    await tester.tap(find.text('send'));
    await tester.pump();
    await tester.pump();

    expect(bloc.state.isEmptyNumberError, isFalse);
    expect(bloc.state.errorMessage, 'Please enter your phone number.');
    expect(find.text('Please enter your phone number.'), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('enter your mobile number'), findsNothing);
    verifyZeroInteractions(networkService);
    // Let the existing toast expire before disposing its overlay.
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets(
    'API failure after FPW-001 still shows its existing error toast',
    (tester) async {
      const backendMessage = 'The number you entered is invalid';
      when(
        () => networkService.request<dynamic>(
          Api.forgotPasswordUrl,
          method: HttpMethod.post,
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: Api.forgotPasswordUrl),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: Api.forgotPasswordUrl),
            statusCode: 400,
            data: {'Message': backendMessage},
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      await _pumpScreen(tester);
      await tester.tap(find.text('send'));
      await tester.pump();
      expect(find.text('enter your mobile number'), findsOneWidget);

      await tester.enterText(_phoneField(), '2425550101');
      await tester.tap(find.text('send'));
      await tester.pump();
      await tester.pump();

      final bloc = tester.element(_phoneField()).read<ForgetPasswordBloc>();
      expect(bloc.state.status, ForgetPasswordStatus.failure);
      expect(bloc.state.isEmptyNumberError, isFalse);
      expect(bloc.state.errorMessage, backendMessage);
      expect(find.text(backendMessage), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('enter your mobile number'), findsNothing);
      verify(
        () => networkService.request<dynamic>(
          Api.forgotPasswordUrl,
          method: HttpMethod.post,
          data: {'Username': '2425550101', 'Channel': 'SelfCare'},
          options: any(named: 'options'),
        ),
      ).called(1);
      await tester.pump(const Duration(seconds: 3));
    },
  );

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

  test(
    'an in-flight API failure cannot inherit the FPW-001 inline flag',
    () async {
      final repository = _MockForgetPasswordRepository();
      final pendingResponse = Completer<String>();
      when(
        () => repository.sendRequest(apiPhone: '2425550101'),
      ).thenAnswer((_) => pendingResponse.future);
      final bloc = ForgetPasswordBloc(repository: repository);
      addTearDown(bloc.close);

      bloc.add(const ForgetPasswordPhoneChanged('2425550101'));
      await bloc.stream.firstWhere((state) => state.phone == '2425550101');
      bloc.add(const ForgetPasswordSubmitted());
      await bloc.stream.firstWhere(
        (state) => state.status == ForgetPasswordStatus.loading,
      );

      bloc.add(const ForgetPasswordPhoneChanged(''));
      await bloc.stream.firstWhere((state) => state.phone.isEmpty);
      bloc.add(const ForgetPasswordSubmitted());
      await bloc.stream.firstWhere((state) => state.isEmptyNumberError);

      pendingResponse.completeError(Exception('Existing API failure'));
      final failure = await bloc.stream.firstWhere(
        (state) => state.errorMessage == 'Existing API failure',
      );
      expect(failure.status, ForgetPasswordStatus.failure);
      expect(failure.isEmptyNumberError, isFalse);
      verify(() => repository.sendRequest(apiPhone: '2425550101')).called(1);
    },
  );
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
    navigatorKey: rootNavigatorKey,
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
