import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/theme/theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestPurchasePlan/widgets/roam_bottom_sheet.dart';

const _info =
    'your standalone plan can start immediately, or on a date of your choice.';
const _noDateError = 'choose a start date to continue';
const _oldRed = Color(0xFFF30F0F);

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String _monthName(DateTime d) => _months[d.month - 1];

void main() {
  late List<DateTime> appliedDates;
  late int activateNowTaps;

  setUpAll(() async {
    await (FontLoader('CircularPro')
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'))
          ..addFont(rootBundle.load('assets/fonts/CircularPro-Bold.otf')))
        .load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });

  setUp(() {
    appliedDates = [];
    activateNowTaps = 0;
  });

  // Mirrors how GuestPurchasePlanScreen opens the standalone start sheet.
  Future<void> openSheet(WidgetTester tester, {double width = 390}) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (sheetContext) => RoamBottomSheet(
                  onBackPressed: () => Navigator.of(sheetContext).pop(),
                  onDateApplied: appliedDates.add,
                  onActivateNowPressed: () => activateNowTaps++,
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Finder dateField() => find
      .descendant(
        of: find.byType(RoamBottomSheet),
        matching: find.byType(InkWell),
      )
      .at(1);

  group('GST-013 neutral "when to start?" guidance', () {
    for (final width in [320.0, 390.0, 430.0]) {
      testWidgets('exact neutral copy on load at $width', (tester) async {
        await openSheet(tester, width: width);

        expect(find.text('when to start?'), findsOneWidget);
        expect(find.text(_info), findsOneWidget);
        expect(find.text('start from'), findsOneWidget);
        expect(find.text('activate now'), findsOneWidget);

        final text = tester.widget<Text>(find.text(_info));
        expect(text.style!.color, GuestPurchasePlanTheme.subtitleColor);
        expect(text.style!.color, isNot(_oldRed));
        expect(text.style!.fontSize, 12);
        expect(text.style!.fontWeight, FontWeight.w400);

        final box = tester.widget<Container>(
          find
              .ancestor(of: find.text(_info), matching: find.byType(Container))
              .first,
        );
        final decoration = box.decoration! as BoxDecoration;
        expect(
          decoration.color,
          GuestPurchasePlanTheme.roamBottomSheetDateFieldBackgroundColor,
        );
        expect(
          (decoration.border! as Border).top.color,
          GuestPurchasePlanTheme.roamBottomSheetOrDividerColor,
        );
        expect(
          decoration.color,
          isNot(GuestPurchasePlanTheme.roamBottomSheetWarningBackgroundColor),
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('guidance stays after cancelling the date picker', (
      tester,
    ) async {
      await openSheet(tester);
      await tester.tap(dateField());
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(GuestPurchasePlanTheme.roamCalendarCancelLabel),
      );
      await tester.pumpAndSettle();

      expect(find.text(_info), findsOneWidget);
      expect(appliedDates, isEmpty);
      expect(activateNowTaps, 0);
    });

    test('shared warning tokens are unchanged for other guest sheets', () {
      expect(
        GuestPurchasePlanTheme.warningBorder.toARGB32(),
        const Color(0xFFFCA19B).toARGB32(),
      );
      expect(
        GuestPurchasePlanTheme.roamBottomSheetWarningTextStyle.color!
            .toARGB32(),
        _oldRed.toARGB32(),
      );
    });
  });

  group('GST-011 start date is always selected (no-date unreachable)', () {
    testWidgets('sheet opens with today already shown as the start date', (
      tester,
    ) async {
      final today = DateTime.now();
      await openSheet(tester);

      final fieldText = tester
          .widgetList<Text>(
            find.descendant(of: dateField(), matching: find.byType(Text)),
          )
          .single
          .data!;
      expect(fieldText, startsWith(_monthName(today)));
      expect(fieldText, endsWith('${today.year}'));
      expect(find.text(_noDateError), findsNothing);
    });

    testWidgets('picker opens with a date selected and apply returns it', (
      tester,
    ) async {
      await openSheet(tester);
      await tester.tap(dateField());
      await tester.pumpAndSettle();

      final picker = tester.widget<CalendarDatePicker>(
        find.byType(CalendarDatePicker),
      );
      expect(picker.initialDate, DateUtils.dateOnly(DateTime.now()));

      final chosen = DateUtils.dateOnly(
        DateTime.now().add(const Duration(days: 3)),
      );
      picker.onDateChanged(chosen);
      await tester.pump();
      await tester.tap(
        find.text(GuestPurchasePlanTheme.roamCalendarApplyLabel),
      );
      await tester.pumpAndSettle();

      expect(appliedDates, [chosen]);
      expect(find.text(_noDateError), findsNothing);
    });

    testWidgets('apply without changing the date returns today', (
      tester,
    ) async {
      await openSheet(tester);
      await tester.tap(dateField());
      await tester.pumpAndSettle();
      await tester.tap(
        find.text(GuestPurchasePlanTheme.roamCalendarApplyLabel),
      );
      await tester.pumpAndSettle();

      expect(appliedDates, [DateUtils.dateOnly(DateTime.now())]);
    });

    testWidgets('activate now keeps the existing immediate-start path', (
      tester,
    ) async {
      await openSheet(tester);
      await tester.tap(find.text('activate now'));
      await tester.pump();

      expect(activateNowTaps, 1);
      expect(appliedDates, isEmpty);
      expect(find.text(_noDateError), findsNothing);
    });
  });
}
