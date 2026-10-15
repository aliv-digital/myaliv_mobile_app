import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/bloc/change_password_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/changePassword/prepaid/view/change_password_prepaid_screen.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';

class _Network extends Mock implements NetworkService {}

class _Challenge extends Mock implements CallLogsVerificationRepository {}

class _Auth extends Mock implements AuthManager {}

void main() {
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
          await tester.binding.setSurfaceSize(Size(width, 844));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final network = _Network();
          final challenge = _Challenge();
          instance.registerSingleton<NetworkService>(network);
          instance.registerSingleton<CallLogsVerificationRepository>(challenge);
          instance.registerSingleton<AuthManager>(_Auth());
          addTearDown(() async {
            await tester.pumpWidget(const SizedBox.shrink());
            await instance.reset();
          });
          await tester.pumpWidget(
            const MaterialApp(home: ChangePasswordPrepaidScreen()),
          );
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byType(TextField).first,
            scenario.newValue,
          );
          await tester.enterText(find.byType(TextField).last, scenario.confirm);
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
          expect(
            tester
                .element(find.byType(TextField).first)
                .read<ChangePasswordPrepaidBloc>()
                .state
                .status
                .name,
            'ready',
          );
          verifyZeroInteractions(network);
          verifyZeroInteractions(challenge);
          await tester.enterText(find.byType(TextField).first, 'abcdefgh');
          await tester.enterText(find.byType(TextField).last, 'abcdefgh');
          await tester.pumpAndSettle();
          expect(find.text(scenario.error), findsNothing);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
