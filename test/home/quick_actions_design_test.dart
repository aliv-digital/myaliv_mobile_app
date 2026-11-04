import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/action_tile.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/home_quick_actions.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

class MockAppUiConfigCubit extends Mock implements AppUiConfigCubit {}

void main() {
  group('Bug 39 - Quick Actions Postpaid and Prepaid Design Tests', () {
    test('Verify all 6 quick action icon assets exist on disk', () {
      final assets = [
        'assets/icons/ListStarQuick.svg',
        'assets/icons/SortDescending.svg',
        'assets/icons/add_credit_card.svg',
        'assets/icons/At.svg',
        'assets/icons/aliv_quick.svg',
        'assets/icons/headphone.svg',
        'assets/icons/UsersThree.svg',
      ];

      for (final asset in assets) {
        final file = File(asset);
        expect(file.existsSync(), isTrue, reason: 'Asset missing: $asset');
      }
    });

    testWidgets('Postpaid quick actions renders exact 6 tiles matching Figma', (
      tester,
    ) async {
      const config = HomeUiConfig(
        userType: UserType.postpaid,
        hasActivePlan: true,
        isFuturePlan: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HomeQuickActions(config: config)),
        ),
      );

      final tiles = tester
          .widgetList<ActionTile>(find.byType(ActionTile))
          .toList();

      expect(tiles.length, 6);

      // Row 1: buy plans, update credit limit, add credit card
      expect(tiles[0].label, 'buy\nplans');
      expect(tiles[0].iconPath, 'assets/icons/ListStarQuick.svg');

      expect(tiles[1].label, 'update\ncredit limit');
      expect(tiles[1].iconPath, 'assets/icons/SortDescending.svg');

      expect(tiles[2].label, 'add\ncredit card');
      expect(tiles[2].iconPath, 'assets/icons/add_credit_card.svg');

      // Row 2: update email, ALIV deals, help & support
      expect(tiles[3].label, 'update\nemail');
      expect(tiles[3].iconPath, 'assets/icons/At.svg');

      expect(tiles[4].label, 'ALIV deals');
      expect(tiles[4].iconPath, 'assets/icons/aliv_quick.svg');

      expect(tiles[5].label, 'help & support');
      expect(tiles[5].iconPath, 'assets/icons/headphone.svg');

      // Must NOT contain refer a friend for postpaid
      expect(find.text('refer a friend'), findsNothing);
    });

    testWidgets('Prepaid quick actions preserves prepaid action tiles', (
      tester,
    ) async {
      const config = HomeUiConfig(
        userType: UserType.prepaid,
        hasActivePlan: true,
        isFuturePlan: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HomeQuickActions(config: config)),
        ),
      );

      final tiles = tester
          .widgetList<ActionTile>(find.byType(ActionTile))
          .toList();

      expect(tiles.length, 6);

      // Row 1: buy plans, add credit card, update email
      expect(tiles[0].label, 'buy\nplans');
      expect(tiles[0].iconPath, 'assets/icons/ListStarQuick.svg');

      expect(tiles[1].label, 'add\ncredit card');
      expect(tiles[1].iconPath, 'assets/icons/add_credit_card.svg');

      expect(tiles[2].label, 'update\nemail');
      expect(tiles[2].iconPath, 'assets/icons/At.svg');

      // Row 2: refer a friend, ALIV deals, help & support
      expect(tiles[3].label, 'refer a friend');
      expect(tiles[3].iconPath, 'assets/icons/UsersThree.svg');

      expect(tiles[4].label, 'ALIV deals');
      expect(tiles[4].iconPath, 'assets/icons/aliv_quick.svg');

      expect(tiles[5].label, 'help & support');
      expect(tiles[5].iconPath, 'assets/icons/headphone.svg');

      // Must NOT contain update credit limit for prepaid
      expect(find.text('update\ncredit limit'), findsNothing);
    });

    testWidgets(
      'Restricted readOnly role renders exact 5 tiles matching design',
      (tester) async {
        const config = HomeUiConfig(
          userType: UserType.postpaid,
          hasActivePlan: true,
          isFuturePlan: false,
          lineRole: LineRole.readOnly,
        );

        final mockCubit = MockAppUiConfigCubit();

        await tester.pumpWidget(
          BlocProvider<AppUiConfigCubit>.value(
            value: mockCubit,
            child: const MaterialApp(
              home: Scaffold(body: HomeQuickActions(config: config)),
            ),
          ),
        );

        final tiles = tester
            .widgetList<ActionTile>(find.byType(ActionTile))
            .toList();

        expect(tiles.length, 5);

        // Row 1: future plans, update email, refer a friend
        expect(tiles[0].label, 'future\nplans');
        expect(tiles[0].iconPath, 'assets/icons/ListStarQuick.svg');

        expect(tiles[1].label, 'update\nemail');
        expect(tiles[1].iconPath, 'assets/icons/At.svg');

        expect(tiles[2].label, 'refer a friend');
        expect(tiles[2].iconPath, 'assets/icons/UsersThree.svg');

        // Row 2: ALIV deals, help & support
        expect(tiles[3].label, 'ALIV deals');
        expect(tiles[3].iconPath, 'assets/icons/aliv_quick.svg');

        expect(tiles[4].label, 'help & support');
        expect(tiles[4].iconPath, 'assets/icons/headphone.svg');

        // Restricted must NOT show buy plans, update credit limit, or add credit card
        expect(find.text('buy\nplans'), findsNothing);
        expect(find.text('update\ncredit limit'), findsNothing);
        expect(find.text('add\ncredit card'), findsNothing);
      },
    );

    testWidgets(
      'Restricted prepaid role also renders exact 5 tiles matching design',
      (tester) async {
        const config = HomeUiConfig(
          userType: UserType.prepaid,
          hasActivePlan: true,
          isFuturePlan: false,
          lineRole: LineRole.readOnly,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: HomeQuickActions(config: config)),
          ),
        );

        final tiles = tester
            .widgetList<ActionTile>(find.byType(ActionTile))
            .toList();

        expect(tiles.length, 5);
        expect(tiles[0].label, 'future\nplans');
        expect(tiles[1].label, 'update\nemail');
        expect(tiles[2].label, 'refer a friend');
        expect(tiles[3].label, 'ALIV deals');
        expect(tiles[4].label, 'help & support');
      },
    );
  });
}
