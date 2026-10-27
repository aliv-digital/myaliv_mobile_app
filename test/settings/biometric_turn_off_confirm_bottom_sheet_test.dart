import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/settings/settingScreen/widgets/biometric_turn_off_confirm_bottom_sheet.dart';

const _message = 'are you sure you want to turn off fingerprint?';

void main() {
  Future<List<bool>> openSheet(WidgetTester tester) async {
    final results = <bool>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                results.add(
                  await BiometricTurnOffConfirmBottomSheet.show(
                    context,
                    message: _message,
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('shows message with no and yes buttons', (tester) async {
    await openSheet(tester);

    expect(find.text(_message), findsOneWidget);
    expect(find.text('no'), findsOneWidget);
    expect(find.text('yes'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('yes confirms', (tester) async {
    final results = await openSheet(tester);

    await tester.tap(find.text('yes'));
    await tester.pumpAndSettle();

    expect(results, [true]);
    expect(find.text(_message), findsNothing);
  });

  testWidgets('no cancels', (tester) async {
    final results = await openSheet(tester);

    await tester.tap(find.text('no'));
    await tester.pumpAndSettle();

    expect(results, [false]);
  });

  testWidgets('back arrow cancels', (tester) async {
    final results = await openSheet(tester);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(results, [false]);
  });

  testWidgets('tapping outside cancels', (tester) async {
    final results = await openSheet(tester);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(results, [false]);
  });
}
