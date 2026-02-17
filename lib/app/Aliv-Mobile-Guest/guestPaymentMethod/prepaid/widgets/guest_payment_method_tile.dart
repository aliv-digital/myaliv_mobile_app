import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/guest_payment_method_prepaid_theme.dart';

class GuestPaymentMethodTile extends StatelessWidget {
  final String logoSvgAsset;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool showLogo;
  final TextStyle? titleStyle;
  final EdgeInsetsGeometry? tilePadding;
  final double indicatorSize;
  final double textToIndicatorGap;

  const GuestPaymentMethodTile({
    super.key,
    required this.logoSvgAsset,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
    this.showLogo = true,
    this.titleStyle,
    this.tilePadding,
    this.indicatorSize = 18,
    this.textToIndicatorGap =
        GuestPaymentMethodPrepaidTheme.savedCardTextToIndicatorGap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? GuestPaymentMethodPrepaidTheme.selectedCardBorder
        : GuestPaymentMethodPrepaidTheme.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding:
            tilePadding ?? GuestPaymentMethodPrepaidTheme.savedCardTilePadding,
        decoration: BoxDecoration(
          color: selected
              ? GuestPaymentMethodPrepaidTheme.selectedCardBg
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            if (showLogo) ...[
              SizedBox(
                width: GuestPaymentMethodPrepaidTheme.savedCardLogoWidth,
                height: GuestPaymentMethodPrepaidTheme.savedCardLogoHeight,
                child: SvgPicture.asset(
                  logoSvgAsset, // ✅ তুমি পরে path set করবে
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: titleStyle ??
                        (selected
                            ? GuestPaymentMethodPrepaidTheme.selectedMethodTitle
                            : GuestPaymentMethodPrepaidTheme.methodTitle),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: selected
                          ? GuestPaymentMethodPrepaidTheme
                              .selectedMethodSubtitle
                          : GuestPaymentMethodPrepaidTheme.methodSubtitle,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: textToIndicatorGap),
            selected
                ? Container(
                    width: GuestPaymentMethodPrepaidTheme.selectedIndicatorSize,
                    height:
                        GuestPaymentMethodPrepaidTheme.selectedIndicatorSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: GuestPaymentMethodPrepaidTheme
                          .selectedIndicatorFillColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: GuestPaymentMethodPrepaidTheme
                            .selectedIndicatorBorderColor,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: GuestPaymentMethodPrepaidTheme
                          .selectedIndicatorCheckSize,
                    ),
                  )
                : Container(
                    width: indicatorSize,
                    height: indicatorSize,
                    decoration: BoxDecoration(
                      color: GuestPaymentMethodPrepaidTheme
                          .unselectedIndicatorColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: GuestPaymentMethodPrepaidTheme
                            .unselectedIndicatorBorderColor,
                        width: 1,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
