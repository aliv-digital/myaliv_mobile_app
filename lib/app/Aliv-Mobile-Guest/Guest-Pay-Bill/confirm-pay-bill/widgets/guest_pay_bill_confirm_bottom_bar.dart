import 'package:flutter/material.dart';

import '../theme/guest_pay_bill_confirm_theme.dart';

class GuestPayBillConfirmBottomBar extends StatelessWidget {
  final double amount;
  final bool loading;
  final VoidCallback onPayNow;

  const GuestPayBillConfirmBottomBar({
    super.key,
    required this.amount,
    required this.loading,
    required this.onPayNow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: GuestPayBillConfirmTheme.bottomBarPadding,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0x11000000))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _money(amount),
                    style: GuestPayBillConfirmTheme.bottomAmount,
                  ),
                  const SizedBox(
                    height:
                        GuestPayBillConfirmTheme.bottomBarAmountToCaptionGap,
                  ),
                  Text(
                    GuestPayBillConfirmTheme.vatExclusiveLabel,
                    style: GuestPayBillConfirmTheme.bottomCaption,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: GuestPayBillConfirmTheme.bottomBarButtonHeight,
              width: GuestPayBillConfirmTheme.bottomBarButtonWidth,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GuestPayBillConfirmTheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      GuestPayBillConfirmTheme.bottomBarButtonRadius,
                    ),
                  ),
                ),
                onPressed: loading ? null : onPayNow,
                child: loading
                    ? const SizedBox(
                        width: GuestPayBillConfirmTheme.bottomBarLoadingSize,
                        height: GuestPayBillConfirmTheme.bottomBarLoadingSize,
                        child: CircularProgressIndicator(
                          strokeWidth:
                              GuestPayBillConfirmTheme.bottomBarLoadingStroke,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        GuestPayBillConfirmTheme.payNowLabel,
                        style: GuestPayBillConfirmTheme.bottomButton,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _money(double v) => '\$ ${v.toStringAsFixed(2)}';
}
