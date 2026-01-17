import 'package:flutter/material.dart';
import '../../theme/add_or_edit_cards_prepaid_theme.dart';

/// Confirmation bottom sheet (before deleting a saved card)
class ConfirmRemoveCardBottomSheet {
  static Future<bool?> show(
      BuildContext context, {
        String? titleOverride,
      }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // ✅ rounded top corners nicely
      barrierColor: Colors.black54,
      builder: (_) => _ConfirmRemoveCardSheetContent(
        title: titleOverride ?? 'are you sure you want to remove\nyour saved card?',
      ),
    );
  }
}

class _ConfirmRemoveCardSheetContent extends StatelessWidget {
  final String title;

  const _ConfirmRemoveCardSheetContent({required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
        decoration: const BoxDecoration(
          color: AddOrEditCardsPrepaidTheme.pageBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row: back arrow (left)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.arrow_back, color: AddOrEditCardsPrepaidTheme.textDark),
              ),
            ),

            const SizedBox(height: 18),

            // Center text (two lines)
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                height: 1.25,
                fontWeight: FontWeight.w500,
                color: AddOrEditCardsPrepaidTheme.textDark,
              ),
            ),

            const SizedBox(height: 22),

            // OK button
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AddOrEditCardsPrepaidTheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'ok',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
