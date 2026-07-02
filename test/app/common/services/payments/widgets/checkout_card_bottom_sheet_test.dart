import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/checkout_card_bottom_sheet.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/card_input_helpers.dart';

void main() {
  test('saved-card validator enforces API number rules', () {
    expect(CardValidators.savedCardNumber('4111111111111111'), isNotNull);
    expect(CardValidators.savedCardNumber('3111111111111111'), isNull);
    expect(CardValidators.savedCardNumber('411111111111111'), isNull);
  });

  testWidgets('payment constructor preserves checkout copy and amount', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CheckoutCardBottomSheet(amountText: r'$ 106.00'),
        ),
      ),
    );

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('amount'), findsOneWidget);
    expect(find.text(r'$ 106.00'), findsOneWidget);
    expect(find.text('confirm payment'), findsOneWidget);
  });

  testWidgets('add-card constructor hides amount and uses add copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CheckoutCardBottomSheet.forAddCard()),
      ),
    );

    expect(find.text('Add card'), findsOneWidget);
    expect(find.text('amount'), findsNothing);
    expect(find.text('save card'), findsOneWidget);
  });

  testWidgets('add-card mode limits card number to valid 16 digits', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CheckoutCardBottomSheet.forAddCard()),
      ),
    );

    final cardNumberField = find.byType(TextField).at(1);
    await tester.enterText(cardNumberField, '41111111111111111');
    await tester.pump();

    final textField = tester.widget<TextField>(cardNumberField);
    expect(textField.controller!.text, '4111 1111 1111 1111');
  });
}
