import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../../../../../../../core/utils/app_session.dart';
import '../../theme/auto_renew_prepaid_theme.dart';

/// Bottom sheet for wallet payment confirmation.
class WalletPaymentBottomSheet extends StatelessWidget {
  final String walletBalanceText;
  final String amountText;

  const WalletPaymentBottomSheet({
    super.key,
    required this.walletBalanceText,
    required this.amountText,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String walletBalanceText,
    required String amountText,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AutoRenewPrepaidTheme.sheetBg,
      shape: AutoRenewPrepaidTheme.walletPaymentSheetShape(),
      builder: (_) => WalletPaymentBottomSheet(
        walletBalanceText: walletBalanceText,
        amountText: amountText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardBottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AutoRenewPrepaidTheme.walletPaymentHorizontalPadding,
        AutoRenewPrepaidTheme.walletPaymentTopPadding,
        AutoRenewPrepaidTheme.walletPaymentHorizontalPadding,
        AutoRenewPrepaidTheme.walletPaymentBottomPadding + keyboardBottomInset,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildBackButton(context),
            const SizedBox(
              height: AutoRenewPrepaidTheme.walletPaymentBackToTitleGap,
            ),
            const Text(
              'pay from wallet',
              style: AutoRenewPrepaidTheme.walletPaymentTitleStyle,
            ),
            const SizedBox(
              height: AutoRenewPrepaidTheme.walletPaymentTitleToBalanceGap,
            ),
            _buildWalletBalanceRow(),
            const SizedBox(
              height: AutoRenewPrepaidTheme.walletPaymentBalanceToAmountGap,
            ),
            const Text(
              'amount',
              style: AutoRenewPrepaidTheme.walletPaymentAmountLabelStyle,
            ),
            const SizedBox(
              height: AutoRenewPrepaidTheme.walletPaymentAmountLabelToFieldGap,
            ),
            _buildAmountField(),
            const SizedBox(
              height: AutoRenewPrepaidTheme.walletPaymentAmountFieldToButtonGap,
            ),
            _buildConfirmButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: const SizedBox(
        width: AutoRenewPrepaidTheme.walletPaymentBackButtonSize,
        height: AutoRenewPrepaidTheme.walletPaymentBackButtonSize,
        child: Icon(
          Icons.arrow_back,
          size: AutoRenewPrepaidTheme.walletPaymentBackIconSize,
          color: AutoRenewPrepaidTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildWalletBalanceRow() {
    return Row(
      children: <Widget>[
        SizedBox(
          width: AutoRenewPrepaidTheme.walletPaymentWalletIconSize,
          height: AutoRenewPrepaidTheme.walletPaymentWalletIconSize,
          child: SvgPicture.asset(
            AssetConstant.walletIconSVG,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(
          width: AutoRenewPrepaidTheme.walletPaymentWalletIconToTextGap,
        ),
        const Text(
          'Wallet balance',
          style: AutoRenewPrepaidTheme.walletPaymentWalletLabelStyle,
        ),
        const SizedBox(
          width: AutoRenewPrepaidTheme.walletPaymentWalletTextToChipGap,
        ),
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
            style: AutoRenewPrepaidTheme.walletPaymentWalletAmountStyle,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField() {
    return Container(
      height: AutoRenewPrepaidTheme.walletPaymentAmountFieldHeight,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AutoRenewPrepaidTheme.walletPaymentAmountFieldBackground,
        borderRadius: BorderRadius.circular(
          AutoRenewPrepaidTheme.walletPaymentAmountFieldRadius,
        ),
      ),
      child: Text(
        (AppSession.appRoute == 'prepaidPlanPurchase')? '\$ 75.00' : amountText,
        style: AutoRenewPrepaidTheme.walletPaymentAmountValueStyle,
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AutoRenewPrepaidTheme.walletPaymentConfirmButtonHeight,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop(true);
          // Navigation handled by state listener for auto-renew flow
          // Only navigate directly for plan purchase flow
          if (AppSession.appRoute == 'prepaidPlanPurchase') {
            context.push(AppRoutes.homePlanPurchaseReceiptScreen);
          }
        },
        style: AutoRenewPrepaidTheme.primaryPillButtonStyle(
          backgroundColor: AutoRenewPrepaidTheme.primary,
        ),
        child: const Text(
          'confirm payment',
          style: AutoRenewPrepaidTheme.walletPaymentConfirmButtonTextStyle,
        ),
      ),
    );
  }
}
