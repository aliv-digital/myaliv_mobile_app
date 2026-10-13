import 'dart:async';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/createPassword/view/create_password_page.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Network extends Mock implements NetworkService {}

void main() {
  const toastChannel = MethodChannel('PonnamKarthik/fluttertoast');
  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  for (final outcome in [
    'success',
    'backend failure',
    'network failure',
    'mismatch',
    'short password'
  ]) {
    testWidgets(
        'reset password $outcome preserves backend timing and navigation',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 1100));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final network = _Network();
      final result = Completer<Response<dynamic>>();
      final validationMessages = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(toastChannel, (call) async {
        validationMessages.add((call.arguments as Map)['msg'] as String);
        return true;
      });
      when(() => network.request<dynamic>(
            Api.updatePasswordUrl,
            method: HttpMethod.post,
            data: any(named: 'data'),
          )).thenAnswer((_) => result.future);
      instance.registerSingleton<NetworkService>(network);
      final router = GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: AppRoutes.createPassword,
        routes: [
          GoRoute(
              path: AppRoutes.createPassword,
              builder: (_, _) => const CreatePasswordScreen()),
          GoRoute(
              path: AppRoutes.home,
              builder: (_, _) =>
                  const Scaffold(body: Text('home destination'))),
        ],
      );
      addTearDown(() async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(toastChannel, null);
        router.dispose();
        await instance.reset();
      });
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      try {
        await tester.enterText(find.byType(TextField).first,
            outcome == 'short password' ? 'short' : 'password1');
        await tester.enterText(
            find.byType(TextField).last,
            outcome == 'short password'
                ? 'short'
                : outcome == 'mismatch'
                    ? 'password2'
                    : 'password1');
        await tester.pumpAndSettle();
        expect(find.text('Password reset successful!'), findsNothing);
        verifyZeroInteractions(network);
        tester.testTextInput.hide();
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('continue'));
        await tester.tap(find.text('continue'));
        await tester.pump();
        expect(find.text('Password reset successful!'), findsNothing);
        expect(find.text('home destination'), findsNothing);
        if (outcome == 'mismatch' || outcome == 'short password') {
          expect(validationMessages, [
            outcome == 'mismatch'
                ? 'Passwords do not match.'
                : 'Password must be at least 8 characters.'
          ]);
          verifyZeroInteractions(network);
          expect(find.byType(CreatePasswordScreen), findsOneWidget);
          return;
        }
        verify(() => network.request<dynamic>(
              Api.updatePasswordUrl,
              method: HttpMethod.post,
              data: {'CurrentPassword': null, 'NewPassword': 'password1'},
            )).called(1);
        // The existing submitting guard also protects the keyboard Done action.
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();
        verifyNoMoreInteractions(network);
        if (outcome == 'network failure') {
          result.completeError(Exception('network unavailable'));
        } else {
          result.complete(Response<dynamic>(
            requestOptions: RequestOptions(path: Api.updatePasswordUrl),
            data: outcome == 'success'
                ? {'Success': true}
                : {'Success': false, 'Message': 'reset rejected'},
          ));
        }
        await tester.pumpAndSettle();
        if (outcome == 'success') {
          expect(find.text('Password reset successful!'), findsOneWidget);
          expect(find.text('home destination'), findsOneWidget);
          expect(find.text('Password updated successfully.'), findsNothing);
        } else {
          expect(find.text('Password reset successful!'), findsNothing);
          expect(find.text('home destination'), findsNothing);
          expect(
              find.text(outcome == 'backend failure'
                  ? 'reset rejected'
                  : 'network unavailable'),
              findsOneWidget);
          expect(find.byType(CreatePasswordScreen), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });
  }
}
