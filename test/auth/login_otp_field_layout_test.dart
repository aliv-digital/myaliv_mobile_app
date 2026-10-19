import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/bloc/login_otp_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/theme/login_otp_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/view/login_otp_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/loginOtp/widgets/otp_code_fields.dart';

class _OtpBloc extends MockBloc<LoginOtpEvent, LoginOtpState>
    implements LoginOtpBloc {}

Finder cells() => find.descendant(
  of: find.byType(OtpCodeFields),
  matching: find.byWidgetPredicate(
    (widget) => widget is Container && widget.decoration is BoxDecoration,
  ),
);

List<Rect> cellRects(WidgetTester tester) =>
    List.generate(6, (index) => tester.getRect(cells().at(index)));

void main() {
  late _OtpBloc bloc;
  late StreamController<LoginOtpState> states;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
  });

  setUp(() {
    bloc = _OtpBloc();
    states = StreamController<LoginOtpState>.broadcast();
    whenListen(bloc, states.stream, initialState: const LoginOtpState());
  });

  tearDown(() async {
    await states.close();
    await bloc.close();
  });

  Future<void> open(
    WidgetTester tester, {
    double width = 390,
    bool useDefaultFields = false,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final provider =
                const LoginOtpScreen().build(context)
                    as BlocProvider<LoginOtpBloc>;
            return BlocProvider<LoginOtpBloc>.value(
              value: bloc,
              child: useDefaultFields
                  ? const Scaffold(
                      body: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 41),
                        child: OtpCodeFields(),
                      ),
                    )
                  : provider.child!,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final width in [320.0, 360.0, 390.0, 430.0]) {
    testWidgets('login OTP cells are 50 high with 10 gaps at $width', (
      tester,
    ) async {
      await open(tester, width: width);
      final rects = cellRects(tester);
      expect(cells(), findsNWidgets(6));
      for (var index = 0; index < rects.length; index++) {
        expect(rects[index].height, 50);
        expect(rects[index].width, closeTo((width - 82 - 50) / 6, 0.001));
        if (index > 0) {
          expect(
            rects[index].left - rects[index - 1].right,
            closeTo(10, 0.001),
          );
        }
      }
      expect(rects.first.left, 41);
      expect(rects.last.right, closeTo(width - 41, 0.001));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('other OTP consumers keep their default square fields', (
    tester,
  ) async {
    await open(tester, useDefaultFields: true);
    for (final rect in cellRects(tester)) {
      expect(rect.width, closeTo(44, 0.001));
      expect(rect.height, closeTo(44, 0.001));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('focus and error keep the same cell height and spacing', (
    tester,
  ) async {
    await open(tester);
    final initial = cellRects(tester);
    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
    var decoration =
        tester.widget<Container>(cells().first).decoration! as BoxDecoration;
    expect(decoration.gradient, LoginOtpGradients.focusedInputBorder);
    expect(decoration.borderRadius, BorderRadius.circular(6));
    expect(tester.getRect(cells().first).size, initial.first.size);
    states.add(const LoginOtpState(codeFieldError: true));
    await tester.pumpAndSettle();
    for (var index = 0; index < 6; index++) {
      decoration =
          tester.widget<Container>(cells().at(index)).decoration!
              as BoxDecoration;
      expect(decoration.gradient, isNull);
      expect(
        (decoration.border! as Border).top.color,
        LoginOtpColors.otpBoxBorderError,
      );
      expect((decoration.border! as Border).top.width, 1);
      expect(tester.getRect(cells().at(index)).size, initial[index].size);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('typing, focus movement and six-digit paste remain unchanged', (
    tester,
  ) async {
    await open(tester);
    final fields = find.byType(TextField);
    await tester.enterText(fields.first, '1');
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(fields.at(1)).focusNode!.hasFocus, isTrue);
    await tester.enterText(fields.first, '123456');
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<TextField>(fields)
          .map((field) => field.controller!.text)
          .join(),
      '123456',
    );
    verify(() => bloc.add(const LoginOtpCodeChanged('123456'))).called(1);
    expect(
      tester.widget<TextField>(fields.first).autofillHints,
      contains(AutofillHints.oneTimeCode),
    );
    expect(tester.takeException(), isNull);
  });
}
