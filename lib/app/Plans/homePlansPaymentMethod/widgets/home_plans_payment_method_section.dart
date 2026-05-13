import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../model/home_plans_payment_method_models.dart';
import '../theme/home_plans_payment_method_theme.dart';
import 'home_plans_payment_method_tile.dart';

class HomePlansPaymentMethodSection extends StatelessWidget {
  final List<HomePlansSavedPaymentMethod> methods;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onPayWithCard;
  final bool showPayFromWallet;
  final String walletBalanceText;
  final VoidCallback onPayFromWallet;

  const HomePlansPaymentMethodSection({
    super.key,
    required this.methods,
    required this.selectedId,
    required this.onSelect,
    required this.onPayWithCard,
    required this.showPayFromWallet,
    required this.walletBalanceText,
    required this.onPayFromWallet,
  });

  @override
  Widget build(BuildContext context) {
    // This card contains:
    // 1) Saved payment methods
    // 2) "pay with card" action
    // 3) "pay from wallet" action (for prepaid users only)
    return Container(
      padding: HomePlansPaymentMethodTheme.sectionContentPadding,
      decoration: BoxDecoration(
        color: HomePlansPaymentMethodTheme.cardBg,
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
            style: HomePlansPaymentMethodTheme.sectionTitle,
          ),
          const SizedBox(
            height: HomePlansPaymentMethodTheme.sectionTitleToFirstCardGap,
          ),
          _buildPaymentMethodList(),
          const SizedBox(
            height: HomePlansPaymentMethodTheme.thirdCardToPayWithCardGap,
          ),
          _buildPayWithCardRow(),
          if (showPayFromWallet) ...[
            const SizedBox(
              height: HomePlansPaymentMethodTheme.payWithCardToWalletGap,
            ),
            _buildPayFromWalletRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodList() {
    return Column(
      children: <Widget>[
        for (int index = 0; index < methods.length; index++) ...[
          HomePlansPaymentMethodTile(
            logoSvgAsset: methods[index].logoSvgAsset,
            title: methods[index].isChargeToMyAccount
                ? 'charge to my account'
                : '${_brandText(methods[index])} ending in ${methods[index].ending}',
            subtitle: methods[index].isChargeToMyAccount
                ? null
                : 'expiry ${methods[index].expiry}',
            showLogo: !methods[index].isChargeToMyAccount,
            titleStyle: methods[index].isChargeToMyAccount
                ? HomePlansPaymentMethodTheme.chargeToAccount
                : null,
            tilePadding: methods[index].isChargeToMyAccount
                ? HomePlansPaymentMethodTheme.chargeToAccountTilePadding
                : null,
            indicatorSize: HomePlansPaymentMethodTheme.selectedIndicatorSize,
            textToIndicatorGap: methods[index].isChargeToMyAccount ? 16 : 4,
            selected: selectedId == methods[index].id,
            onTap: () {
              onSelect(methods[index].id);
            },
          ),
          if (index == 0)
            const SizedBox(
              height: HomePlansPaymentMethodTheme.firstToSecondCardGap,
            ),
          if (index == 1)
            const SizedBox(
              height: HomePlansPaymentMethodTheme.secondToThirdCardGap,
            ),
        ],
      ],
    );
  }

  Widget _buildPayWithCardRow() {
    return InkWell(
      onTap: onPayWithCard,
      child: Padding(
        padding: HomePlansPaymentMethodTheme.payWithCardRowPadding,
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.add,
              size: HomePlansPaymentMethodTheme.paymentActionIconSize,
              color: HomePlansPaymentMethodTheme.plus,
            ),
            const SizedBox(width: 8),
            Text(
              'pay with card',
              style: HomePlansPaymentMethodTheme.addCard,
            ),
            const Spacer(),
            _buildChevronIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildPayFromWalletRow() {
    return InkWell(
      onTap: onPayFromWallet,
      child: Padding(
        padding: HomePlansPaymentMethodTheme.payWithCardRowPadding,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: HomePlansPaymentMethodTheme.paymentActionIconSize,
              height: HomePlansPaymentMethodTheme.paymentActionIconSize,
              child: SvgPicture.asset(
                AssetConstant.walletIconSVG,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            // how wallet balance text is showing , from which source
            Text(
              'pay from wallet',
              style: HomePlansPaymentMethodTheme.addCard,
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal:
                    HomePlansPaymentMethodTheme.walletChipHorizontalPadding,
                vertical: HomePlansPaymentMethodTheme.walletChipVerticalPadding,
              ),
              decoration: const BoxDecoration(
                color: HomePlansPaymentMethodTheme.walletChipBackground,
                borderRadius: BorderRadius.all(
                  Radius.circular(
                      HomePlansPaymentMethodTheme.walletChipCornerRadius),
                ),
              ),
              child: Text(
                walletBalanceText,
                style: HomePlansPaymentMethodTheme.walletAmount,
              ),
            ),
            const Spacer(),
            _buildChevronIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildChevronIcon() {
    return SizedBox(
      width: HomePlansPaymentMethodTheme.payWithCardChevronSize,
      height: HomePlansPaymentMethodTheme.payWithCardChevronSize,
      child: SvgPicture.asset(
        AssetConstant.arrowRightIconSVG,
        width: HomePlansPaymentMethodTheme.payWithCardChevronSize,
        height: HomePlansPaymentMethodTheme.payWithCardChevronSize,
        fit: BoxFit.contain,
      ),
    );
  }

  String _brandText(HomePlansSavedPaymentMethod m) {
    switch (m.brand) {
      case HomePlansCardBrand.visa:
        return 'visa';
      case HomePlansCardBrand.mastercard:
        return 'mastercard';
      case HomePlansCardBrand.unknown:
        return 'card';
    }
  }
}
