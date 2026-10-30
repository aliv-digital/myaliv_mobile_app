import 'dart:async';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/createPassword/view/create_password_page.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/createPassword/widgets/password_input.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/theme/login_theme.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class _Network extends Mock implements NetworkService {}

void main() {
  const minimum = 'Password must be 8 characters long';
  const maximum = 'Password must be 64 characters or fewer.';
  const mismatch = 'Passwords do not match.';
  const channel = MethodChannel('PonnamKarthik/fluttertoast');
  late _Network network;
  late List<MethodCall> legacyToasts;
  GoRouter? router;

  Finder field(int index) => find.byType(TextField).at(index);
  Finder inline(String message) => find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.data == message &&
        widget.style == AuthModuleTextStyles.invalidCredentials,
  );
  Finder toast(String message) => find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.data == message &&
        widget.style?.color == Colors.white,
  );

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() async {
    await instance.reset();
    network = _Network();
    instance.registerSingleton<NetworkService>(network);
    legacyToasts = [];
    router = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          legacyToasts.add(call);
          return true;
        });
  });

  tearDown(() async {
    router?.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await instance.reset();
  });

  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    double scale = 1,
    bool recoveryBack = true,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    router = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.createPassword,
      routes: [
        GoRoute(
          path: AppRoutes.createPassword,
          builder: (_, _) =>
              CreatePasswordScreen(onBack: recoveryBack ? () {} : null),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const Scaffold(body: Text('home destination')),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router!,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, int index, String text) async {
    await tester.enterText(field(index), text);
    await tester.pumpAndSettle();
  }

  Future<void> submit(WidgetTester tester) async {
    tester.testTextInput.hide();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('continue'));
    await tester.tap(find.text('continue'));
    await tester.pump();
    await tester.pump();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpWidget(const SizedBox.shrink());
  }

  for (final width in [320.0, 430.0]) {
    for (final password in ['', 'Abc12345']) {
      testWidgets(
        'empty reset fields show conditional messages after Continue at $width, password length ${password.length}',
        (tester) async {
          const emptyPassword = 'password must be 8 characters long';
          const emptyConfirmation = 'please re-enter your password.';
          await open(tester, size: Size(width, 844));
          if (password.isNotEmpty) {
            await enter(tester, 0, password);
          }
          expect(inline(emptyPassword), findsNothing);
          expect(inline(emptyConfirmation), findsNothing);
          await submit(tester);
          expect(
            inline(emptyPassword),
            password.isEmpty ? findsOneWidget : findsNothing,
          );
          expect(inline(emptyConfirmation), findsOneWidget);
          expect(inline(mismatch), findsNothing);
          expect(
            toast(password.isEmpty ? emptyPassword : emptyConfirmation),
            findsOneWidget,
          );
          expect(
            tester.getTopLeft(inline(emptyConfirmation)).dy,
            greaterThan(tester.getBottomLeft(field(1)).dy),
          );
          expect(find.text('home destination'), findsNothing);
          verifyZeroInteractions(network);
          await enter(tester, 0, 'Abc12345');
          await enter(tester, 1, 'Abc12345');
          expect(inline(emptyPassword), findsNothing);
          expect(inline(emptyConfirmation), findsNothing);
          expect(tester.takeException(), isNull);
          await finish(tester);
        },
      );
    }
  }

  testWidgets(
    'minimum error is live, red, below the first input and clears at eight',
    (tester) async {
      await open(tester);
      expect(inline(minimum), findsNothing);
      expect(inline(mismatch), findsNothing);
      await enter(tester, 0, 'Abc123');
      expect(inline(minimum), findsOneWidget);
      expect(
        tester.getTopLeft(inline(minimum)).dy,
        greaterThan(tester.getBottomLeft(field(0)).dy),
      );
      expect(inline(mismatch), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
      await enter(tester, 0, 'Abc12345');
      expect(inline(minimum), findsNothing);
      expect(inline(maximum), findsNothing);
      expect(legacyToasts, isEmpty);
      verifyZeroInteractions(network);
      await finish(tester);
    },
  );

  testWidgets(
    'maximum length is retained and its live error clears at sixty-four',
    (tester) async {
      await open(tester);
      await enter(tester, 0, 'a' * 65);
      expect(inline(maximum), findsOneWidget);
      expect(inline(minimum), findsNothing);
      await enter(tester, 0, 'a' * 64);
      expect(inline(maximum), findsNothing);
      verifyZeroInteractions(network);
      await finish(tester);
    },
  );

  testWidgets(
    'confirmation revalidates immediately on either field after interaction',
    (tester) async {
      await open(tester);
      await enter(tester, 0, 'Abc12345');
      expect(inline(mismatch), findsNothing);
      await enter(tester, 1, 'Abc1234');
      expect(inline(mismatch), findsOneWidget);
      expect(
        tester.getTopLeft(inline(mismatch)).dy,
        greaterThan(tester.getBottomLeft(field(1)).dy),
      );
      await enter(tester, 1, 'Abc12345');
      expect(inline(mismatch), findsNothing);
      await enter(tester, 0, 'Abc123456');
      expect(inline(mismatch), findsOneWidget);
      await enter(tester, 0, 'Abc12345');
      expect(inline(mismatch), findsNothing);
      await enter(tester, 1, '');
      expect(inline(mismatch), findsOneWidget);
      expect(legacyToasts, isEmpty);
      verifyZeroInteractions(network);
      await finish(tester);
    },
  );

  testWidgets(
    'live errors preserve focus nodes, typed values and visibility controls',
    (tester) async {
      await open(tester);
      final firstFocus = tester.widget<TextField>(field(0)).focusNode;
      final confirmFocus = tester.widget<TextField>(field(1)).focusNode;
      await enter(tester, 0, 'short');
      await enter(tester, 1, 'other');
      expect(tester.widget<TextField>(field(0)).focusNode, same(firstFocus));
      expect(tester.widget<TextField>(field(1)).focusNode, same(confirmFocus));
      expect(confirmFocus!.hasFocus, isTrue);
      await tester.tap(find.byIcon(Icons.visibility_off_outlined).at(1));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(field(1)).obscureText, isFalse);
      expect(confirmFocus.hasFocus, isTrue);
      expect(inline(minimum), findsOneWidget);
      expect(inline(mismatch), findsOneWidget);
      final inputs = tester
          .widgetList<PasswordInput>(find.byType(PasswordInput))
          .toList();
      expect(inputs[0].obscureText, isTrue);
      expect(inputs[1].obscureText, isFalse);
      final editable = tester
          .widgetList<EditableText>(find.byType(EditableText))
          .toList();
      expect(editable[0].controller.text, 'short');
      expect(editable[1].controller.text, 'other');
      await finish(tester);
    },
  );

  for (final scenario in [
    (password: 'short', confirm: 'different', message: minimum),
    (password: 'a' * 65, confirm: 'different', message: maximum),
    (password: 'Abc12345', confirm: 'different', message: mismatch),
  ]) {
    testWidgets(
      'invalid Continue uses one universal error toast: ${scenario.message}',
      (tester) async {
        await open(tester);
        await enter(tester, 0, scenario.password);
        await enter(tester, 1, scenario.confirm);
        for (var i = 0; i < 2; i++) {
          await submit(tester);
          expect(toast(scenario.message), findsOneWidget);
          expect(find.byIcon(Icons.close), findsOneWidget);
          expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is Container &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration! as BoxDecoration).color ==
                      const Color(0xFFE54848),
            ),
            findsOneWidget,
          );
          expect(legacyToasts, isEmpty);
          expect(find.text('home destination'), findsNothing);
          verifyZeroInteractions(network);
        }
        await finish(tester);
      },
    );
  }

  for (final recoveryBack in [true, false]) {
    testWidgets(
      'matching password preserves API, loading, success toast and navigation with recoveryBack=$recoveryBack',
      (tester) async {
        final pending = Completer<Response<dynamic>>();
        when(
          () => network.request<dynamic>(
            Api.updatePasswordUrl,
            method: HttpMethod.post,
            data: any(named: 'data'),
          ),
        ).thenAnswer((_) => pending.future);
        await open(tester, recoveryBack: recoveryBack);
        await enter(tester, 0, '  Abc12345  ');
        await enter(tester, 1, 'Abc12345');
        expect(inline(minimum), findsNothing);
        expect(inline(mismatch), findsNothing);
        await submit(tester);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Password reset successful!'), findsNothing);
        expect(find.text('home destination'), findsNothing);
        verify(
          () => network.request<dynamic>(
            Api.updatePasswordUrl,
            method: HttpMethod.post,
            data: {'CurrentPassword': null, 'NewPassword': 'Abc12345'},
          ),
        ).called(1);
        pending.complete(
          Response<dynamic>(
            requestOptions: RequestOptions(path: Api.updatePasswordUrl),
            data: {'Success': true},
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Password reset successful!'), findsOneWidget);
        expect(find.text('home destination'), findsOneWidget);
        expect(legacyToasts, isEmpty);
        expect(tester.takeException(), isNull);
        await finish(tester);
      },
    );
  }

  for (final layout in [
    (size: const Size(320, 568), scale: 1.0),
    (size: const Size(390, 844), scale: 1.0),
    (size: const Size(430, 932), scale: 1.6),
  ]) {
    testWidgets(
      'both inline errors fit and remain scrollable at ${layout.size}, text scale ${layout.scale}',
      (tester) async {
        await open(tester, size: layout.size, scale: layout.scale);
        await enter(tester, 0, 'short');
        await enter(tester, 1, 'other');
        expect(inline(minimum), findsOneWidget);
        expect(inline(mismatch), findsOneWidget);
        for (final keyboardHeight in [240.0, 0.0]) {
          tester.view.viewInsets = FakeViewPadding(bottom: keyboardHeight);
          await tester.pumpAndSettle();
          await tester.ensureVisible(inline(mismatch));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        await tester.ensureVisible(find.text('continue'));
        await tester.pumpAndSettle();
        expect(find.text('continue').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        verifyZeroInteractions(network);
        await finish(tester);
      },
    );
  }
}
