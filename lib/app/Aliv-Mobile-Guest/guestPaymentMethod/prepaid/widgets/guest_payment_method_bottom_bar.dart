import 'package:flutter/material.dart';
import '../theme/guest_payment_method_prepaid_theme.dart';

class GuestPaymentMethodBottomBar extends StatelessWidget {
  final String amountText;
  final String vatNote;
  final bool enabled;
  final bool loading;
  final VoidCallback onPayNow;

  const GuestPaymentMethodBottomBar({
    super.key,
    required this.amountText,
    required this.vatNote,
    required this.enabled,
    required this.loading,
    required this.onPayNow,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 72, // ✅ fixed height (important)
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(amountText,
                          style: GuestPaymentMethodPrepaidTheme.bottomAmount),
                      const SizedBox(height: 4),
                      Text(vatNote,
                          style: GuestPaymentMethodPrepaidTheme.bottomVat),
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: enabled && !loading ? onPayNow : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GuestPaymentMethodPrepaidTheme.payBtnBg,
                      disabledBackgroundColor: GuestPaymentMethodPrepaidTheme
                          .payBtnBg
                          .withValues(alpha: 0.45),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text('pay now',
                            style: GuestPaymentMethodPrepaidTheme.payNow),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
