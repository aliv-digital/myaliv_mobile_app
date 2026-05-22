import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/widgets/cards/saved_card_brand_box.dart';

enum CardBrand { visa, mastercard, unknown }

class SavedCardsRadioList extends StatelessWidget {
  final List<SavedCardModel> cards;
  final String? selectedToken;
  final ValueChanged<SavedCardModel> onCardSelected;
  final CardBrand Function(SavedCardModel card)? brandResolver;
  final String? Function(SavedCardModel card)? expiryResolver;
  final double itemSpacing;
  final int? maxVisibleItems;
  final double tileHeight;

  // Optional visual overrides forwarded to each [SavedCardRadioTile] so callers
  // can match sibling tiles on the same screen.
  final double? tileRadius;
  final double? radioSize;
  final double? logoBoxWidth;
  final double? logoBoxHeight;
  final Color? unselectedRadioFill;

  const SavedCardsRadioList({
    super.key,
    required this.cards,
    required this.selectedToken,
    required this.onCardSelected,
    this.brandResolver,
    this.expiryResolver,
    this.itemSpacing = 12,
    this.maxVisibleItems,
    this.tileHeight = 64,
    this.tileRadius,
    this.radioSize,
    this.logoBoxWidth,
    this.logoBoxHeight,
    this.unselectedRadioFill,
  });

  @override
  Widget build(BuildContext context) {
    final cap = maxVisibleItems;
    if (cap != null && cards.length > cap) {
      final boundedHeight = cap * tileHeight + (cap - 1) * itemSpacing;
      return SizedBox(
        height: boundedHeight,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          itemCount: cards.length,
          separatorBuilder: (_, _) => SizedBox(height: itemSpacing),
          itemBuilder: (_, i) => SavedCardRadioTile(
            card: cards[i],
            isSelected: cards[i].token == selectedToken,
            brand: brandResolver?.call(cards[i]) ?? CardBrand.unknown,
            expiry: expiryResolver?.call(cards[i]),
            onTap: () => onCardSelected(cards[i]),
            tileRadius: tileRadius,
            radioSize: radioSize,
            logoBoxWidth: logoBoxWidth,
            logoBoxHeight: logoBoxHeight,
            unselectedRadioFill: unselectedRadioFill,
          ),
        ),
      );
    }

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
            tileRadius: tileRadius,
            radioSize: radioSize,
            logoBoxWidth: logoBoxWidth,
            logoBoxHeight: logoBoxHeight,
            unselectedRadioFill: unselectedRadioFill,
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

  // Optional visual overrides — null = use defaults.
  final double? tileRadius;
  final double? radioSize;
  final double? logoBoxWidth;
  final double? logoBoxHeight;
  final Color? unselectedRadioFill;

  const SavedCardRadioTile({
    super.key,
    required this.card,
    required this.isSelected,
    required this.onTap,
    this.brand = CardBrand.unknown,
    this.expiry,
    this.tileRadius,
    this.radioSize,
    this.logoBoxWidth,
    this.logoBoxHeight,
    this.unselectedRadioFill,
  });

  static const _selectedBg = Color(0xFFEDEAF8);
  static const _selectedBorder = Color(0xFF645D9C);
  static const _selectedTextColor = Color(0xFF645D9C);
  static const _unselectedBg = Colors.white;
  static const _unselectedBorder = Color(0xFFE5E7EB);
  static const _unselectedTitleColor = Color(0xFF1A1A1A);
  static const _unselectedSubtitleColor = Color(0xFF707070);
  static const _unselectedRadioBorder = Color(0xFFCFCFCF);

  static const double _defaultTileRadius = 12;
  static const double _defaultLogoBoxWidth = 56;
  static const double _defaultLogoBoxHeight = 40;
  static const double _logoBoxRadius = 8;
  static const double _defaultRadioSize = 22;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius =
        BorderRadius.circular(tileRadius ?? _defaultTileRadius);

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
    return SavedCardBrandBox(
      brand: brand,
      width: logoBoxWidth ?? _defaultLogoBoxWidth,
      height: logoBoxHeight ?? _defaultLogoBoxHeight,
      cornerRadius: _logoBoxRadius,
    );
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
    final double r = radioSize ?? _defaultRadioSize;
    if (isSelected) {
      return Container(
        width: r,
        height: r,
        decoration: const BoxDecoration(
          color: _selectedBorder,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.check,
          size: r * 0.64,
          color: Colors.white,
        ),
      );
    }
    return Container(
      width: r,
      height: r,
      decoration: BoxDecoration(
        color: unselectedRadioFill,
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
