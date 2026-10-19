import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/save_new_card_bottom_sheet.dart';

const _error = 'enter a valid expiry date';
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

String _mmyy(int month, int year) =>
    '${month.toString().padLeft(2, '0')}${(year % 100).toString().padLeft(2, '0')}';

void main() {
  final now = DateTime.now();
  String? result;
  var closed = false;

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
    result = null;
    closed = false;
  });

  Future<void> openPicker(
    WidgetTester tester, {
    required bool rejectPastExpiry,
  }) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await SaveNewCardBottomSheet.showForExpiryCapture(
                  context,
                  rejectPastExpiry: rejectPastExpiry,
                );
                closed = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> pick(WidgetTester tester, String current, String next) async {
    await tester.tap(find.text(current).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(next).last);
    await tester.pumpAndSettle();
  }

  Future<void> confirm(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'save card'));
    await tester.pumpAndSettle();
  }

  final currentMonth = _months[now.month - 1];
  final hasEarlierMonth = now.month > 1;
  // The menu builds lazily around the selection, so use the adjacent month.
  final previousMonth = hasEarlierMonth ? _months[now.month - 2] : '';

  testWidgets('CARD-002 current month/year is valid', (tester) async {
    await openPicker(tester, rejectPastExpiry: true);
    await confirm(tester);
    expect(find.text(_error), findsNothing);
    expect(closed, isTrue);
    expect(result, _mmyy(now.month, now.year));
  });

  testWidgets('CARD-002 earlier month this year is blocked inline', (
    tester,
  ) async {
    await openPicker(tester, rejectPastExpiry: true);
    await pick(tester, currentMonth, previousMonth);
    await confirm(tester);
    expect(find.text(_error), findsOneWidget);
    expect(closed, isFalse);
    expect(result, isNull);
  }, skip: !hasEarlierMonth);

  testWidgets('CARD-002 error clears once a valid month is chosen', (
    tester,
  ) async {
    await openPicker(tester, rejectPastExpiry: true);
    await pick(tester, currentMonth, previousMonth);
    await confirm(tester);
    expect(find.text(_error), findsOneWidget);
    await pick(tester, previousMonth, currentMonth);
    expect(find.text(_error), findsNothing);
    await confirm(tester);
    expect(result, _mmyy(now.month, now.year));
  }, skip: !hasEarlierMonth);

  testWidgets('CARD-002 an earlier month next year is valid', (tester) async {
    if (!hasEarlierMonth) return;
    await openPicker(tester, rejectPastExpiry: true);
    await pick(tester, currentMonth, previousMonth);
    await pick(tester, '${now.year}', '${now.year + 1}');
    await confirm(tester);
    expect(find.text(_error), findsNothing);
    expect(result, _mmyy(now.month - 1, now.year + 1));
  });

  testWidgets(
    'without the opt-in flag existing callers are unchanged',
    (tester) async {
      await openPicker(tester, rejectPastExpiry: false);
      await pick(tester, currentMonth, previousMonth);
      await confirm(tester);
      expect(find.text(_error), findsNothing);
      expect(result, _mmyy(now.month - 1, now.year));
    },
    skip: !hasEarlierMonth,
  );
}
