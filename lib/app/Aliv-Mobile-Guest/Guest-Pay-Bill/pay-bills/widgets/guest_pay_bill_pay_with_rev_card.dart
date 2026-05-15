import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/Guest-Pay-Bill/pay-bills/theme/guest_pay_bill_theme.dart';

class GuestPayBillPayWithRevCard extends StatelessWidget {
  final VoidCallback onContinueToPay;

  const GuestPayBillPayWithRevCard({
    super.key,
    required this.onContinueToPay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: GuestPayBillTheme.payWithRevCardHorizontalPadding,
        vertical: GuestPayBillTheme.payWithRevCardVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: GuestPayBillTheme.payWithRevCardBg,
        borderRadius: BorderRadius.circular(
          GuestPayBillTheme.payWithRevCardRadius,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            GuestPayBillTheme.payWithRevImageAsset,
            width: GuestPayBillTheme.payWithRevImageWidth,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: GuestPayBillTheme.payWithRevImageToTitleGap),
          Text(
            GuestPayBillTheme.payWithRevTitle,
            style: GuestPayBillTheme.payWithRevTitleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: GuestPayBillTheme.payWithRevTitleToButtonGap),
          _ContinueToPayButton(onPressed: onContinueToPay),
        ],
      ),
    );
  }
}

class _ContinueToPayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ContinueToPayButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GuestPayBillTheme.payWithRevButtonHorizontalPadding,
      ),
      child: SizedBox(
        width: double.infinity,
        height: GuestPayBillTheme.payWithRevButtonHeight,
        child: Material(
          color: GuestPayBillTheme.submitButtonColor,
          borderRadius: BorderRadius.circular(
            GuestPayBillTheme.payWithRevButtonRadius,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(
              GuestPayBillTheme.payWithRevButtonRadius,
            ),
            onTap: onPressed,
            child: Center(
              child: Text(
                GuestPayBillTheme.payWithRevButtonLabel,
                style: GuestPayBillTheme.payWithRevButtonTextStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
