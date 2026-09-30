import 'dart:async';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/createPassword/bloc/create_password_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/createPassword/bloc/create_password_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/createPassword/view/create_password_page.dart';

class _MockNetworkService extends Mock implements NetworkService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
  late _MockNetworkService networkService;
  late List<MethodCall> toastCalls;

  setUp(() async {
    await instance.reset();
    networkService = _MockNetworkService();
    instance.registerSingleton<NetworkService>(networkService);
    toastCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, (call) async {
          toastCalls.add(call);
          return true;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(toastChannel, null);
    await instance.reset();
  });

  testWidgets('first-field Next transfers focus to second field', (
    tester,
  ) async {
    await _pumpCreatePasswordScreen(tester);

    final firstField = find.byType(TextField).at(0);
    final secondField = find.byType(TextField).at(1);

    expect(
      tester.widget<TextField>(firstField).textInputAction,
      TextInputAction.next,
    );
    await tester.showKeyboard(firstField);
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();

    expect(tester.widget<TextField>(firstField).focusNode!.hasFocus, isFalse);
    expect(tester.widget<TextField>(secondField).focusNode!.hasFocus, isTrue);
  });

  testWidgets('second-field Done triggers the existing submit flow', (
    tester,
  ) async {
    when(
      () => networkService.request<dynamic>(
        any(),
        method: HttpMethod.post,
        data: any(named: 'data'),
      ),
    ).thenThrow(Exception('expected test failure'));
    await _pumpCreatePasswordScreen(tester);
    await _enterMatchingPasswords(tester);

    final secondField = find.byType(TextField).at(1);
    expect(
      tester.widget<TextField>(secondField).textInputAction,
      TextInputAction.done,
    );
    await tester.showKeyboard(secondField);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    verify(
      () => networkService.request<dynamic>(
        any(),
        method: HttpMethod.post,
        data: {'CurrentPassword': null, 'NewPassword': 'password1'},
      ),
    ).called(1);
  });

  testWidgets('invalid input through Done follows existing validation path', (
    tester,
  ) async {
    await _pumpCreatePasswordScreen(tester);
    final secondField = find.byType(TextField).at(1);

    await tester.enterText(find.byType(TextField).at(0), 'short');
    await tester.enterText(secondField, 'short');
    await tester.showKeyboard(secondField);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(toastCalls, hasLength(1));
    expect(toastCalls.single.method, 'showToast');
    expect(
      (toastCalls.single.arguments as Map<Object?, Object?>)['msg'],
      'Password must be at least 8 characters.',
    );
    verifyNever(
      () => networkService.request<dynamic>(
        any(),
        method: HttpMethod.post,
        data: any(named: 'data'),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Done does not submit again while already submitting', (
    tester,
  ) async {
    final pendingRequest = Completer<Response<dynamic>>();
    when(
      () => networkService.request<dynamic>(
        any(),
        method: HttpMethod.post,
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) => pendingRequest.future);
    await _pumpCreatePasswordScreen(tester);
    await _enterMatchingPasswords(tester);

    final secondField = find.byType(TextField).at(1);
    await tester.showKeyboard(secondField);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    final bloc = tester
        .element(find.byType(CustomScrollView))
        .read<CreatePasswordBloc>();
    expect(bloc.state.status, CreatePasswordStatus.submitting);

    await tester.showKeyboard(secondField);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    verify(
      () => networkService.request<dynamic>(
        any(),
        method: HttpMethod.post,
        data: any(named: 'data'),
      ),
    ).called(1);

    pendingRequest.completeError(Exception('expected test failure'));
    await tester.pump();
  });
}

Future<void> _pumpCreatePasswordScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: CreatePasswordScreen()));
  await tester.pump();
}

Future<void> _enterMatchingPasswords(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(0), 'password1');
  await tester.enterText(find.byType(TextField).at(1), 'password1');
  await tester.pump();
}
