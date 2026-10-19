import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/change_password_flow_harness.dart';

void main() {
  setUpAll(loadChangePasswordTestFonts);
  for (final width in [320.0, 390.0]) {
    for (final scenario in [
      (newValue: '', confirm: '', error: 'New password is required.'),
      (newValue: '   ', confirm: '', error: 'New password is required.'),
      (
        newValue: 'abcdefgh',
        confirm: '',
        error: 'Please re-enter your password.',
      ),
      (
        newValue: 'abcdefgh',
        confirm: '   ',
        error: 'Please re-enter your password.',
      ),
      (
        newValue: 'abcdefgh',
        confirm: 'abcdEfgh',
        error: 'Passwords do not match. Try again.',
      ),
      (
        newValue: 'abcdefgh',
        confirm: 'abc',
        error: 'Passwords do not match. Try again.',
      ),
      (
        newValue: 'abc',
        confirm: 'abc',
        error: 'password does not meet the requirement',
      ),
    ]) {
      testWidgets(
        'local validation ${scenario.error} (new length ${scenario.newValue.length}, confirm ${scenario.confirm}) at $width',
        (tester) async {
          await withChangePasswordFlow(tester, (h) async {
            await h.start(tester, width: width);
            await h.select(tester);
            await h.verify(tester);
            await tester.enterText(
              find.byType(TextField).first,
              scenario.newValue,
            );
            await tester.enterText(
              find.byType(TextField).last,
              scenario.confirm,
            );
            await tester.pumpAndSettle();
            tester.testTextInput.hide();
            FocusManager.instance.primaryFocus?.unfocus();
            await tester.pumpAndSettle();
            final button = find.byType(ElevatedButton);
            await tester.ensureVisible(button);
            expect(tester.widget<ElevatedButton>(button).onPressed, isNotNull);
            await tester.tap(button);
            await tester.pumpAndSettle();
            expect(
              find.text(scenario.error),
              scenario.error == 'password does not meet the requirement'
                  ? findsNWidgets(2)
                  : findsOneWidget,
            );
            expect(find.text('Password required.'), findsNothing);
            expect(h.challenges, 1);
            expect(h.verifications, 1);
            expect(h.updates, 0);
            await tester.enterText(find.byType(TextField).first, 'abcdefgh');
            await tester.enterText(find.byType(TextField).last, 'abcdefgh');
            await tester.pumpAndSettle();
            expect(find.text(scenario.error), findsNothing);
            expect(tester.takeException(), isNull);
          });
        },
      );
    }
  }
}
