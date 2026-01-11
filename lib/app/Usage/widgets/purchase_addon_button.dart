import 'package:flutter/material.dart';

class PurchaseAddOnButton extends StatelessWidget {
  const PurchaseAddOnButton({super.key});

  static const Color purple = Color(0xFF6C63A6);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: purple,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: const Text(
            'purchase an add-on',
            style: TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
