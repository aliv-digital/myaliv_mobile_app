import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/postpaid/theme/top_up_prepaid_number_postpaid_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/postpaid/widgets/sections/top_up_prepaid_number_postpaid_confirm_number_section.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/postpaid/widgets/sections/top_up_prepaid_number_postpaid_number_section.dart';
import 'package:myaliv_mobile_app/resources/widgets/custom_country_phone_input_row.dart';

void main() {
  group('Bug 44: Postpaid Top-Up Input Box Styling', () {
    testWidgets(
      'number section has #F2F1F9 color, no border when inactive, and active border when focused',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TopUpPrepaidNumberPostPaidNumberSection(
                value: '',
                onChanged: (_) {},
              ),
            ),
          ),
        );

        final rowFinder = find.byType(CustomCountryPhoneInputRow);
        expect(rowFinder, findsOneWidget);

        final rowWidget = tester.widget<CustomCountryPhoneInputRow>(rowFinder);
        expect(rowWidget.backgroundColor, const Color(0xFFF2F1F9));
        expect(
          rowWidget.backgroundColor,
          TopUpPrepaidNumberPostPaidTheme.fieldBg,
        );
        expect(rowWidget.unfocusedBorderColor, Colors.transparent);
        expect(rowWidget.hideUnfocusedInputBorder, isTrue);
        expect(rowWidget.showCountryPickerBorder, isFalse);
        expect(rowWidget.borderRadius, TopUpPrepaidNumberPostPaidTheme.radius);

        // Tap the textfield to focus it (make it active)
        final textFieldFinder = find.byType(TextField);
        expect(textFieldFinder, findsOneWidget);
        await tester.tap(textFieldFinder);
        await tester.pump();

        // When focused (active), the gradient border wrapper must show the active border
        final animatedContainers = tester.widgetList<Container>(
          find.descendant(of: rowFinder, matching: find.byType(Container)),
        );
        final wrapperContainer = animatedContainers.firstWhere(
          (c) =>
              c.decoration is BoxDecoration &&
              (c.decoration as BoxDecoration).gradient != null,
        );
        final decoration = wrapperContainer.decoration as BoxDecoration;
        expect(decoration.gradient, isNotNull);
      },
    );

    testWidgets(
      'confirm number section has #F2F1F9 color, no border when inactive, and active border when focused',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TopUpPrepaidNumberPostPaidConfirmNumberSection(
                value: '',
                onChanged: (_) {},
              ),
            ),
          ),
        );

        final rowFinder = find.byType(CustomCountryPhoneInputRow);
        expect(rowFinder, findsOneWidget);

        final rowWidget = tester.widget<CustomCountryPhoneInputRow>(rowFinder);
        expect(rowWidget.backgroundColor, const Color(0xFFF2F1F9));
        expect(
          rowWidget.backgroundColor,
          TopUpPrepaidNumberPostPaidTheme.fieldBg,
        );
        expect(rowWidget.unfocusedBorderColor, Colors.transparent);
        expect(rowWidget.hideUnfocusedInputBorder, isTrue);
        expect(rowWidget.showCountryPickerBorder, isFalse);
        expect(rowWidget.borderRadius, TopUpPrepaidNumberPostPaidTheme.radius);

        // Tap the textfield to focus it (make it active)
        final textFieldFinder = find.byType(TextField);
        expect(textFieldFinder, findsOneWidget);
        await tester.tap(textFieldFinder);
        await tester.pump();

        // When focused (active), the gradient border wrapper must show the active border
        final animatedContainers = tester.widgetList<Container>(
          find.descendant(of: rowFinder, matching: find.byType(Container)),
        );
        final wrapperContainer = animatedContainers.firstWhere(
          (c) =>
              c.decoration is BoxDecoration &&
              (c.decoration as BoxDecoration).gradient != null,
        );
        final decoration = wrapperContainer.decoration as BoxDecoration;
        expect(decoration.gradient, isNotNull);
      },
    );
  });
}
