import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/models/auto_renew_prepaid_models.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/autoRenew/autoRenewPage/prepaid/widgets/auto_renew_saved_cards_list.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../theme/auto_renew_prepaid_theme.dart';

class AutoRenewPaymentMethodSection extends StatelessWidget {
  final SavedCardModel? selectedCard;
  final String? selectedMethodId;
  final ValueChanged<SavedCardModel?> onCardSelected;
  final bool showWalletRow;
  final bool showNoAutoRenewRow;
  final String? walletBalanceText;
  final String noAutoRenewText;
  final VoidCallback? onPayFromWallet;
  final VoidCallback? onNoAutoRenewSelected;

  const AutoRenewPaymentMethodSection({
    super.key,
    required this.selectedCard,
    required this.onCardSelected,
    this.selectedMethodId,
    this.showWalletRow = true,
    this.showNoAutoRenewRow = false,
    this.walletBalanceText,
    this.noAutoRenewText = "i don't want to auto renew",
    this.onPayFromWallet,
    this.onNoAutoRenewSelected,
  })  : assert(
          !showWalletRow ||
              (walletBalanceText != null && onPayFromWallet != null),
          'walletBalanceText and onPayFromWallet are required when showWalletRow is true',
        ),
        assert(
          !(showWalletRow || showNoAutoRenewRow) ||
              onNoAutoRenewSelected != null,
          'onNoAutoRenewSelected is required when the no-auto-renew row is shown',
        );

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
          AutoRenewSavedCardsList(
            selectedToken: selectedCard?.token,
            onCardSelected: onCardSelected,
          ),
          if (showWalletRow || showNoAutoRenewRow)
            const SizedBox(height: AutoRenewPrepaidTheme.sectionItemGap),
          if (showWalletRow) ...[
            _buildPayFromWalletRow(),
            if (showNoAutoRenewRow)
              const SizedBox(height: AutoRenewPrepaidTheme.sectionItemGap),
          ],
          if (showNoAutoRenewRow) ...[
            _buildNoAutoRenewRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildPayFromWalletRow() {
    // static option
    return _StaticPaymentOptionTile(
      selected: selectedMethodId == AutoRenewPaymentMethod.wallet.id,
      onTap: onPayFromWallet,
      leading: SvgPicture.asset(
        AssetConstant.walletIconSVG,
        width: AutoRenewPrepaidTheme.addCardIconSize,
        height: AutoRenewPrepaidTheme.addCardIconSize,
        fit: BoxFit.contain,
      ),
      title: 'pay from wallet',
      titleTrailing: Container(
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
          walletBalanceText!,
          style: AutoRenewPrepaidTheme.walletAmountTextStyle,
        ),
      ),
    );
  }

  Widget _buildNoAutoRenewRow() {
    return _StaticPaymentOptionTile(
      selected: selectedMethodId == AutoRenewPaymentMethod.none.id,
      onTap: onNoAutoRenewSelected,
      title: noAutoRenewText,
    );
  }
}

class _StaticPaymentOptionTile extends StatelessWidget {
  const _StaticPaymentOptionTile({
    required this.title,
    required this.selected,
    this.onTap,
    this.leading,
    this.titleTrailing,
  });

  static const Color _selectedBg = Color(0xFFEDEAF8);
  static const Color _selectedBorder = Color(0xFF645D9C);
  static const Color _selectedTextColor = Color(0xFF645D9C);
  static const Color _unselectedBg = Colors.white;
  static const Color _unselectedBorder = Color(0xFFE5E7EB);
  static const Color _unselectedRadioBorder = Color(0xFFCFCFCF);

  static const double _tileRadius = 12;
  static const double _tileMinHeight = 64;
  static const double _radioSize = 22;
  static const double _checkIconSize = 14;

  final String title;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? titleTrailing;

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
            color: selected ? _selectedBg : _unselectedBg,
            borderRadius: radius,
            border: Border.all(
              color: selected ? _selectedBorder : _unselectedBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _tileMinHeight - 24),
            child: Row(
              children: [
                if (leading != null) ...[
                  SizedBox(
                    width: 20,
                    height: 40,
                    child: Center(child: leading),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: _titleStyle,
                        ),
                      ),
                      if (titleTrailing != null) ...[
                        const SizedBox(width: 10),
                        titleTrailing!,
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _SelectionIndicator(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle get _titleStyle => TextStyle(
        color: selected ? _selectedTextColor : AutoRenewPrepaidTheme.primary,
        fontSize: 16,
        fontFamily: AppConstants.defaultFontFamily,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );
}

class _SelectionIndicator extends StatelessWidget {
  const _SelectionIndicator({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        width: _StaticPaymentOptionTile._radioSize,
        height: _StaticPaymentOptionTile._radioSize,
        decoration: const BoxDecoration(
          color: _StaticPaymentOptionTile._selectedBorder,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.check,
          size: _StaticPaymentOptionTile._checkIconSize,
          color: Colors.white,
        ),
      );
    }

    return Container(
      width: _StaticPaymentOptionTile._radioSize,
      height: _StaticPaymentOptionTile._radioSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _StaticPaymentOptionTile._unselectedRadioBorder,
          width: 1.5,
        ),
      ),
    );
  }
}
