import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/theme/top_up_prepaid_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/prepaid/widgets/top_up_prepaid_amount_box.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('CircularPro')
      ..addFont(rootBundle.load('assets/fonts/CircularPro-Book.otf'));
    await loader.load();
  });

  Future<void> pumpAmount(
    WidgetTester tester, {
    String value = '',
    ValueChanged<String>? onChanged,
    TargetPlatform platform = TargetPlatform.iOS,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: platform),
        home: Scaffold(
          body: Center(
            child: TopUpPrepaidAmountBox(
              value: value,
              onChanged: onChanged ?? (_) {},
            ),
          ),
        ),
      ),
    );
  }

  void expectCentered(WidgetTester tester) {
    final box = tester.getRect(find.byType(TopUpPrepaidAmountBox));
    final editable = tester
        .state<EditableTextState>(find.byType(EditableText))
        .renderEditable;
    final value = tester
        .widget<EditableText>(find.byType(EditableText))
        .controller
        .text;
    Rect visible;
    if (value.isEmpty) {
      final hint = tester.renderObject<RenderParagraph>(find.text(r'$0.00'));
      visible = hint
          .getBoxesForSelection(
            const TextSelection(baseOffset: 0, extentOffset: 5),
          )
          .map((box) => box.toRect().shift(hint.localToGlobal(Offset.zero)))
          .reduce((a, b) => a.expandToInclude(b));
      expect(find.text(r'$'), findsNothing);
    } else {
      // Measure the glyph bounds rather than selection highlight leading.
      final selectionHeightStyle = editable.selectionHeightStyle;
      editable.selectionHeightStyle = ui.BoxHeightStyle.tight;
      final textBoxes = editable.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: value.length),
      );
      editable.selectionHeightStyle = selectionHeightStyle;
      visible = textBoxes
          .map((box) => box.toRect().shift(editable.localToGlobal(Offset.zero)))
          .reduce((a, b) => a.expandToInclude(b));
      final currency = tester.getRect(find.text(r'$'));
      expect(
        visible.left - currency.right,
        closeTo(TopUpPrepaidTheme.amountFieldCurrencyGap, 1),
      );

      final currencyRender = tester.renderObject<RenderBox>(find.text(r'$'));
      final currencyBaseline =
          currencyRender.localToGlobal(Offset.zero).dy +
          currencyRender.getDryBaseline(
            currencyRender.constraints,
            TextBaseline.alphabetic,
          )!;
      final valueBaseline =
          editable.localToGlobal(Offset.zero).dy +
          editable.getDryBaseline(
            editable.constraints,
            TextBaseline.alphabetic,
          )!;
      expect(valueBaseline, closeTo(currencyBaseline, 0.1));
      visible = visible.expandToInclude(currency);
    }
    expect(visible.center.dx, closeTo(box.center.dx, 0.1));
    expect(visible.center.dy, closeTo(box.center.dy, 0.1));
    expect(box.width, 250);
    expect(box.height, 71);
    expect(tester.takeException(), isNull);
  }

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final width in [320.0, 390.0, 430.0]) {
      testWidgets('full amount stays centered on $platform at width $width', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 844);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final values = <String>[];
        await pumpAmount(tester, onChanged: values.add, platform: platform);
        await tester.pumpAndSettle();
        expectCentered(tester);

        // The limit is account-dependent; cover the usual $100 and $1,000
        // configuration already exercised by TOP-003, including cents.
        for (final value in [
          '1',
          '15',
          '15.00',
          '10',
          '10.25',
          '100.00',
          '1000.00',
          '1',
          '',
        ]) {
          await tester.enterText(find.byType(TextField), value);
          await tester.pumpAndSettle();
          expect(values.last, value);
          expectCentered(tester);
        }
      });
    }
  }

  testWidgets(
    'first entered amount is centered before hint animations settle',
    (tester) async {
      var amount = '';
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (context, setState) => TopUpPrepaidAmountBox(
                  value: amount,
                  onChanged: (value) => setState(() => amount = value),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      for (final value in ['5', '50', '5', '', '5']) {
        await tester.enterText(find.byType(TextField), value);
        await tester.pump();
        expectCentered(tester);
        await tester.pump(const Duration(milliseconds: 10));
        expectCentered(tester);
        await tester.pumpAndSettle();
        expectCentered(tester);
      }
    },
  );

  testWidgets(
    'editing preserves focus, selection, sanitizing and raw callbacks',
    (tester) async {
      final values = <String>[];
      await pumpAmount(tester, value: '10.25', onChanged: values.add);
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      final field = tester.widget<TextField>(find.byType(TextField));
      final controller = field.controller!;
      final focus = field.focusNode!;
      expect(focus.hasFocus, isTrue);

      const middle = TextSelection.collapsed(offset: 2);
      controller.selection = middle;
      await tester.pump();
      expect(controller.selection, middle);
      expectCentered(tester);

      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '105.25',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.text, '105.25');
      expect(controller.selection.baseOffset, 3);
      expect(values.last, '105.25');
      expectCentered(tester);

      const selected = TextSelection(baseOffset: 1, extentOffset: 4);
      tester.testTextInput.updateEditingValue(
        TextEditingValue(text: controller.text, selection: selected),
      );
      await tester.pump();
      expect(controller.selection, selected);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '175',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.text, '175');
      expect(controller.selection.baseOffset, 2);
      expectCentered(tester);

      await tester.enterText(find.byType(TextField), r'$1a0.2.5');
      await tester.pumpAndSettle();
      expect(controller.text, '10.25');
      expect(values.last, '10.25');
      expect(focus.hasFocus, isTrue);
      expectCentered(tester);

      // Parent echoes must keep the same editing owners and selection.
      controller.selection = middle;
      await pumpAmount(tester, value: '10.25', onChanged: values.add);
      await tester.pump();
      final echoed = tester.widget<TextField>(find.byType(TextField));
      expect(echoed.controller, same(controller));
      expect(echoed.focusNode, same(focus));
      expect(controller.selection, middle);

      await pumpAmount(tester, value: '100.00', onChanged: values.add);
      await tester.pumpAndSettle();
      expect(controller.text, '100.00');
      expect(controller.selection.baseOffset, 6);
      expectCentered(tester);

      // Long input remains scrollable within the existing maximum field width.
      await tester.enterText(find.byType(TextField), '12345678901234567890.25');
      await tester.pumpAndSettle();
      expect(controller.text, '12345678901234567890.25');
      expect(
        tester.getSize(find.byType(TextField)).width,
        TopUpPrepaidTheme.amountFieldMaxInputWidth,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
