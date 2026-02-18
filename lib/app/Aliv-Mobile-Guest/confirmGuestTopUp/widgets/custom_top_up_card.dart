import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CustomTopUpCard extends StatelessWidget {
  final String title;
  final String phoneNumber;
  final double amount;

  const CustomTopUpCard({
    super.key,
    required this.title,
    required this.phoneNumber,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: TopUpConfirmTheme.customCardMargin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TopUpConfirmTheme.customCardRadius),
      ),
      elevation: TopUpConfirmTheme.customCardElevation,
      child: Padding(
        padding: TopUpConfirmTheme.customCardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TopUpConfirmTheme.customCardTitle,
                ),
                Text(
                  phoneNumber,
                  style: TopUpConfirmTheme.customCardPhone,
                ),
              ],
            ),
            const SizedBox(height: TopUpConfirmTheme.customCardGap),
            const Divider(color: TopUpConfirmTheme.customCardDividerColor),
            const SizedBox(height: TopUpConfirmTheme.customCardGap),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top-up amount',
                  style: TopUpConfirmTheme.customCardLabel,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: TopUpConfirmTheme.customCardAmountVerticalPadding,
                    horizontal:
                        TopUpConfirmTheme.customCardAmountHorizontalPadding,
                  ),
                  decoration: BoxDecoration(
                    color: TopUpConfirmTheme.customCardAmountBackground,
                    borderRadius: BorderRadius.circular(
                      TopUpConfirmTheme.customCardAmountRadius,
                    ),
                    border: Border.all(
                      color: TopUpConfirmTheme.customCardAmountBackground,
                    ),
                  ),
                  child: Text(
                    '\$${amount.toStringAsFixed(2)}',
                    style: TopUpConfirmTheme.customCardAmount,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
