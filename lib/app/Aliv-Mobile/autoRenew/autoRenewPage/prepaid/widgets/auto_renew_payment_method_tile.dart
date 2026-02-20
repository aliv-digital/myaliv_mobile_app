import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../models/auto_renew_prepaid_models.dart';
import '../theme/auto_renew_prepaid_theme.dart';

class AutoRenewPaymentMethodTile extends StatelessWidget {
  final AutoRenewPaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  const AutoRenewPaymentMethodTile({
    super.key,
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? AutoRenewPrepaidTheme.selectedTileBorderColor()
        : AutoRenewPrepaidTheme.border;

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(AutoRenewPrepaidTheme.cardTileTapRadius),
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? AutoRenewPrepaidTheme.cardBgSelected
              : AutoRenewPrepaidTheme.cardBg,
          borderRadius:
              BorderRadius.circular(AutoRenewPrepaidTheme.cardTileRadius),
          border: Border.all(
            color: borderColor,
            width: AutoRenewPrepaidTheme.tileBorderWidth,
          ),
        ),
        padding: AutoRenewPrepaidTheme.cardTilePadding,
        child: Row(
          children: [
            if (method.isCard)
              _BrandLogo(brand: method.card!.brand)
            else
              const SizedBox.shrink(),
            if (method.isCard)
              const SizedBox(width: AutoRenewPrepaidTheme.tileLogoGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title(),
                    style: AutoRenewPrepaidTheme.tileTitle(selected: selected),
                  ),
                  if (_subtitle() != null) ...[
                    const SizedBox(
                      height: AutoRenewPrepaidTheme.tileTitleSubtitleGap,
                    ),
                    Text(
                      _subtitle()!,
                      style: AutoRenewPrepaidTheme.tileSubtitle(
                        selected: selected,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AutoRenewPrepaidTheme.tileSelectionGap),
            _SelectionIndicator(selected: selected),
          ],
        ),
      ),
    );
  }

  String _title() {
    switch (method.type) {
      case AutoRenewMethodType.card:
        return '${_brandLabel(method.card!.brand)} ending in ${method.card!.ending}';
      case AutoRenewMethodType.wallet:
        return 'charge to my wallet';
      case AutoRenewMethodType.none:
        return "i don't want to auto renew";
    }
  }

  String? _subtitle() {
    if (method.type == AutoRenewMethodType.card) {
      return 'expiry ${method.card!.expiry}';
    }
    return null;
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

class _SelectionIndicator extends StatelessWidget {
  final bool selected;
  const _SelectionIndicator({required this.selected});

  @override
  Widget build(BuildContext context) {
    final border =
        selected ? AutoRenewPrepaidTheme.primary : AutoRenewPrepaidTheme.border;

    return Container(
      width: AutoRenewPrepaidTheme.selectionIndicatorSize,
      height: AutoRenewPrepaidTheme.selectionIndicatorSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: border,
          width: AutoRenewPrepaidTheme.selectionIndicatorBorderWidth,
        ),
        color: selected
            ? AutoRenewPrepaidTheme.primary
            : AutoRenewPrepaidTheme.transparent,
      ),
      child: selected
          ? const Icon(
              Icons.check,
              size: AutoRenewPrepaidTheme.selectionCheckIconSize,
              color: AutoRenewPrepaidTheme.white,
            )
          : null,
    );
  }
}

class _BrandLogo extends StatelessWidget {
  final CardBrand brand;
  const _BrandLogo({required this.brand});

  @override
  Widget build(BuildContext context) {
    final isVisa = brand == CardBrand.visa;

    return Container(
      width: AutoRenewPrepaidTheme.cardLogoWidth,
      height: AutoRenewPrepaidTheme.cardLogoHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(AutoRenewPrepaidTheme.cardTileRadius),
      ),
      child: SvgPicture.asset(
        isVisa ? AssetConstant.visaCardSVG : AssetConstant.masterCardSVG,
      ),
    );
  }
}
