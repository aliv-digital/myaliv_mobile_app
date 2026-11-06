import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/resources/widgets/fair_use_policy_modal.dart';
import 'package:myaliv_mobile_app/resources/widgets/terms_and_conditions_modal.dart';

void main() {
  testWidgets('FairUsePolicyDialog displays title, headings and close button', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: FairUsePolicyDialog())),
    );

    expect(find.text('Fair Use Policy'), findsOneWidget);
    expect(find.text('Excessive Network Usage'), findsOneWidget);
    expect(
      find.text('Your Term of Service and Termination Fees'),
      findsOneWidget,
    );
    expect(find.text('Postpaid Deposit'), findsOneWidget);
    expect(find.text('Policy Changes'), findsOneWidget);
    expect(find.byType(TermsShieldBadge), findsOneWidget);
    expect(find.byType(TermsDialogCloseButton), findsOneWidget);
  });

  testWidgets(
    'showFairUsePolicyModal opens dialog and close button dismisses it',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => showFairUsePolicyModal(context),
                  child: const Text('Open Policy'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.byType(FairUsePolicyDialog), findsNothing);

      await tester.tap(find.text('Open Policy'));
      await tester.pumpAndSettle();

      expect(find.byType(FairUsePolicyDialog), findsOneWidget);
      expect(find.text('Fair Use Policy'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byType(TermsDialogCloseButton));
      await tester.pumpAndSettle();

      expect(find.byType(FairUsePolicyDialog), findsNothing);
    },
  );
}
