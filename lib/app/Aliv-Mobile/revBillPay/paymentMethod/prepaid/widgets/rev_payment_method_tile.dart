import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/widgets/cards/payment_method_icon.dart';
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
    final borderColor = selected
        ? RevPaymentMethodPrepaidTheme.selectedBorder
        : RevPaymentMethodPrepaidTheme.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: RevPaymentMethodPrepaidTheme.paymentTilePadding,
        decoration: BoxDecoration(
          color: selected
              ? RevPaymentMethodPrepaidTheme.selectedCardBg
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            // Previous artwork: SvgPicture.asset(logoSvgAsset).
            const PaymentMethodIcon.savedCard(),
            const SizedBox(
              width: RevPaymentMethodPrepaidTheme.paymentTileLogoToTextGap,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: selected
                        ? RevPaymentMethodPrepaidTheme.selectedMethodTitle
                        : RevPaymentMethodPrepaidTheme.methodTitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: selected
                        ? RevPaymentMethodPrepaidTheme.selectedMethodSubtitle
                        : RevPaymentMethodPrepaidTheme.methodSubtitle,
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: RevPaymentMethodPrepaidTheme.paymentTileTextToIndicatorGap,
            ),
            selected
                ? Container(
                    width: RevPaymentMethodPrepaidTheme.selectedIndicatorSize,
                    height: RevPaymentMethodPrepaidTheme.selectedIndicatorSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: RevPaymentMethodPrepaidTheme
                          .selectedIndicatorFillColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: RevPaymentMethodPrepaidTheme
                            .selectedIndicatorBorderColor,
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: RevPaymentMethodPrepaidTheme
                          .selectedIndicatorCheckSize,
                    ),
                  )
                : Container(
                    width: RevPaymentMethodPrepaidTheme.selectedIndicatorSize,
                    height: RevPaymentMethodPrepaidTheme.selectedIndicatorSize,
                    decoration: BoxDecoration(
                      color:
                          RevPaymentMethodPrepaidTheme.unselectedIndicatorColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: RevPaymentMethodPrepaidTheme
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
