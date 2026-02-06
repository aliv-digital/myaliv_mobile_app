import 'package:flutter/material.dart';
import '../theme/theme.dart';

class BottomPayBar extends StatelessWidget {
  const BottomPayBar({
    super.key,
    required this.amountText,
    required this.onPayNow,
    this.isLoading = false,
    this.buttonText = 'pay now',
    this.isVatExclusive = false,
    this.backgroundColor = Colors.white,
    this.buttonColor = const Color(0xFF655C9A),
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
    return Material(
      color: backgroundColor,
      elevation: 10,
      shadowColor: const Color(0x22000000),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 75,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left amount column
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        amountText,
                        style: TopUpConfirmTheme.payBarAmount,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isVatExclusive ? 'vat exclusive' : 'vat inclusive',
                        style: TopUpConfirmTheme.payBarVat,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Right pill button
                SizedBox(
                  height: 44,
                  width: 180,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onPayNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      disabledBackgroundColor: buttonColor.withValues(alpha: 0.7),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
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
