import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/dropdowns/saved_card_dropdown.dart';
import '../theme/auto_renew_prepaid_theme.dart';

class AutoRenewPaymentMethodSection extends StatelessWidget {
  final SavedCardModel? selectedCard;
  final ValueChanged<SavedCardModel?> onCardSelected;
  final String walletBalanceText;
  final VoidCallback onPayFromWallet;

  const AutoRenewPaymentMethodSection({
    super.key,
    required this.selectedCard,
    required this.onCardSelected,
    required this.walletBalanceText,
    required this.onPayFromWallet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AutoRenewPrepaidTheme.cardBg,
        borderRadius:
            BorderRadius.circular(AutoRenewPrepaidTheme.sectionRadius),
      ),
      padding: AutoRenewPrepaidTheme.sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'select payment method',
            style: AutoRenewPrepaidTheme.sectionTitleStyle,
          ),
          const SizedBox(height: AutoRenewPrepaidTheme.sectionTitleGap),
          SavedCardDropdown(
            selectedCard: selectedCard,
            onCardSelected: onCardSelected,
          ),
          const SizedBox(height: AutoRenewPrepaidTheme.payFromWalletTopGap),
          _buildPayFromWalletRow(),
        ],
      ),
    );
  }

  Widget _buildPayFromWalletRow() {
    return InkWell(
      onTap: onPayFromWallet,
      child: Padding(
        padding: AutoRenewPrepaidTheme.payFromWalletRowPadding,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: AutoRenewPrepaidTheme.addCardIconSize,
              height: AutoRenewPrepaidTheme.addCardIconSize,
              child: SvgPicture.asset(
                AssetConstant.walletIconSVG,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'pay from wallet',
              style: AutoRenewPrepaidTheme.payFromWalletTextStyle,
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AutoRenewPrepaidTheme.walletChipHorizontalPadding,
                vertical: AutoRenewPrepaidTheme.walletChipVerticalPadding,
              ),
              decoration: const BoxDecoration(
                color: AutoRenewPrepaidTheme.walletChipBackground,
                borderRadius: BorderRadius.all(
                  Radius.circular(AutoRenewPrepaidTheme.walletChipCornerRadius),
                ),
              ),
              child: Text(
                walletBalanceText,
                style: AutoRenewPrepaidTheme.walletAmountTextStyle,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: AutoRenewPrepaidTheme.payFromWalletChevronSize,
              height: AutoRenewPrepaidTheme.payFromWalletChevronSize,
              child: SvgPicture.asset(
                AssetConstant.arrowRightIconSVG,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
