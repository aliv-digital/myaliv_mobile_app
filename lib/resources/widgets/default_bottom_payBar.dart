import 'package:flutter/material.dart';

class DefaultBottomPayBar extends StatelessWidget {
  const DefaultBottomPayBar({
    super.key,
    required this.amountText,
    required this.onPayNow,
    this.isLoading = false,
    this.isButtonEnabled = true,
    this.buttonText = 'pay now',
    this.isVatExclusive = false,
    this.backgroundColor = Colors.white,
    this.buttonColor = const Color(0xFF6B63A7),
    this.disabledButtonColor,
  });

  final String amountText;
  final bool isVatExclusive;
  final VoidCallback onPayNow;

  final bool isLoading;
  final bool isButtonEnabled;
  final String buttonText;

  final Color backgroundColor;
  final Color buttonColor;
  final Color? disabledButtonColor;

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
                        style: const TextStyle(
                          fontSize: 22,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111),
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isVatExclusive ? 'no vat applied' : 'vat inclusive',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6D6D6D),
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Right pill button
                SizedBox(
                  height: 40,
                  width: 169,
                  child: ElevatedButton(
                    onPressed: (isLoading || !isButtonEnabled) ? null : onPayNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      disabledBackgroundColor: disabledButtonColor ??
                          buttonColor.withValues(alpha: 0.45),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontFamily: 'CircularPro',
                              fontWeight: FontWeight.w500,
                            ),
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
