import 'package:flutter/material.dart';
import '../theme/rev_payment_method_prepaid_theme.dart';

class RevPaymentMethodBottomBar extends StatelessWidget {
  final String amountText;
  final String vatNote;
  final bool enabled;
  final bool loading;
  final VoidCallback onPayNow;

  const RevPaymentMethodBottomBar({
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
        height: 80, // ✅ fixed height (important)
        child: DecoratedBox(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: const Color(0xFFE1E1E1),
              ),
            ),
          ),          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // // Text(amountText, style: RevPaymentMethodPrepaidTheme.bottomAmount),
                      // const SizedBox(height: 4),
                      // Text(vatNote, style: RevPaymentMethodPrepaidTheme.bottomVat),
                      Text(
                        '\$ 200.00',
                        style: TextStyle(
                          color: const Color(0xFF222222),
                          fontSize: 22,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'vat inclusive',
                        style: TextStyle(
                          color: const Color(0xFF707070),
                          fontSize: 12,
                          fontFamily: 'CircularPro',
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: enabled && !loading ? onPayNow : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RevPaymentMethodPrepaidTheme.payBtnBg,
                      disabledBackgroundColor:
                      RevPaymentMethodPrepaidTheme.payBtnBg.withValues(alpha: 0.45),
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
                        :Text(
                      'pay now',
                      style: TextStyle(
                        color: const Color(0xFFF1F1F8),
                        fontSize: 13,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w500,
                      ),
                    )
                    // Text('pay now', style: RevPaymentMethodPrepaidTheme.payNow),
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
