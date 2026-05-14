import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../model/add_or_edit_cards_prepaid_models.dart';
import '../theme/add_or_edit_cards_prepaid_theme.dart';

class SavedCardTile extends StatelessWidget {
  final SavedCard card;
  final bool deleting;
  final VoidCallback onDelete;

  const SavedCardTile({
    super.key,
    required this.card,
    required this.deleting,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // ✅ Inner tile style (border + radius)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      child: Row(
        children: [
          _BrandLogo(brand: card.brand),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_brandLabel(card.brand)} ending in ${card.ending}',
                  style: AddOrEditCardsPrepaidTheme.cardTitle(),
                ),
                if (card.expiry.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    'expiry ${card.expiry}',
                    style: AddOrEditCardsPrepaidTheme.cardSubTitle(),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ✅ Delete area aligned like screenshot (no IconButton extra padding)
          deleting
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onDelete,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset('assets/icons/delete.svg'),
            ),
          ),
        ],
      ),
    );
  }

  String _brandLabel(CardBrand brand) {
    switch (brand) {
      case CardBrand.visa:
        return 'visa';
      case CardBrand.mastercard:
        return 'mastercard';
      case CardBrand.unknown:
        return 'card';
    }
  }
}

class _BrandLogo extends StatelessWidget {
  final CardBrand brand;
  const _BrandLogo({required this.brand});

  @override
  Widget build(BuildContext context) {
    final isVisa = brand == CardBrand.visa;

    return Container(
      // width: 52,
      // height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(8),
        // border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: SvgPicture.asset(
        isVisa ? AssetConstant.visaCardSVG : AssetConstant.masterCardSVG,
        // keep natural size as figma look
      ),
    );
  }
}
