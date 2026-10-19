import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/cards/saved_cards_radio_list.dart';

/// White rounded card with a subtle drop-shadow that frames the brand
/// artwork for a saved card (visa / mastercard / generic credit card).
///
/// Used by every saved-card tile in the app so the "card initial icon" reads
/// the same on every payment screen.
class SavedCardBrandBox extends StatelessWidget {
  final CardBrand brand;
  final double width;
  final double height;
  final double cornerRadius;
  final EdgeInsets artworkPadding;

  const SavedCardBrandBox({
    super.key,
    this.brand = CardBrand.unknown,
    this.width = 46,
    this.height = 32,
    this.cornerRadius = 8,
    this.artworkPadding = const EdgeInsets.all(6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cornerRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Padding(padding: artworkPadding, child: _buildArtwork()),
    );
  }

  Widget _buildArtwork() {
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
