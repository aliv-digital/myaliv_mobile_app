import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/makePayment/payment/postpaid/theme/make_payment_postpaid_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/resources/widgets/cards/payment_option_tile.dart';
import 'package:myaliv_mobile_app/resources/widgets/cards/saved_cards_radio_list.dart';

void main() {
  testWidgets('postpaid add-card content follows Figma spacing', (
    tester,
  ) async {
    const savedTileKey = Key('saved-card-tile');
    const addCardTileKey = Key('add-card-tile');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 314,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SavedCardRadioTile(
                    key: savedTileKey,
                    card: const SavedCardModel(token: 'token', number: '*0005'),
                    isSelected: false,
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  PaymentOptionTile(
                    key: addCardTileKey,
                    title: 'pay with card',
                    selected: false,
                    onTap: () {},
                    contentPadding: MakePaymentPostPaidTheme
                        .paymentMethodPayWithCardRowPadding,
                    leadingWidth: MakePaymentPostPaidTheme
                        .paymentMethodPayWithCardLeadingWidth,
                    leadingHeight: MakePaymentPostPaidTheme
                        .paymentMethodPayWithCardLeadingHeight,
                    leadingToTextGap: MakePaymentPostPaidTheme
                        .paymentMethodPayWithCardLeadingToTextGap,
                    unselectedRadioFill: MakePaymentPostPaidTheme
                        .paymentMethodUnselectedIndicatorColor,
                    leading: const Icon(Icons.add, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final savedTileRect = tester.getRect(find.byKey(savedTileKey));
    final addCardTileRect = tester.getRect(find.byKey(addCardTileKey));
    final savedIconCenter = tester.getCenter(find.byIcon(Icons.credit_card));
    final addIconCenter = tester.getCenter(find.byIcon(Icons.add));
    final addTextLeft = tester.getTopLeft(find.text('pay with card'));
    final addIconRight = tester.getTopRight(find.byIcon(Icons.add));

    expect(addCardTileRect.height, savedTileRect.height);
    expect(
      addTextLeft.dx - addIconRight.dx,
      MakePaymentPostPaidTheme.paymentMethodPayWithCardLeadingToTextGap,
    );
    expect(
      addIconCenter.dy - addCardTileRect.top,
      savedIconCenter.dy - savedTileRect.top,
    );
    expect(
      tester.getCenter(find.text('pay with card')).dy - addCardTileRect.top,
      tester.getCenter(find.text('card ending in 0005')).dy - savedTileRect.top,
    );
  });
}
