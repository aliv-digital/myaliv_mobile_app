import 'package:flutter/material.dart';
import '../theme/guest_purchase_plan_confirmation_theme.dart';

class TermsNotice extends StatelessWidget {
  final VoidCallback onTermsTap;

  const TermsNotice({
    super.key,
    required this.onTermsTap,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: GuestPurchasePlanConfirmationTheme.t(
          12,
          weight: FontWeight.w700,
          color: GuestPurchasePlanConfirmationTheme.textBlack,
          height: 1.25,
        ),
        children: [
          const TextSpan(text: 'By pressing “pay now” you agree to the '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: onTermsTap,
              child: Text(
                'Terms &\nConditions.',
                style: GuestPurchasePlanConfirmationTheme.t(
                  12,
                  weight: FontWeight.w900,
                  color: GuestPurchasePlanConfirmationTheme.textBlack,
                ).copyWith(decoration: TextDecoration.underline),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
