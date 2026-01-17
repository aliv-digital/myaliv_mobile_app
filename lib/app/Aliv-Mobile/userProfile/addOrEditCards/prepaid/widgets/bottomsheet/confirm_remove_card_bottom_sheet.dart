import 'package:flutter/material.dart';
import '../../theme/add_or_edit_cards_prepaid_theme.dart';

/// BottomSheet: Confirm remove saved card
/// - shows warning text + big OK button
/// - returns true if confirmed, else false
class RemoveSavedCardConfirmBottomSheet extends StatelessWidget {
  const RemoveSavedCardConfirmBottomSheet({super.key});

  static Future<bool> show(BuildContext context) async {
    final res = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // ✅ for rounded top card look
      builder: (_) => const RemoveSavedCardConfirmBottomSheet(),
    );

    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        // ✅ Rounded top sheet like screenshot
        decoration: const BoxDecoration(
          color: AddOrEditCardsPrepaidTheme.pageBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row: back arrow (left)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),

            const SizedBox(height: 14),

            // Message center
            const Text(
              'are you sure you want to remove\nyour saved card?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                //height: 1.25,
                fontWeight: FontWeight.w400,
                color: AddOrEditCardsPrepaidTheme.textDark,
                fontFamily: AddOrEditCardsPrepaidTheme.myFontFamily,
              ),
            ),

            const SizedBox(height: 22),

            // OK Button
            SizedBox(
              height: 52,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AddOrEditCardsPrepaidTheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'ok',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: AddOrEditCardsPrepaidTheme.myFontFamily,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
