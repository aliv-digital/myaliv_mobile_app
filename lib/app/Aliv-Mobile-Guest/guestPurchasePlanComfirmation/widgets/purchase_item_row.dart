import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../models/guest_purchase_plan_confirmation_models.dart';
import '../theme/guest_purchase_plan_confirmation_theme.dart';

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
                style: GuestPurchasePlanConfirmationTheme
                    .purchaseItemLabelTextStyle,
              ),
              const SizedBox(
                height: GuestPurchasePlanConfirmationTheme
                    .purchaseItemLabelToTitleGap,
              ),
              Text(
                item.title,
                style: GuestPurchasePlanConfirmationTheme
                    .purchaseItemTitleTextStyle,
              ),
              const SizedBox(
                height: GuestPurchasePlanConfirmationTheme
                    .purchaseItemTitleToSubtitleGap,
              ),
              Text(
                item.subtitle,
                style: GuestPurchasePlanConfirmationTheme
                    .purchaseItemSubtitleTextStyle,
              ),
            ],
          ),
        ),

        // Price pill
        Container(
          padding:
              GuestPurchasePlanConfirmationTheme.purchaseItemAmountChipPadding,
          decoration: BoxDecoration(
            color:
                GuestPurchasePlanConfirmationTheme.purchaseItemAmountChipColor,
            borderRadius: BorderRadius.circular(
              GuestPurchasePlanConfirmationTheme.purchaseItemAmountChipRadius,
            ),
          ),
          child: Text(
            '\$ ${item.price.toStringAsFixed(2)}',
            style: GuestPurchasePlanConfirmationTheme
                .purchaseItemAmountChipTextStyle,
          ),
        ),

        const SizedBox(
          width:
              GuestPurchasePlanConfirmationTheme.purchaseItemPriceToDeleteGap,
        ),

        // Trash
        InkWell(
          onTap: onRemove,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.all(
              GuestPurchasePlanConfirmationTheme.purchaseItemDeleteTapPadding,
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
      width: GuestPurchasePlanConfirmationTheme.purchaseItemDeleteIconSize,
      height: GuestPurchasePlanConfirmationTheme.purchaseItemDeleteIconSize,
      fit: BoxFit.contain,
    );
  }
}
