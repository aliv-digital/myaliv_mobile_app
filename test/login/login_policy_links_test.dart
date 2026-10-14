import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/login_privacy_policy_link.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/login_privacy_policy_modal.dart';

void main() {
  testWidgets('privacy policy and terms of use are separate links', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: LoginPrivacyPolicyLink())),
      ),
    );

    expect(find.widgetWithText(TextButton, 'Privacy Policy'), findsOneWidget);
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
  testWidgets('privacy link still opens its existing dialog', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: LoginPrivacyPolicyLink())),
      ),
    );
    await tester.tap(find.widgetWithText(TextButton, 'Privacy Policy'));
    await tester.pump();
    expect(find.byType(LoginPrivacyPolicyDialog), findsOneWidget);
    expect(find.text('Privacy Policy'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final width in [320.0, 390.0]) {
      testWidgets(
        '$platform footer is centered and baseline-aligned at $width',
        (tester) async {
          tester.view.physicalSize = Size(width, 700);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(platform: platform),
              home: const Scaffold(
                body: Center(child: LoginPrivacyPolicyLink()),
              ),
            ),
          );
          expect(tester.takeException(), isNull);
          expect(find.byType(TextButton), findsNWidgets(2));
          expect(find.text('|'), findsOneWidget);
          final group = find.descendant(
            of: find.byType(LoginPrivacyPolicyLink),
            matching: find.byType(Row),
          );
          expect(tester.getCenter(group).dx, closeTo(width / 2, 0.01));
          final row = tester.widget<Row>(group);
          expect(row.crossAxisAlignment, CrossAxisAlignment.baseline);
          final underline =
              tester
                      .widget<DecoratedBox>(
                        find
                            .descendant(
                              of: find.byType(LoginPrivacyPolicyLink),
                              matching: find.byType(DecoratedBox),
                            )
                            .first,
                      )
                      .decoration
                  as BoxDecoration;
          expect((underline.border! as Border).bottom.style, BorderStyle.solid);
          for (final label in ['Privacy Policy', 'Terms of Use']) {
            final text = tester.widget<Text>(find.text(label));
            expect(text.style!.fontSize, 10);
            expect(text.style!.fontWeight, FontWeight.w700);
            expect(
              text.style!.color,
              (underline.border! as Border).bottom.color,
            );
            expect(text.style!.decoration, TextDecoration.none);
          }
        },
      );
    }
  }
}
