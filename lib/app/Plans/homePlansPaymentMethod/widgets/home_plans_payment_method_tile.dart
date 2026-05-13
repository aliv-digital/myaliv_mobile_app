import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/home_plans_payment_method_theme.dart';

class HomePlansPaymentMethodTile extends StatelessWidget {
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

  const HomePlansPaymentMethodTile({
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
        HomePlansPaymentMethodTheme.savedCardTextToIndicatorGap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? HomePlansPaymentMethodTheme.selectedCardBorder
        : HomePlansPaymentMethodTheme.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding:
            tilePadding ?? HomePlansPaymentMethodTheme.savedCardTilePadding,
        decoration: BoxDecoration(
          color: selected
              ? HomePlansPaymentMethodTheme.selectedCardBg
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            if (showLogo) ...[
              SizedBox(
                width: HomePlansPaymentMethodTheme.savedCardLogoWidth,
                height: HomePlansPaymentMethodTheme.savedCardLogoHeight,
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
                    style:
                        titleStyle ??
                        (selected
                            ? HomePlansPaymentMethodTheme.selectedMethodTitle
                            : HomePlansPaymentMethodTheme.methodTitle),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: selected
                          ? HomePlansPaymentMethodTheme.selectedMethodSubtitle
                          : HomePlansPaymentMethodTheme.methodSubtitle,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: textToIndicatorGap),
            selected
                ? Container(
                    width: HomePlansPaymentMethodTheme.selectedIndicatorSize,
                    height: HomePlansPaymentMethodTheme.selectedIndicatorSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: HomePlansPaymentMethodTheme
                          .selectedIndicatorFillColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: HomePlansPaymentMethodTheme
                            .selectedIndicatorBorderColor,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: HomePlansPaymentMethodTheme
                          .selectedIndicatorCheckSize,
                    ),
                  )
                : Container(
                    width: indicatorSize,
                    height: indicatorSize,
                    decoration: BoxDecoration(
                      color:
                          HomePlansPaymentMethodTheme.unselectedIndicatorColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: HomePlansPaymentMethodTheme
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
