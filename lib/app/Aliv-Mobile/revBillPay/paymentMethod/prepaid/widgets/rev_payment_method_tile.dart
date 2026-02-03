import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/rev_payment_method_prepaid_theme.dart';

class RevPaymentMethodTile extends StatelessWidget {
  final String logoSvgAsset;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const RevPaymentMethodTile({
    super.key,
    required this.logoSvgAsset,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
    selected ? RevPaymentMethodPrepaidTheme.selectedBorder : RevPaymentMethodPrepaidTheme.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              height: 22,
              child: SvgPicture.asset(
                logoSvgAsset, // ✅ তুমি পরে path set করবে
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: RevPaymentMethodPrepaidTheme.methodTitle),
                  const SizedBox(height: 4),
                  Text(subtitle, style: RevPaymentMethodPrepaidTheme.methodSubtitle),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 18,
              color: selected
                  ? RevPaymentMethodPrepaidTheme.selectedBorder
                  : RevPaymentMethodPrepaidTheme.border,
            ),
          ],
        ),
      ),
    );
  }
}
