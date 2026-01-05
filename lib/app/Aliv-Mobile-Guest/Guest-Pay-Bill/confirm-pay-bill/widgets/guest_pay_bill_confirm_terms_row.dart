import 'package:flutter/material.dart';
import '../theme/guest_pay_bill_confirm_theme.dart';

class GuestPayBillConfirmTermsRow extends StatelessWidget {
  final VoidCallback onTapTerms;

  const GuestPayBillConfirmTermsRow({
    super.key,
    required this.onTapTerms,
  });

  @override
  Widget build(BuildContext context) {
    const baseStyle = TextStyle(
      fontFamily: GuestPayBillConfirmTheme.myFontFamily,
      color: GuestPayBillConfirmTheme.textDark,
      fontSize: 14,
      height: 1.43,
      fontWeight: FontWeight.w500,
    );

    const linkStyle = TextStyle(
      color: GuestPayBillConfirmTheme.textDark,
      fontSize: 14,
      height: 1.43,
      fontFamily: GuestPayBillConfirmTheme.myFontFamily,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationThickness: 1.2,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: baseStyle,
            children: [
              const TextSpan(
                text: 'By pressing “pay now” you agree to the ',
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapTerms,
                  child: const Text(
                    'Terms &',
                    style: linkStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTapTerms,
          child: const Text(
            'Conditions.',
            style: linkStyle,
          ),
        ),
      ],
    );
  }
}
