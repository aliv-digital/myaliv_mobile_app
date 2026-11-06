import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/widgets/cards/saved_card_brand_box.dart';
import 'package:myaliv_mobile_app/resources/widgets/cards/payment_method_icon.dart';

enum CardBrand { visa, mastercard, unknown }

class SavedCardsRadioList extends StatefulWidget {
  final List<SavedCardModel> cards;
  final String? selectedToken;
  final ValueChanged<SavedCardModel> onCardSelected;
  final CardBrand Function(SavedCardModel card)? brandResolver;
  final String? Function(SavedCardModel card)? expiryResolver;
  final double itemSpacing;
  final int? maxVisibleItems;
  final double tileHeight;
  final ScrollController? scrollController;
  final bool showScrollbar;
  final bool thumbVisibility;
  final double scrollbarThickness;
  final double scrollbarPadding;
  final double thumbHeight;
  final Color? thumbColor;

  // Optional visual overrides forwarded to each [SavedCardRadioTile] so callers
  // can match sibling tiles on the same screen.
  final double? tileRadius;
  final double? radioSize;
  final double? logoBoxWidth;
  final double? logoBoxHeight;
  final String? logoImageAsset;
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
    this.scrollController,
    this.showScrollbar = true,
    this.thumbVisibility = true,
    this.scrollbarThickness = 4,
    this.scrollbarPadding = 8,
    this.thumbHeight = 20,
    this.thumbColor,
    this.tileRadius,
    this.radioSize,
    this.logoBoxWidth,
    this.logoBoxHeight,
    this.logoImageAsset,
    this.unselectedRadioFill,
  });

  @override
  State<SavedCardsRadioList> createState() => _SavedCardsRadioListState();
}

class _SavedCardsRadioListState extends State<SavedCardsRadioList> {
  ScrollController? _internalController;

  ScrollController get _effectiveController {
    if (widget.scrollController != null) {
      return widget.scrollController!;
    }
    return _internalController ??= ScrollController();
  }

