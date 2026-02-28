import 'package:flutter/material.dart';

class HomePlanPurchaseReceiptBackButton extends StatelessWidget {
  const HomePlanPurchaseReceiptBackButton({
    super.key,
    required this.onTap,
    this.text = 'back to home page',
  });

  final VoidCallback onTap;
  final String text;

  static const _purple = Color(0xFF655C9A);

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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: const Text(
          'back to home page',
          style: TextStyle(
              color: _purple,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: 'CircularPro'),
        ),
      ),
    );
  }
}
