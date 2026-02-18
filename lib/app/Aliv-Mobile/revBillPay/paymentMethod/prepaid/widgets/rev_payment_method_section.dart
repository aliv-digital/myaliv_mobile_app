import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../model/rev_payment_method_prepaid_models.dart';
import '../theme/rev_payment_method_prepaid_theme.dart';
import 'rev_payment_method_tile.dart';

class RevPaymentMethodSection extends StatelessWidget {
  final List<RevSavedPaymentMethod> methods;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onPayWithCard;

  const RevPaymentMethodSection({
    super.key,
    required this.methods,
    required this.selectedId,
    required this.onSelect,
    required this.onPayWithCard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: RevPaymentMethodPrepaidTheme.sectionContentPadding,
      decoration: BoxDecoration(
        color: RevPaymentMethodPrepaidTheme.cardBg,
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
          Text(
            'payment method',
            textAlign: TextAlign.center,
            style: RevPaymentMethodPrepaidTheme.sectionTitle,
          ),
          const SizedBox(height: RevPaymentMethodPrepaidTheme.sectionTitleToFirstCardGap),

          for (int i = 0; i < methods.length; i++) ...[
            RevPaymentMethodTile(
              logoSvgAsset: methods[i].logoSvgAsset,
              title: '${_brandText(methods[i])} ending in ${methods[i].ending}',
              subtitle: 'expiry ${methods[i].expiry}',
              selected: selectedId == methods[i].id,
              onTap: () => onSelect(methods[i].id),
            ),
            if (i < methods.length - 1)
              const SizedBox(height: RevPaymentMethodPrepaidTheme.betweenMethodCardsGap),
          ],
          const SizedBox(height: RevPaymentMethodPrepaidTheme.lastCardToPayWithCardGap),

          InkWell(
            onTap: onPayWithCard,
            child: Padding(
              padding: RevPaymentMethodPrepaidTheme.payWithCardRowPadding,
              child: Row(
                children: [
                   Icon(Icons.add, size: 18, color: RevPaymentMethodPrepaidTheme.plus),
                  const SizedBox(width: 8),
                  Text('pay with card', style: RevPaymentMethodPrepaidTheme.addCard),
                  const Spacer(),
                  SizedBox(
                    width: RevPaymentMethodPrepaidTheme.payWithCardChevronSize,
                    height: RevPaymentMethodPrepaidTheme.payWithCardChevronSize,
                    child: SvgPicture.asset(
                      AssetConstant.arrowRightIconSVG,
                      width: RevPaymentMethodPrepaidTheme.payWithCardChevronSize,
                      height: RevPaymentMethodPrepaidTheme.payWithCardChevronSize,
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

  String _brandText(RevSavedPaymentMethod m) {
    switch (m.brand) {
      case RevCardBrand.visa:
        return 'visa';
      case RevCardBrand.mastercard:
        return 'mastercard';
      case RevCardBrand.unknown:
        return 'card';
    }
  }
}
