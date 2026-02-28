import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_routes.dart';

class PurchaseAddOnButton extends StatelessWidget {
  const PurchaseAddOnButton({super.key});

  static const Color purple = Color(0xFF645D9C);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: ElevatedButton(
          onPressed: () {
            // 🔥 purchase add-on
            context.push(AppRoutes.guestPurchasePlanAddOns);
          },
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
              color: const Color(0xFFF1F1F8),
              fontSize: 15,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
