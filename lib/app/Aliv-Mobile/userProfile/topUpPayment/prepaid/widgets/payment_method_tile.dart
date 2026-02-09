import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/top_up_payment_prepaid_theme.dart';

class PaymentMethodTile extends StatelessWidget {
  final String logoAsset;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentMethodTile({
    super.key,
    required this.logoAsset,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? TopUpPaymentPrepaidTheme.primary.withValues(alpha: 0.65)
        : TopUpPaymentPrepaidTheme.border;

    final bg = isSelected ? TopUpPaymentPrepaidTheme.tileBg : Colors.white;

    // ✅ Figma-like selected text coloring
    final titleStyle = TopUpPaymentPrepaidTheme.bodyMd(context).copyWith(
      color: isSelected
          ? TopUpPaymentPrepaidTheme.primary
          : Color(0xFF222222),
      fontWeight: FontWeight.w700,
      fontSize: 14,
      fontFamily: 'Circular Pro',
      height: 1.43,

    );

    final subtitleStyle = TopUpPaymentPrepaidTheme.bodySm(context).copyWith(
      color: isSelected
          ?  Color(0xCC5146A8)
          : const Color(0xFF707070),
      fontSize: 14,
      fontFamily: 'Circular Pro',
      fontWeight: FontWeight.w500,
      height: 1.43,    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              height: 32,
              width: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SvgPicture.asset(
                logoAsset,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle),
                  const SizedBox(height: 4),
                  Text(subtitle, style: subtitleStyle),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _RightIndicator(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _RightIndicator extends StatelessWidget {
  final bool isSelected;
  const _RightIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return Container(
        height: 18,
        width: 18,
        decoration: const BoxDecoration(
          color: TopUpPaymentPrepaidTheme.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 12, color: Colors.white),
      );
    }

    return Container(
      height: 18,
      width: 18,
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
    );
  }
}
