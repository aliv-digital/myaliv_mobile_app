import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../models/home_plan_confirmation_models.dart';
import '../theme/home_plan_confirmation_theme.dart';

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
                item.label, // Resolved from plan type in the repository.
                style: HomePlanConfirmationTheme.purchaseItemLabelTextStyle,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
              ),
              const SizedBox(
                height: HomePlanConfirmationTheme.purchaseItemLabelToTitleGap,
              ),
              Text(
                item.title,
                style: HomePlanConfirmationTheme.purchaseItemTitleTextStyle,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
              ),
              const SizedBox(
                height:
                    HomePlanConfirmationTheme.purchaseItemTitleToSubtitleGap,
              ),
              Text(
                item.subtitle,
                style: HomePlanConfirmationTheme.purchaseItemSubtitleTextStyle,
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
          padding: HomePlanConfirmationTheme.purchaseItemAmountChipPadding,
          decoration: BoxDecoration(
            color: HomePlanConfirmationTheme.purchaseItemAmountChipColor,
            borderRadius: BorderRadius.circular(
              HomePlanConfirmationTheme.purchaseItemAmountChipRadius,
            ),
          ),
          child: Text(
            '\$ ${item.totalPrice.toStringAsFixed(2)}',
            style: HomePlanConfirmationTheme.purchaseItemAmountChipTextStyle,
          ),
        ),

        const SizedBox(
          width: HomePlanConfirmationTheme.purchaseItemPriceToDeleteGap,
        ),

        // Trash
        InkWell(
          onTap: onRemove,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.all(
              HomePlanConfirmationTheme.purchaseItemDeleteTapPadding,
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
      width: HomePlanConfirmationTheme.purchaseItemDeleteIconSize,
      height: HomePlanConfirmationTheme.purchaseItemDeleteIconSize,
      fit: BoxFit.contain,
    );
  }
}
