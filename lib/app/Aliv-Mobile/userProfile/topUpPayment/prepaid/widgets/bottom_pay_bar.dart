import 'package:flutter/material.dart';
import '../theme/top_up_payment_prepaid_theme.dart';

class BottomPayBar extends StatelessWidget {
  final double total;
  final bool vatInclusive;
  final bool isLoading;
  final VoidCallback onPayNow;

  const BottomPayBar({
    super.key,
    required this.total,
    required this.vatInclusive,
    required this.isLoading,
    required this.onPayNow,
  });

  String _money(double v) => '\$ ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _money(total),
                    style: TopUpPaymentPrepaidTheme.bottomPrice(context),
                  ),
                  Text(
                    'vat exclusive',
                    style: TopUpPaymentPrepaidTheme.bodySm(context),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              width: 170,
              child: ElevatedButton(
                onPressed: isLoading ? null : onPayNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TopUpPaymentPrepaidTheme.primary,
                  disabledBackgroundColor: TopUpPaymentPrepaidTheme.primary
                      .withValues(alpha: 0.55),
                  elevation: 0,
                  shape: const StadiumBorder(),
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
                        'pay now',
                        style: TopUpPaymentPrepaidTheme.buttonText(context),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
