import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/referAFriend/referFriend/prepaid/view/success_screen.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/referAFriend/referFriend/prepaid/widgets/refer_friend_prepaid_tabs.dart';

void main() {
  group('Bug 37 - Refer Friend Tabs Baseline Tests', () {
    testWidgets('ReferFriendPrepaidTabs has a full-width bottom divider line', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReferFriendPrepaidTabs(selectedIndex: 0, onChanged: (_) {}),
          ),
        ),
      );

      // Verify full-width divider is present at the bottom of the tab bar
      final dividerFinder = find.byType(Divider);
      expect(dividerFinder, findsOneWidget);

      final divider = tester.widget<Divider>(dividerFinder);
      expect(divider.color, const Color(0xFFE6E6EC));
      expect(divider.thickness, 1);
    });
  });

  group('Bug 38 - Success Screen Text Alignment & Copy Button Tests', () {
    testWidgets(
      'InvitingSuccessScreen description has exact line breaks matching Figma',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: InvitingSuccessScreen(referralCode: 'REF123456'),
          ),
        );

        const expectedDescription =
            "Thank you for inviting your friend to join\n"
            "the ALIV network! once they’re on the\n"
            "network for three months, you will\n"
            "receive your cash back reward.";

        final descFinder = find.text(expectedDescription);
        expect(descFinder, findsOneWidget);

        final descText = tester.widget<Text>(descFinder);
        expect(descText.textAlign, TextAlign.center);
        expect(descText.style?.color, const Color(0xFF707070));
        expect(descText.style?.fontSize, 16);
        expect(descText.style?.fontWeight, FontWeight.w400);
      },
    );

    testWidgets('InvitingSuccessScreen copy button is present and aligned', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InvitingSuccessScreen(referralCode: 'REF123456'),
        ),
      );

      expect(find.text('REF123456'), findsOneWidget);
      expect(find.text('copy'), findsOneWidget);
    });
  });
}
