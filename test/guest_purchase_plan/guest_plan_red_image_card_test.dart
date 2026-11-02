import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlanAddons/widgets/plan_red_image_card.dart';
import 'package:myaliv_mobile_app/app/Plans/purchasePlanAddOns/widgets/plan_purchase_plan_red_image_card.dart';

void main() {
  group('PlanRedImageCard (Guest add-ons)', () {
    testWidgets('renders labels at font size 13 and dates baseline-aligned', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlanRedImageCard(
              planLabel: 'active plan',
              planName: 'liberty70',
              activeLabel: 'active',
              activeDate: '20/08/24',
              expireLabel: 'expire',
              expireDate: '19/09/24',
              expireTime: '11:59 PM',
            ),
          ),
        ),
      );

      final activeTextFinder = find.text('active');
      final expireTextFinder = find.text('expire');
      expect(activeTextFinder, findsOneWidget);
      expect(expireTextFinder, findsOneWidget);

      final activeTextStyle = tester.widget<Text>(activeTextFinder).style;
      final expireTextStyle = tester.widget<Text>(expireTextFinder).style;
      expect(activeTextStyle?.fontSize, 13);
      expect(expireTextStyle?.fontSize, 13);

      final activeDateFinder = find.text('20/08/24');
      final expireDateFinder = find.text('19/09/24');
      expect(activeDateFinder, findsOneWidget);
      expect(expireDateFinder, findsOneWidget);

      // Verify baseline alignment
      final activeDateBottom = tester.getBottomLeft(activeDateFinder).dy;
      final expireDateBottom = tester.getBottomLeft(expireDateFinder).dy;
      expect(activeDateBottom, equals(expireDateBottom));

      // Verify expireTime
      final expireTimeFinder = find.text('11:59 PM');
      expect(expireTimeFinder, findsOneWidget);

      // Verify gap between plan name and date portion is expanded (>= 30.0)
      final planNameBottom = tester.getBottomLeft(find.text('liberty70')).dy;
      final activeLabelTop = tester.getTopLeft(activeTextFinder).dy;
      final gap = activeLabelTop - planNameBottom;
      expect(gap, greaterThanOrEqualTo(30.0));
    });
  });

  group('PlanPurchasePlanRedImageCard (Plan purchase add-ons)', () {
    testWidgets('renders labels at font size 13 and dates baseline-aligned', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PlanPurchasePlanRedImageCard(
              planLabel: 'active plan will be',
              planName: 'liberty70',
              activeLabel: 'active',
              activeDate: '20/08/24',
              expireLabel: 'expire',
              expireDate: '19/09/24',
              expireTime: '11:59 PM',
              showAutoRenew: false,
            ),
          ),
        ),
      );

      final activeTextFinder = find.text('active');
      final expireTextFinder = find.text('expire');
      expect(activeTextFinder, findsOneWidget);
      expect(expireTextFinder, findsOneWidget);

      final activeTextStyle = tester.widget<Text>(activeTextFinder).style;
      final expireTextStyle = tester.widget<Text>(expireTextFinder).style;
      expect(activeTextStyle?.fontSize, 13);
      expect(expireTextStyle?.fontSize, 13);

      final activeDateFinder = find.text('20/08/24');
      final expireDateFinder = find.text('19/09/24');
      expect(activeDateFinder, findsOneWidget);
      expect(expireDateFinder, findsOneWidget);

      // Verify baseline alignment
      final activeDateBottom = tester.getBottomLeft(activeDateFinder).dy;
      final expireDateBottom = tester.getBottomLeft(expireDateFinder).dy;
      expect(activeDateBottom, equals(expireDateBottom));

      // Verify expireTime
      final expireTimeFinder = find.text('11:59 PM');
      expect(expireTimeFinder, findsOneWidget);

      // Verify gap between plan name and date portion is expanded (>= 30.0)
      final planNameBottom = tester.getBottomLeft(find.text('liberty70')).dy;
      final activeLabelTop = tester.getTopLeft(activeTextFinder).dy;
      final gap = activeLabelTop - planNameBottom;
      expect(gap, greaterThanOrEqualTo(30.0));
    });
  });
}
