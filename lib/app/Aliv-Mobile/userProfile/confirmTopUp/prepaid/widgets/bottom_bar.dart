import 'package:flutter/material.dart';

import '../theme/confirm_top_up_prepaid_theme.dart';

class ConfirmTopUpBottomBar extends StatelessWidget {
  final double total;
  final bool vatExclusive;
  final bool isLoading;
  final VoidCallback onContinue;

  const ConfirmTopUpBottomBar({
    super.key,
    required this.total,
    required this.vatExclusive,
    required this.isLoading,
    required this.onContinue,
  });

  String _money(double v) => '\$ ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(29, 10, 29, 12),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _money(total),
                    style: ConfirmTopUpPrepaidTheme.bottomPrice(context),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    vatExclusive ? 'vat exclusive' : 'vat inclusive',
                    style: TextStyle(
                      color: const Color(0xFF707070),
                      fontSize: 12,
                      fontFamily: 'Circular Pro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              width: 168,
              child: ElevatedButton(
                onPressed: isLoading ? null : onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ConfirmTopUpPrepaidTheme.primary,
                  disabledBackgroundColor: ConfirmTopUpPrepaidTheme.primary
                      .withValues(alpha: 0.5),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'continue',
                        style: ConfirmTopUpPrepaidTheme.buttonText(context),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
