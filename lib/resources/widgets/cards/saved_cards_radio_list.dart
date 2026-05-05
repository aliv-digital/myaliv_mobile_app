import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

enum CardBrand { visa, mastercard, unknown }

class SavedCardsRadioList extends StatelessWidget {
  final List<SavedCardModel> cards;
  final String? selectedToken;
  final ValueChanged<SavedCardModel> onCardSelected;
  final CardBrand Function(SavedCardModel card)? brandResolver;
  final String? Function(SavedCardModel card)? expiryResolver;
  final double itemSpacing;

  const SavedCardsRadioList({
    super.key,
    required this.cards,
    required this.selectedToken,
    required this.onCardSelected,
    this.brandResolver,
    this.expiryResolver,
    this.itemSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) SizedBox(height: itemSpacing),
          SavedCardRadioTile(
            card: cards[i],
            isSelected: cards[i].token == selectedToken,
            brand: brandResolver?.call(cards[i]) ?? CardBrand.unknown,
            expiry: expiryResolver?.call(cards[i]),
            onTap: () => onCardSelected(cards[i]),
          ),
        ],
      ],
    );
  }
}

class SavedCardRadioTile extends StatelessWidget {
  final SavedCardModel card;
  final bool isSelected;
  final CardBrand brand;
  final String? expiry;
  final VoidCallback onTap;

  const SavedCardRadioTile({
    super.key,
    required this.card,
    required this.isSelected,
    required this.onTap,
    this.brand = CardBrand.unknown,
    this.expiry,
  });

  static const _selectedBg = Color(0xFFEDEAF8);
  static const _selectedBorder = Color(0xFF645D9C);
  static const _selectedTextColor = Color(0xFF645D9C);
  static const _unselectedBg = Colors.white;
  static const _unselectedBorder = Color(0xFFE5E7EB);
  static const _unselectedTitleColor = Color(0xFF1A1A1A);
  static const _unselectedSubtitleColor = Color(0xFF707070);
  static const _unselectedRadioBorder = Color(0xFFCFCFCF);

  static const double _tileRadius = 12;
  static const double _logoBoxWidth = 56;
  static const double _logoBoxHeight = 40;
  static const double _logoBoxRadius = 8;
  static const double _radioSize = 22;
  static const double _checkIconSize = 14;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(_tileRadius);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected ? _selectedBg : _unselectedBg,
            borderRadius: radius,
            border: Border.all(
              color: isSelected ? _selectedBorder : _unselectedBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              _buildBrandBox(),
              const SizedBox(width: 12),
              Expanded(child: _buildTextBlock()),
              const SizedBox(width: 12),
              _buildRadio(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandBox() {
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

  Widget _buildTextBlock() {
    final String title = '${_brandLabel(brand)} ending in ${card.lastDigits}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isSelected ? _selectedTextColor : _unselectedTitleColor,
            fontSize: 16,
            fontFamily: AppConstants.defaultFontFamily,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        if (expiry != null) ...[
          const SizedBox(height: 2),
          Text(
            'expiry $expiry',
            style: TextStyle(
              color:
                  isSelected ? _selectedTextColor : _unselectedSubtitleColor,
              fontSize: 14,
              fontFamily: AppConstants.defaultFontFamily,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRadio() {
    if (isSelected) {
      return Container(
        width: _radioSize,
        height: _radioSize,
        decoration: const BoxDecoration(
          color: _selectedBorder,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.check,
          size: _checkIconSize,
          color: Colors.white,
        ),
      );
    }
    return Container(
      width: _radioSize,
      height: _radioSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _unselectedRadioBorder, width: 1.5),
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
