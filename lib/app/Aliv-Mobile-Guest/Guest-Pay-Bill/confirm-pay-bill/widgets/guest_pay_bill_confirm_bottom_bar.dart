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
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
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
                  Text(_money(amount), style: GuestPayBillConfirmTheme.bottomAmount()),
                  const SizedBox(height: 2),
                  Text('vat exclusive', style: GuestPayBillConfirmTheme.bottomCaption()),
                ],
              ),
            ),
            SizedBox(
              height: 40,
              width: 150,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GuestPayBillConfirmTheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                onPressed: loading ? null : onPayNow,
                child: loading ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'pay now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: GuestPayBillConfirmTheme.myFontFamily,
                    fontWeight: FontWeight.w500,
                  ),
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
