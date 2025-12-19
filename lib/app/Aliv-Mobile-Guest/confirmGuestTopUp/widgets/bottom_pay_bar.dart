import 'package:flutter/material.dart';

class BottomPayBar extends StatelessWidget {
  const BottomPayBar({
    super.key,
    required this.amountText,
    required this.onPayNow,
    this.isLoading = false,
    this.buttonText = 'pay now',
    this.backgroundColor = Colors.white,
    this.buttonColor = const Color(0xFF6B63A7),
  });

  final String amountText;
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
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
                    const SizedBox(height: 4),
                    const Text(
                      'vat exclusive',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w200,
                        color: Color(0xFF6D6D6D),
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              // Right pill button
              SizedBox(
                height: 40,
                width: 169, // screenshot এর মতো বড় pill look
                child: ElevatedButton(
                  onPressed: isLoading ? null : onPayNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    disabledBackgroundColor: buttonColor.withOpacity(0.7),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: isLoading ? const SizedBox(
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
    );
  }
}
