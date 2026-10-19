import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/resources/widgets/dropdowns/dropdown_content_widgets.dart';
import 'package:myaliv_mobile_app/resources/widgets/dropdowns/saved_card_dropdown.dart';

class _MockSavedCardsCubit extends MockCubit<SavedCardsState>
    implements SavedCardsCubit {}

void main() {
  group('Bug 32: SavedCardDropdown and CardListOverlay Design Verification', () {
    const card1 = SavedCardModel(token: 'token-1', number: '*1234');
    const card2 = SavedCardModel(token: 'token-2', number: '*5678');

    testWidgets(
      'displays purple arrow and opens dropdown with selected/unselected indicators',
      (tester) async {
        final cubit = _MockSavedCardsCubit();
        when(() => cubit.state).thenReturn(
          const SavedCardsState(
            status: SavedCardsStatus.success,
            cards: [card1, card2],
          ),
        );

        SavedCardModel? selected = card1;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(24),
                child: BlocProvider<SavedCardsCubit>.value(
                  value: cubit,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return SavedCardDropdown(
                        selectedCard: selected,
                        onCardSelected: (c) => setState(() => selected = c),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Arrow icon verification when closed (Bug 32 Part 1)
        final arrowDownFinder = find.byIcon(Icons.keyboard_arrow_down);
        expect(arrowDownFinder, findsOneWidget);
        final arrowDownIcon = tester.widget<Icon>(arrowDownFinder);
        expect(arrowDownIcon.color, dropdownSelectedAccent);

        // 2. Open dropdown by tapping
        await tester.tap(find.byType(DropdownContainer));
        await tester.pumpAndSettle();

        // Arrow icon when open should also be purple
        final arrowUpFinder = find.byIcon(Icons.keyboard_arrow_up);
        expect(arrowUpFinder, findsOneWidget);
        final arrowUpIcon = tester.widget<Icon>(arrowUpFinder);
        expect(arrowUpIcon.color, dropdownSelectedAccent);

        // 3. Selection indicator & styling verification (Bug 32 Part 2)
        final text1Finder = find.text('card ending in 1234');
        final text2Finder = find.text('card ending in 5678');
        expect(
          text1Finder,
          findsNWidgets(2),
        ); // 1 in closed container, 1 in overlay
        expect(text2Finder, findsOneWidget);

        // Check overlay selected text (last widget found with this text)
        final overlayText1 = tester.widgetList<Text>(text1Finder).last;
        expect(overlayText1.style?.color, dropdownSelectedAccent);
        expect(overlayText1.style?.fontWeight, FontWeight.w700);

        // Check overlay unselected text
        final overlayText2 = tester.widget<Text>(text2Finder);
        expect(overlayText2.style?.color, Colors.black);
        expect(overlayText2.style?.fontWeight, FontWeight.w400);

        // Check selected indicator: purple circle with white check
        final checkIconFinder = find.byIcon(Icons.check);
        expect(checkIconFinder, findsOneWidget);
        final checkIcon = tester.widget<Icon>(checkIconFinder);
        expect(checkIcon.color, Colors.white);

        // Check unselected indicator: grey circle (Color 0xFFE0E0E0)
        final containers = tester.widgetList<Container>(find.byType(Container));
        final greyCircles = containers.where((c) {
          final dec = c.decoration;
          if (dec is BoxDecoration && dec.shape == BoxShape.circle) {
            return dec.color == const Color(0xFFE0E0E0);
          }
          return false;
        }).toList();
        expect(greyCircles.length, 1);
        expect(greyCircles.first.constraints?.maxWidth, 20);
        expect(greyCircles.first.constraints?.maxHeight, 20);

        // 4. Add new card footer present with black text
        expect(find.textContaining('add new card'), findsOneWidget);

        // 5. Selecting unselected card updates selection and closes dropdown
        await tester.tap(text2Finder);
        await tester.pumpAndSettle();

        expect(selected, equals(card2));
        // Overlay is closed, arrow is down again
        expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
        expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);
      },
    );
  });
}
