import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../model/guest_payment_method_prepaid_models.dart';
import '../theme/guest_payment_method_prepaid_theme.dart';
import 'guest_payment_method_tile.dart';

class GuestPaymentMethodSection extends StatelessWidget {
  final List<GuestSavedPaymentMethod> methods;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onPayWithCard;

  const GuestPaymentMethodSection({
    super.key,
    required this.methods,
    required this.selectedId,
    required this.onSelect,
    required this.onPayWithCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: GuestPaymentMethodPrepaidTheme.sectionContentPadding,
      decoration: BoxDecoration(
        color: GuestPaymentMethodPrepaidTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('payment method',
              style: GuestPaymentMethodPrepaidTheme.sectionTitle),
          const SizedBox(
            height: GuestPaymentMethodPrepaidTheme.sectionTitleToFirstCardGap,
          ),
          for (int i = 0; i < methods.length; i++) ...[
            GuestPaymentMethodTile(
              logoSvgAsset: methods[i].logoSvgAsset,
              title: methods[i].isChargeToMyAccount
                  ? 'charge to my account'
                  : '${_brandText(methods[i])} ending in ${methods[i].ending}',
              subtitle: methods[i].isChargeToMyAccount
                  ? null
                  : 'expiry ${methods[i].expiry}',
              showLogo: !methods[i].isChargeToMyAccount,
              titleStyle: methods[i].isChargeToMyAccount
                  ? GuestPaymentMethodPrepaidTheme.chargeToAccount
                  : null,
              tilePadding: methods[i].isChargeToMyAccount
                  ? GuestPaymentMethodPrepaidTheme.chargeToAccountTilePadding
                  : null,
              indicatorSize:
                  GuestPaymentMethodPrepaidTheme.selectedIndicatorSize,
              textToIndicatorGap: methods[i].isChargeToMyAccount ? 16 : 4,
              selected: selectedId == methods[i].id,
              onTap: () => onSelect(methods[i].id),
            ),
            if (i == 0)
              const SizedBox(
                height: GuestPaymentMethodPrepaidTheme.firstToSecondCardGap,
              ),
            if (i == 1)
              const SizedBox(
                height: GuestPaymentMethodPrepaidTheme.secondToThirdCardGap,
              ),
          ],
          const SizedBox(
            height: GuestPaymentMethodPrepaidTheme.thirdCardToPayWithCardGap,
          ),
          InkWell(
            onTap: onPayWithCard,
            child: Padding(
              padding: GuestPaymentMethodPrepaidTheme.payWithCardRowPadding,
              child: Row(
                children: [
                  const Icon(Icons.add,
                      size: 18, color: GuestPaymentMethodPrepaidTheme.plus),
                  const SizedBox(width: 8),
                  Text('pay with card',
                      style: GuestPaymentMethodPrepaidTheme.addCard),
                  const Spacer(),
                  SizedBox(
                    width: GuestPaymentMethodPrepaidTheme.payWithCardChevronSize,
                    height:
                        GuestPaymentMethodPrepaidTheme.payWithCardChevronSize,
                    child: SvgPicture.asset(
                      AssetConstant.arrowRightIconSVG,
                      width:
                          GuestPaymentMethodPrepaidTheme.payWithCardChevronSize,
                      height:
                          GuestPaymentMethodPrepaidTheme.payWithCardChevronSize,
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

  String _brandText(GuestSavedPaymentMethod m) {
    switch (m.brand) {
      case GuestCardBrand.visa:
        return 'visa';
      case GuestCardBrand.mastercard:
        return 'mastercard';
      case GuestCardBrand.unknown:
        return 'card';
    }
  }
}
