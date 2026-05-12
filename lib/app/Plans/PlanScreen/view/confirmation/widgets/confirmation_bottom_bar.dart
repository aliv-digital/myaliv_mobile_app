import 'package:flutter/material.dart';

class ConfirmationBottomBar extends StatelessWidget {
  final String totalText;
  final String vatLabel;
  final bool enabled;
  final VoidCallback onContinue;

  const ConfirmationBottomBar({
    super.key,
    required this.totalText,
    required this.vatLabel,
    required this.enabled,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = enabled
        ? const Color(0xFF645D9C)
        : const Color(0xFFC8C5DA);
    final textColor = enabled
        ? const Color(0xFFF1F1F8)
        : const Color(0xFF707070);

    return Container(
      width: 390,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFFE1E1E1)),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  totalText,
                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 22,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  vatLabel,
                  style: const TextStyle(
                    color: Color(0xFF707070),
                    fontSize: 12,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: enabled ? onContinue : null,
            child: Container(
              width: 170,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: ShapeDecoration(
                color: buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Center(
                child: Text(
                  'continue',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
