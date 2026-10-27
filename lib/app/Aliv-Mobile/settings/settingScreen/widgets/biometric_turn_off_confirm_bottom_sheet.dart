import 'package:flutter/material.dart';

import '../theme/settings_theme.dart';

/// BottomSheet: confirm turning off a biometric login option.
/// - shows a back arrow, the confirmation message, and no / yes buttons
/// - returns true only when "yes" is tapped
class BiometricTurnOffConfirmBottomSheet extends StatelessWidget {
  const BiometricTurnOffConfirmBottomSheet({super.key, required this.message});

  final String message;

  static Future<bool> show(
    BuildContext context, {
    required String message,
  }) async {
    final res = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BiometricTurnOffConfirmBottomSheet(message: message),
    );

    return res ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: SettingsTheme.sheetBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: SettingsTheme.sheetMessage,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    label: 'no',
                    backgroundColor: Colors.white,
                    textColor: SettingsTheme.sheetPrimary,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SheetButton(
                    label: 'yes',
                    backgroundColor: SettingsTheme.sheetPrimary,
                    textColor: SettingsTheme.sheetPrimaryText,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: SettingsTheme.sheetButtonText.copyWith(color: textColor),
        ),
      ),
    );
  }
}
