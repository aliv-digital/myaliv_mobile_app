import 'package:flutter/material.dart';
import '../../theme/add_or_edit_cards_prepaid_theme.dart';

class SaveCardPrimaryButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool loading;

  const SaveCardPrimaryButton({
    super.key,
    required this.onTap,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AddOrEditCardsPrepaidTheme.primary,
          disabledBackgroundColor: AddOrEditCardsPrepaidTheme.primary.withOpacity(0.45),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: loading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Text(
          'save card',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
