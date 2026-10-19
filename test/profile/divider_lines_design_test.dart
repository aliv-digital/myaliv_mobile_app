import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/profile/postpaid/theme/profile_postpaid_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/profile/postpaid/widgets/profile_menu_item_tile.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/profile/prepaid/theme/profile_prepaid_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/profile/prepaid/widgets/profile_menu_item_tile.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/purchases/prepaid/model/purchase_prepaid_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/purchases/prepaid/theme/purchase_prepaid_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/purchases/prepaid/widgets/purchase_prepaid_menu_list.dart';

void main() {
  group('Bugs 41, 42, 43 - Divider Line Indent and Size Tests', () {
    testWidgets(
      'Bug 41: Prepaid Profile MenuItemTile has 20px symmetric indents',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProfileMenuItemTile(
                title: 'my profile',
                enabled: true,
                onTap: () {},
              ),
            ),
          ),
        );

        final dividerFinder = find.byType(Divider);
        expect(dividerFinder, findsOneWidget);

        final divider = tester.widget<Divider>(dividerFinder);
        expect(divider.indent, 20.0);
        expect(divider.endIndent, 20.0);
        expect(divider.color, ProfilePrepaidTheme.divider);

        final paddingFinder = find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Padding),
        );
        final padding = tester.widget<Padding>(paddingFinder);
        expect(
          padding.padding,
          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        );
      },
    );

    testWidgets(
      'Bug 42: Postpaid Profile MenuItemTile has 20px symmetric indents',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ProfilePostpaidMenuItemTile(
                title: 'my profile',
                enabled: true,
                onTap: () {},
              ),
            ),
          ),
        );

        final dividerFinder = find.byType(Divider);
        expect(dividerFinder, findsOneWidget);

        final divider = tester.widget<Divider>(dividerFinder);
        expect(divider.indent, 20.0);
        expect(divider.endIndent, 20.0);
        expect(divider.color, ProfilePostpaidTheme.divider);

        final paddingFinder = find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Padding),
        );
        final padding = tester.widget<Padding>(paddingFinder);
        expect(padding.padding, const EdgeInsets.symmetric(horizontal: 20));
      },
    );

    testWidgets(
      'Bug 43: Purchases menu list has 20px horizontalPad and top/inter-item dividers',
      (tester) async {
        const items = [
          PurchasePrepaidMenuItem(
            title: 'buy plans',
            action: PurchasePrepaidAction.buyPlans,
          ),
          PurchasePrepaidMenuItem(
            title: 'make payment',
            action: PurchasePrepaidAction.makePayment,
          ),
        ];

        expect(PurchasePrepaidTheme.horizontalPad, 20.0);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PurchasePrepaidMenuList(items: items, onTapItem: (_) {}),
            ),
          ),
        );

        // Should have top divider + 1 divider between 2 items = 2 dividers total
        final dividerFinder = find.byType(Divider);
        expect(dividerFinder, findsNWidgets(2));

        final dividers = tester.widgetList<Divider>(dividerFinder).toList();
        for (final divider in dividers) {
          expect(divider.indent, 20.0);
          expect(divider.endIndent, 20.0);
          expect(divider.color, PurchasePrepaidTheme.divider);
        }
      },
    );
  });
}
