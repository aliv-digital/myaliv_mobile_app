import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/postpaid/widgets/sections/top_up_prepaid_number_postpaid_number_section.dart';

void main() {
  testWidgets('recipient format copy preserves empty and valid input', (
    tester,
  ) async {
    var number = '';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) =>
                TopUpPrepaidNumberPostPaidNumberSection(
                  value: number,
                  onChanged: (value) => setState(() => number = value),
                ),
          ),
        ),
      ),
    );
    expect(find.text('invalid Format'), findsNothing);

    await tester.enterText(find.byType(TextField), '24255');
    await tester.pump();
    expect(find.text('invalid Format'), findsOneWidget);
    expect(find.text('invalid phone number'), findsNothing);

    for (final validNumber in ['8011616', '2428011616']) {
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(find.text('invalid Format'), findsNothing);
      await tester.enterText(find.byType(TextField), validNumber);
      await tester.pump();
      expect(find.text('invalid Format'), findsNothing);
    }
  });
}
