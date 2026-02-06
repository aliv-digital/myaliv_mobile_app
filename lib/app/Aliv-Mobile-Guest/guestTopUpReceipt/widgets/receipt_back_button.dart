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
      height: 46,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEDEDF3),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: Text(
          text,
          style: ReceiptTheme.backButtonText,
        ),
      ),
    );
  }
}
