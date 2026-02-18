import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../repository/make_payment_postpaid_repository.dart';
import '../theme/make_payment_postpaid_theme.dart';

class MpPaymentMethodSection extends StatelessWidget {
  final List<MpPaymentMethod> methods;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAddCard;

  const MpPaymentMethodSection({
    super.key,
    required this.methods,
    required this.selectedIndex,
    required this.onSelect,
    required this.onAddCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MakePaymentPostPaidTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Color(0x14000000),
          ),
        ],
      ),
      padding: MakePaymentPostPaidTheme.paymentMethodSectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'payment method',
            textAlign: TextAlign.center,
            style: MakePaymentPostPaidTheme.paymentMethodSectionTitle,
          ),
          const SizedBox(
            height: MakePaymentPostPaidTheme.paymentMethodSectionTitleToFirstCardGap,
          ),
          for (int i = 0; i < methods.length; i++) ...[
            _MethodTile(
              method: methods[i],
              selected: i == selectedIndex,
              onTap: () => onSelect(i),
            ),
            if (i != methods.length - 1)
              const SizedBox(
                height: MakePaymentPostPaidTheme.paymentMethodBetweenCardsGap,
              ),
          ],
          const SizedBox(
            height: MakePaymentPostPaidTheme.paymentMethodLastCardToPayWithCardGap,
          ),
          InkWell(
            onTap: onAddCard,
            child: Padding(
              padding: MakePaymentPostPaidTheme.paymentMethodPayWithCardRowPadding,
              child: Row(
                children: [
                  const Icon(
                    Icons.add,
                    size: 18,
                    color: MakePaymentPostPaidTheme.paymentMethodAccent,
                  ),
                  const SizedBox(width: 8),
                  Text('pay with card', style: MakePaymentPostPaidTheme.addCard),
                  const Spacer(),
                  SizedBox(
                    width: MakePaymentPostPaidTheme.paymentMethodPayWithCardChevronSize,
                    height: MakePaymentPostPaidTheme.paymentMethodPayWithCardChevronSize,
                    child: SvgPicture.asset(
                      AssetConstant.arrowRightIconSVG,
                      width: MakePaymentPostPaidTheme.paymentMethodPayWithCardChevronSize,
                      height: MakePaymentPostPaidTheme.paymentMethodPayWithCardChevronSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final MpPaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  const _MethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? MakePaymentPostPaidTheme.paymentMethodSelectedBorder
        : MakePaymentPostPaidTheme.paymentMethodBorder;
    final nameStyle = selected
        ? MakePaymentPostPaidTheme.paymentMethodSelectedName
        : MakePaymentPostPaidTheme.paymentMethodName;
    final expiryStyle = selected
        ? MakePaymentPostPaidTheme.paymentMethodSelectedExpiry
        : MakePaymentPostPaidTheme.paymentMethodExpiry;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: selected
              ? MakePaymentPostPaidTheme.paymentMethodSelectedCardBg
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
        ),
        padding: MakePaymentPostPaidTheme.paymentMethodTilePadding,
        child: Row(
          children: [
            _BrandLogo(brand: method.brand),
            const SizedBox(width: MakePaymentPostPaidTheme.paymentMethodLogoToTextGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_brandLabel(method.brand)} ending in ${method.ending}',
                    style: nameStyle,
                  ),
                  const SizedBox(height: 4),
                  Text('expiry ${method.expiry}', style: expiryStyle),
                ],
              ),
            ),
            const SizedBox(
              width: MakePaymentPostPaidTheme.paymentMethodTextToIndicatorGap,
            ),
            _SelectionIndicator(selected: selected),
          ],
        ),
      ),
    );
  }

  String _brandLabel(MpCardBrand brand) {
    switch (brand) {
      case MpCardBrand.visa:
        return 'visa';
      case MpCardBrand.mastercard:
        return 'mastercard';
    }
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool selected;

  const _SelectionIndicator({required this.selected});

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        width: MakePaymentPostPaidTheme.paymentMethodIndicatorSize,
        height: MakePaymentPostPaidTheme.paymentMethodIndicatorSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: MakePaymentPostPaidTheme.paymentMethodSelectedIndicatorFillColor,
          shape: BoxShape.circle,
          border: Border.all(
            color:
                MakePaymentPostPaidTheme.paymentMethodSelectedIndicatorBorderColor,
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: MakePaymentPostPaidTheme.paymentMethodIndicatorCheckSize,
        ),
      );
    }

    return Container(
      width: MakePaymentPostPaidTheme.paymentMethodIndicatorSize,
      height: MakePaymentPostPaidTheme.paymentMethodIndicatorSize,
      decoration: BoxDecoration(
        color: MakePaymentPostPaidTheme.paymentMethodUnselectedIndicatorColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: MakePaymentPostPaidTheme.paymentMethodUnselectedIndicatorBorderColor,
          width: 1,
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  final MpCardBrand brand;

  const _BrandLogo({required this.brand});

  @override
  Widget build(BuildContext context) {
    final isVisa = brand == MpCardBrand.visa;

    return SizedBox(
      width: MakePaymentPostPaidTheme.paymentMethodLogoWidth,
      height: MakePaymentPostPaidTheme.paymentMethodLogoHeight,
      child: SvgPicture.asset(
        isVisa ? AssetConstant.visaCardSVG : AssetConstant.masterCardSVG,
        fit: BoxFit.contain,
      ),
    );
  }
}
