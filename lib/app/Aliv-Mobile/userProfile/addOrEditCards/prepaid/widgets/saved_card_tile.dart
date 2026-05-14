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

  static const double _logoBoxWidth = 56;
  static const double _logoBoxHeight = 40;
  static const double _logoBoxRadius = 8;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _logoBoxWidth,
      height: _logoBoxHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_logoBoxRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: _buildBrandArtwork(),
      ),
    );
  }

  Widget _buildBrandArtwork() {
    switch (brand) {
      case CardBrand.visa:
        return SvgPicture.asset(AssetConstant.visaCardSVG, fit: BoxFit.contain);
      case CardBrand.mastercard:
        return SvgPicture.asset(
          AssetConstant.masterCardSVG,
          fit: BoxFit.contain,
        );
      case CardBrand.unknown:
        return const Icon(
          Icons.credit_card,
          size: 22,
          color: Color(0xFF707070),
        );
    }
  }
}
