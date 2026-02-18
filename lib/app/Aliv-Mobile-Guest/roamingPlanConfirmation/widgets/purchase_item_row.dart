import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../models/roaming_plan_confirmation_models.dart';
import '../theme/roaming_plan_confirmation_theme.dart';

class PurchaseItemRow extends StatelessWidget {
  final PurchaseLineItem item;
  final VoidCallback onRemove;

  const PurchaseItemRow({
    super.key,
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left texts
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: RoamingPlanConfirmationTheme.purchaseItemLabelTextStyle,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
              ),
              const SizedBox(
                height:
                    RoamingPlanConfirmationTheme.purchaseItemLabelToTitleGap,
              ),
              Text(
                item.title,
                style: RoamingPlanConfirmationTheme.purchaseItemTitleTextStyle,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
              ),
              const SizedBox(
                height:
                    RoamingPlanConfirmationTheme.purchaseItemTitleToSubtitleGap,
              ),
              Text(
                item.subtitle,
                style:
                    RoamingPlanConfirmationTheme.purchaseItemSubtitleTextStyle,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
              ),
            ],
          ),
        ),

        // Price pill
        Container(
          padding: RoamingPlanConfirmationTheme.purchaseItemAmountChipPadding,
          decoration: BoxDecoration(
            color: RoamingPlanConfirmationTheme.purchaseItemAmountChipColor,
            borderRadius: BorderRadius.circular(
              RoamingPlanConfirmationTheme.purchaseItemAmountChipRadius,
            ),
          ),
          child: Text(
            '\$ ${item.price.toStringAsFixed(2)}',
            style: RoamingPlanConfirmationTheme.purchaseItemAmountChipTextStyle,
          ),
        ),

        const SizedBox(
          width: RoamingPlanConfirmationTheme.purchaseItemPriceToDeleteGap,
        ),

        // Trash
        InkWell(
          onTap: onRemove,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.all(
              RoamingPlanConfirmationTheme.purchaseItemDeleteTapPadding,
            ),
            child: _TrashIcon(),
          ),
        ),
      ],
    );
  }
}

class _TrashIcon extends StatelessWidget {
  const _TrashIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AssetConstant.trashIconSVG,
      width: RoamingPlanConfirmationTheme.purchaseItemDeleteIconSize,
      height: RoamingPlanConfirmationTheme.purchaseItemDeleteIconSize,
      fit: BoxFit.contain,
    );
  }
}
