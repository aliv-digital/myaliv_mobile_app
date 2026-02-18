import 'package:flutter/material.dart';
import '../theme/rev_confirmation_prepaid_theme.dart';

class RevBottomBar extends StatelessWidget {
  final String amountText;
  final VoidCallback onContinue;

  const RevBottomBar({
    super.key,
    required this.amountText,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            offset: Offset(0, -6),
            color: Color(0x14000000), // ✅ subtle top shadow like figma separation
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(amountText, style: RevConfirmationPrepaidTheme.bottomAmount),
                  const SizedBox(height: 2),
                  Text('vat inclusive', style: RevConfirmationPrepaidTheme.bottomVat),
                ],
              ),
            ),
            SizedBox(
              width: 200, // ✅ closer to figma
              height: 44,
              child: InkWell(
                onTap: onContinue,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: RevConfirmationPrepaidTheme.continueBtnBg,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text('continue', style: RevConfirmationPrepaidTheme.continueText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
