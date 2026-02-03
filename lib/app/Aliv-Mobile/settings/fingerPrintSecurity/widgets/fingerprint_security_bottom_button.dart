import 'package:flutter/material.dart';
import '../theme/fingerprint_security_theme.dart';

class FingerPrintSecurityBottomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const FingerPrintSecurityBottomButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: SizedBox(
          height: FingerPrintSecurityTheme.bottomButtonHeight,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: FingerPrintSecurityTheme.bottomButtonBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  FingerPrintSecurityTheme.bottomButtonRadius,
                ),
              ),
              elevation: 0,
            ),
            onPressed: onTap,
            child: Text(text, style: FingerPrintSecurityTheme.bottomButtonText),
          ),
        ),
      ),
    );
  }
}
