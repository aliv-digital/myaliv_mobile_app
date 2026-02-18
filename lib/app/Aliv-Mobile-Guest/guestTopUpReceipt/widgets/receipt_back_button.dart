import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/guestTopUpReceipt/theme/theme.dart';

class ReceiptBackButton extends StatelessWidget {
  const ReceiptBackButton({
    super.key,
    required this.onTap,
    this.text = 'back to home page',
  });

  final VoidCallback onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ReceiptTheme.backButtonHeight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: ReceiptTheme.backButtonWidth,
        ),
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: ReceiptTheme.backButtonBackgroundColor,
            elevation: 0,
            minimumSize: const Size(
              ReceiptTheme.backButtonWidth,
              ReceiptTheme.backButtonHeight,
            ),
            padding: ReceiptTheme.backButtonPadding,
            side: BorderSide(
              width: 1,
              color: ReceiptTheme.backButtonBorderColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(ReceiptTheme.backButtonRadius),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: ReceiptTheme.backButtonText,
          ),
        ),
      ),
    );
  }
}
