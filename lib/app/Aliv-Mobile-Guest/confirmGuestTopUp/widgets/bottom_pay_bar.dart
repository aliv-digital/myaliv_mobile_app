import 'package:flutter/material.dart';
import '../theme/theme.dart';

class BottomPayBar extends StatelessWidget {
  const BottomPayBar({
    super.key,
    required this.amountText,
    required this.onPayNow,
    this.isLoading = false,
    this.buttonText = TopUpConfirmTheme.payNowLabel,
    this.isVatExclusive = false,
    this.backgroundColor = TopUpConfirmTheme.payBarBackgroundColor,
    this.buttonColor = TopUpConfirmTheme.payBarButtonColor,
  });

  final String amountText;
  final bool isVatExclusive;
  final VoidCallback onPayNow;

  final bool isLoading;
  final String buttonText;

  final Color backgroundColor;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    final numericAmount = amountText.replaceAll('\$', '').trim();

    return Material(
      color: backgroundColor,
      elevation: TopUpConfirmTheme.payBarElevation,
      shadowColor: TopUpConfirmTheme.payBarShadowColor,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: TopUpConfirmTheme.payBarHeight,
          child: Padding(
            padding: TopUpConfirmTheme.payBarPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '\$',
                              style: TopUpConfirmTheme.payBarCurrency,
                            ),
                            TextSpan(
                              text: ' $numericAmount',
                              style: TopUpConfirmTheme.payBarAmount,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                          height: TopUpConfirmTheme.payBarAmountToVatGap),
                      Text(
                        isVatExclusive
                            ? TopUpConfirmTheme.vatExclusiveLabel
                            : TopUpConfirmTheme.vatInclusiveLabel,
                        style: TopUpConfirmTheme.payBarVat,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: TopUpConfirmTheme.payBarSectionGap),
                SizedBox(
                  height: TopUpConfirmTheme.payBarButtonHeight,
                  width: TopUpConfirmTheme.payBarButtonWidth,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onPayNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      disabledBackgroundColor: buttonColor.withValues(
                        alpha: TopUpConfirmTheme.payBarDisabledOpacity,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          TopUpConfirmTheme.payBarButtonRadius,
                        ),
                      ),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: TopUpConfirmTheme.payBarLoadingSize,
                            width: TopUpConfirmTheme.payBarLoadingSize,
                            child: CircularProgressIndicator(
                              strokeWidth:
                                  TopUpConfirmTheme.payBarLoadingStroke,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            buttonText,
                            style: TopUpConfirmTheme.payBarButton,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
