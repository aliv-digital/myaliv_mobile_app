import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/postpaid/bloc/top_up_prepaid_number_postpaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/postpaid/widgets/sections/top_up_prepaid_number_postpaid_confirm_number_section.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topup/postpaid/widgets/sections/top_up_prepaid_number_postpaid_number_section.dart';

void main() {
  for (final (isConfirmation, size) in [
    (false, const Size(320, 700)),
    (false, const Size(443, 958)),
  ]) {
    testWidgets(
      '${isConfirmation ? 'confirmation' : 'recipient'} requires 242 and shows invalid format inline at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        var number = '';
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  void onChanged(String value) =>
                      setState(() => number = value);
                  return isConfirmation
                      ? TopUpPrepaidNumberPostPaidConfirmNumberSection(
                          value: number,
                          hasMismatchError:
                              number.isNotEmpty &&
                              number.replaceAll(RegExp(r'\D'), '') !=
                                  '2428011616',
                          onChanged: onChanged,
                        )
                      : TopUpPrepaidNumberPostPaidNumberSection(
                          value: number,
                          onChanged: onChanged,
                        );
                },
              ),
            ),
          ),
        );
        expect(find.text('invalid format'), findsNothing);

        for (final invalidNumber in [
          '8999880',
          '8011616',
          '3058999880',
          '24255',
        ]) {
          await tester.enterText(find.byType(TextField), '');
          await tester.pump();
          await tester.enterText(find.byType(TextField), invalidNumber);
          await tester.pump();
          expect(find.text('invalid format'), findsOneWidget);
          expect(find.text('invalid Format'), findsNothing);
          expect(find.text('invalid phone number'), findsNothing);
          expect(find.text('phone numbers do not match'), findsNothing);
          expect(
            tester.getTopLeft(find.text('invalid format')).dy,
            greaterThan(tester.getBottomLeft(find.byType(TextField)).dy),
          );
          tester.widget<TextField>(find.byType(TextField)).focusNode!.unfocus();
          await tester.pump();
          expect(find.text('invalid format'), findsOneWidget);
        }

        await tester.enterText(find.byType(TextField), '');
        await tester.pump();
        expect(find.text('invalid format'), findsNothing);

        await tester.enterText(find.byType(TextField), '2428011616');
        await tester.pump();
        expect(find.text('invalid format'), findsNothing);
        expect(find.text('phone numbers do not match'), findsNothing);

        if (isConfirmation) {
          await tester.enterText(find.byType(TextField), '');
          await tester.pump();
          await tester.enterText(find.byType(TextField), '2428011617');
          await tester.pump();
          expect(find.text('invalid format'), findsNothing);
          expect(find.text('phone numbers do not match'), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  TopUpPrepaidNumberPostPaidState ready(String number, String confirmation) =>
      TopUpPrepaidNumberPostPaidState.initial().copyWith(
        loadStatus: TopUpPrepaidNumberPostPaidLoadStatus.ready,
        number: number,
        confirmNumber: confirmation,
        amountText: '10',
      );

  test(
    'Apply rejects numbers without 242 instead of adding it automatically',
    () {
      for (final (number, confirmation) in [
        ('8999880', '8999880'),
        ('8011616', '8011616'),
        ('3058999880', '3058999880'),
        ('8011616', '2428011616'),
        ('2428011616', '8011616'),
        ('24255', '24255'),
      ]) {
        expect(ready(number, confirmation).canApply, isFalse);
      }
      expect(ready('8999880', '8999880').numberForApi, isNull);
    },
  );

  test('matching full 242 numbers remain valid, including formatted input', () {
    for (final number in ['2428011616', '(242)-801-1616']) {
      final state = ready(number, number);
      expect(state.canApply, isTrue);
      expect(state.numberForApi, '2428011616');
    }
    expect(ready('2428011616', '2428011617').canApply, isFalse);
  });
}
