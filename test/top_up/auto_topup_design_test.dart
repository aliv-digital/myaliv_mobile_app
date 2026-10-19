import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/theme/top_up_prepaid_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/auto_topup/auto_topup_amount_grid.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/auto_topup/auto_topup_sections.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/auto_topup/auto_topup_widgets.dart';

void main() {
  group('Bug 33: Auto Top-up Figma Design Verification', () {
    testWidgets('AutoTopupSectionLabel renders with muted color #707070', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AutoTopupSectionLabel('select a top-up amount')),
        ),
      );

      final textFinder = find.text('select a top-up amount');
      expect(textFinder, findsOneWidget);

      final text = tester.widget<Text>(textFinder);
      expect(text.style?.color, const Color(0xFF707070));
      expect(text.style?.fontSize, 14);
      expect(text.style?.fontWeight, FontWeight.w700);
    });

    testWidgets(
      'AutoTopupOrDivider renders thin divider and compact 12px muted text',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: AutoTopupOrDivider())),
        );

        final textFinder = find.text('or');
        expect(textFinder, findsOneWidget);

        final text = tester.widget<Text>(textFinder);
        expect(text.style?.fontSize, 12);
        expect(text.style?.fontWeight, FontWeight.w500);
        expect(text.style?.color, TopUpPrepaidTheme.textMuted);

        final dividers = tester.widgetList<Divider>(find.byType(Divider));
        expect(dividers.length, 2);
        for (final d in dividers) {
          expect(d.color, TopUpPrepaidTheme.divider);
        }
      },
    );

    testWidgets(
      'AutoTopupAmountGrid renders 6 tiles with radius 12, spacing 10, and amountTileBg',
      (tester) async {
        int? selected;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return AutoTopupAmountGrid(
                    selectedAmount: selected,
                    onAmountSelected: (a) => setState(() => selected = a),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Check grid spacing and padding
        final gridFinder = find.byType(GridView);
        expect(gridFinder, findsOneWidget);
        final grid = tester.widget<GridView>(gridFinder);
        expect(grid.padding, EdgeInsets.zero);
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisSpacing, 16);
        expect(delegate.mainAxisSpacing, 16);
        expect(delegate.childAspectRatio, 1.24);

        // Check unselected tile container decoration
        final tile10Finder = find.text('\$ 10.00');
        expect(tile10Finder, findsOneWidget);

        final containers = tester.widgetList<Container>(find.byType(Container));
        final unselectedTileContainers = containers.where((c) {
          final dec = c.decoration;
          if (dec is BoxDecoration &&
              dec.color == TopUpPrepaidTheme.amountTileBg) {
            return dec.borderRadius == BorderRadius.circular(12);
          }
          return false;
        }).toList();

        // All 6 preset tiles should initially be unselected with amountTileBg and radius 12
        expect(unselectedTileContainers.length, 6);

        // Tap $15 tile to select
        await tester.tap(find.text('\$ 15.00'));
        await tester.pumpAndSettle();

        expect(selected, 15);
      },
    );

    testWidgets(
      'AutoTopupAmountSection has compact spacing between label and grid',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AutoTopupAmountSection(
                selectedAmount: null,
                onAmountSelected: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final labelFinder = find.byType(AutoTopupSectionLabel);
        final gridFinder = find.byType(AutoTopupAmountGrid);

        final labelBottom = tester.getBottomLeft(labelFinder).dy;
        final gridTop = tester.getTopLeft(gridFinder).dy;

        // AutoTopupSectionLabel has bottom padding 8, so gridTop should equal labelBottom
        expect(gridTop, equals(labelBottom));
      },
    );
  });
}
