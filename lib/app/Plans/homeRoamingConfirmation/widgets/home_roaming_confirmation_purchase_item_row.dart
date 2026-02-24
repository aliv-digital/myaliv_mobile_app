import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../models/home_roaming_confirmation_models.dart';
import '../theme/home_roaming_confirmation_theme.dart';

class HomeRoamingConfirmationPurchaseItemRow extends StatelessWidget {
  final HomeRoamingConfirmationPurchaseLineItem item;
  final VoidCallback onRemove;

  const HomeRoamingConfirmationPurchaseItemRow({
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
                style: HomeRoamingConfirmationTheme.purchaseItemLabelTextStyle,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
              ),
              const SizedBox(
                height:
                    HomeRoamingConfirmationTheme.purchaseItemLabelToTitleGap,
              ),
              Text(
                item.title,
                style: HomeRoamingConfirmationTheme.purchaseItemTitleTextStyle,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
              ),
              const SizedBox(
                height:
                    HomeRoamingConfirmationTheme.purchaseItemTitleToSubtitleGap,
              ),
              Text(
                item.subtitle,
                style:
                    HomeRoamingConfirmationTheme.purchaseItemSubtitleTextStyle,
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
          padding: HomeRoamingConfirmationTheme.purchaseItemAmountChipPadding,
          decoration: BoxDecoration(
            color: HomeRoamingConfirmationTheme.purchaseItemAmountChipColor,
            borderRadius: BorderRadius.circular(
              HomeRoamingConfirmationTheme.purchaseItemAmountChipRadius,
            ),
          ),
          child: Text(
            '\$ ${item.price.toStringAsFixed(2)}',
            style: HomeRoamingConfirmationTheme.purchaseItemAmountChipTextStyle,
          ),
        ),

        const SizedBox(
          width: HomeRoamingConfirmationTheme.purchaseItemPriceToDeleteGap,
        ),

        // Trash
        InkWell(
          onTap: onRemove,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.all(
              HomeRoamingConfirmationTheme.purchaseItemDeleteTapPadding,
            ),
            child: _HomeRoamingConfirmationTrashIcon(),
          ),
        ),
      ],
    );
  }
}

class _HomeRoamingConfirmationTrashIcon extends StatelessWidget {
  const _HomeRoamingConfirmationTrashIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AssetConstant.trashIconSVG,
      width: HomeRoamingConfirmationTheme.purchaseItemDeleteIconSize,
      height: HomeRoamingConfirmationTheme.purchaseItemDeleteIconSize,
      fit: BoxFit.contain,
    );
  }
}