  @override
  void didUpdateWidget(SavedCardsRadioList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrollController != null && _internalController != null) {
      _internalController!.dispose();
      _internalController = null;
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cap = widget.maxVisibleItems;
    if (cap != null && widget.cards.length > cap) {
      final boundedHeight =
          cap * widget.tileHeight + (cap - 1) * widget.itemSpacing;
      final controller = _effectiveController;
      final list = ListView.separated(
        controller: controller,
        primary: false,
        padding: widget.scrollbarPadding > 0
            ? EdgeInsetsDirectional.only(end: widget.scrollbarPadding)
            : EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        itemCount: widget.cards.length,
        separatorBuilder: (_, _) => SizedBox(height: widget.itemSpacing),
        itemBuilder: (_, i) => SavedCardRadioTile(
          card: widget.cards[i],
          isSelected: widget.cards[i].token == widget.selectedToken,
          brand:
              widget.brandResolver?.call(widget.cards[i]) ?? CardBrand.unknown,
          expiry: widget.expiryResolver?.call(widget.cards[i]),
          onTap: () => widget.onCardSelected(widget.cards[i]),
          tileRadius: widget.tileRadius,
          radioSize: widget.radioSize,
          logoBoxWidth: widget.logoBoxWidth,
          logoBoxHeight: widget.logoBoxHeight,
          logoImageAsset: widget.logoImageAsset,
          unselectedRadioFill: widget.unselectedRadioFill,
        ),
      );

      final child = widget.showScrollbar && widget.thumbVisibility
          ? Stack(
              children: [
                Positioned.fill(child: list),
                PositionedDirectional(
                  top: 0,
                  bottom: 0,
                  end: 0,
                  child: SavedCardsScrollbarThumb(
                    controller: controller,
                    thickness: widget.scrollbarThickness,
                    thumbHeight: widget.thumbHeight,
                    thumbColor: widget.thumbColor,
                    trackHeight: boundedHeight,
                  ),
                ),
              ],
            )
          : list;

      return SizedBox(height: boundedHeight, child: child);
    }

    return Column(
      children: [
        for (var i = 0; i < widget.cards.length; i++) ...[
          if (i > 0) SizedBox(height: widget.itemSpacing),
          SavedCardRadioTile(
            card: widget.cards[i],
            isSelected: widget.cards[i].token == widget.selectedToken,
            brand:
                widget.brandResolver?.call(widget.cards[i]) ??
                CardBrand.unknown,
            expiry: widget.expiryResolver?.call(widget.cards[i]),
            onTap: () => widget.onCardSelected(widget.cards[i]),
            tileRadius: widget.tileRadius,
            radioSize: widget.radioSize,
            logoBoxWidth: widget.logoBoxWidth,
            logoBoxHeight: widget.logoBoxHeight,
            logoImageAsset: widget.logoImageAsset,
            unselectedRadioFill: widget.unselectedRadioFill,
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
  final String? logoImageAsset;
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
    this.logoImageAsset,
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
  static const double _defaultLogoBoxWidth = PaymentMethodIcon.width;
  static const double _defaultLogoBoxHeight = 40;
  static const double _logoBoxRadius = 8;
  static const double _defaultRadioSize = 22;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(
      tileRadius ?? _defaultTileRadius,
    );

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
    final imageAsset = logoImageAsset;
    if (imageAsset != null) {
      return Image.asset(
        imageAsset,
        width: logoBoxWidth ?? _defaultLogoBoxWidth,
        height: logoBoxHeight ?? _defaultLogoBoxHeight,
        fit: BoxFit.contain,
      );
    }
    if (brand == CardBrand.unknown) {
      return SizedBox(
        width: logoBoxWidth ?? _defaultLogoBoxWidth,
        height: logoBoxHeight ?? _defaultLogoBoxHeight,
        child: const Center(child: PaymentMethodIcon.savedCard()),
      );
    }
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
              color: isSelected ? _selectedTextColor : _unselectedSubtitleColor,
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
        child: Icon(Icons.check, size: r * 0.64, color: Colors.white),
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

class SavedCardsScrollbarThumb extends StatelessWidget {
  final ScrollController controller;
  final double thickness;
  final double thumbHeight;
  final Color? thumbColor;
  final double trackHeight;

  const SavedCardsScrollbarThumb({
    super.key,
    required this.controller,
    required this.thickness,
    required this.thumbHeight,
    this.thumbColor,
    required this.trackHeight,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
        thumbColor ??
        Theme.of(context).scrollbarTheme.thumbColor?.resolve({}) ??
        const Color(0xFF645D9C);

    final double effectiveThumbHeight = thumbHeight.clamp(16.0, trackHeight);
    final double travel = (trackHeight - effectiveThumbHeight).clamp(
      0.0,
      trackHeight,
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final double maxScroll =
            controller.hasClients && controller.position.hasContentDimensions
            ? controller.position.maxScrollExtent
            : 0.0;

        final double offset = controller.hasClients ? controller.offset : 0.0;

        final double progress = maxScroll > 0
            ? (offset / maxScroll).clamp(0.0, 1.0)
            : 0.0;

        final double top = progress * travel;

        return SizedBox(
          width: thickness,
          height: trackHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: top,
                right: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: (details) {
                    if (!controller.hasClients ||
                        maxScroll <= 0 ||
                        travel <= 0) {
                      return;
                    }
                    final double deltaProgress = details.delta.dy / travel;
                    final double targetOffset =
                        (controller.offset + deltaProgress * maxScroll).clamp(
                          0.0,
                          maxScroll,
                        );
                    controller.jumpTo(targetOffset);
                  },
                  child: Container(
                    width: math.max(thickness, 16.0),
                    height: effectiveThumbHeight,
                    alignment: Alignment.centerRight,
                    child: Container(
                      key: const ValueKey('saved_cards_scrollbar_thumb'),
                      width: thickness,
                      height: effectiveThumbHeight,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(thickness / 2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
