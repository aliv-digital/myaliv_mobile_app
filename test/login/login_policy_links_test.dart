import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/login_privacy_policy_link.dart';

void main() {
  testWidgets('privacy policy and terms of use are separate links', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: LoginPrivacyPolicyLink())),
      ),
    );

    //expect(find.widgetWithText(TextButton, 'Privacy Policy'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Terms of Use'), findsOneWidget);
    expect(find.text('|'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Terms of Use'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Terms of Use'), findsNWidgets(2));
    expect(find.textContaining('temporary sample content'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsNothing);
  });
}
