import 'package:flutter/material.dart';

class NotAppToast {
  static void show(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);

    // আগের banner থাকলে remove
    messenger.hideCurrentMaterialBanner();

    messenger.showMaterialBanner(
      MaterialBanner(
        elevation: 0,
        backgroundColor: const Color(0xFF57C7B0), // screenshot-like green
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 16, color: Color(0xFF57C7B0)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: const [SizedBox.shrink()], // no action buttons
      ),
    );

    // auto dismiss
    Future.delayed(const Duration(seconds: 2), () {
      messenger.hideCurrentMaterialBanner();
    });
  }
}
