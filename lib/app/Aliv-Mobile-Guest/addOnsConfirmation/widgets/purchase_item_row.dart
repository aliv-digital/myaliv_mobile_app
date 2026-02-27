import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../models/add_ons_confirmation_models.dart';
import '../theme/add_ons_confirmation_theme.dart';

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
                style: AddOnsConfirmationTheme.purchaseItemLabelTextStyle,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
              ),
              const SizedBox(
                height:
                    AddOnsConfirmationTheme.purchaseItemLabelToTitleGap,
              ),
              Text(
                item.title,
                style: AddOnsConfirmationTheme.purchaseItemTitleTextStyle,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
              ),
              const SizedBox(
                height:
                    AddOnsConfirmationTheme.purchaseItemTitleToSubtitleGap,
              ),
              Text(
                item.subtitle,
                style:
                    AddOnsConfirmationTheme.purchaseItemSubtitleTextStyle,
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
          padding: AddOnsConfirmationTheme.purchaseItemAmountChipPadding,
          decoration: BoxDecoration(
            color: AddOnsConfirmationTheme.purchaseItemAmountChipColor,
            borderRadius: BorderRadius.circular(
              AddOnsConfirmationTheme.purchaseItemAmountChipRadius,
            ),
          ),
          child: Text(
            '\$ ${item.price.toStringAsFixed(2)}',
            style: AddOnsConfirmationTheme.purchaseItemAmountChipTextStyle,
          ),
        ),

        const SizedBox(
          width: AddOnsConfirmationTheme.purchaseItemPriceToDeleteGap,
        ),

        // Trash
        InkWell(
          onTap: onRemove,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.all(
              AddOnsConfirmationTheme.purchaseItemDeleteTapPadding,
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
      width: AddOnsConfirmationTheme.purchaseItemDeleteIconSize,
      height: AddOnsConfirmationTheme.purchaseItemDeleteIconSize,
      fit: BoxFit.contain,
    );
  }
}
