import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/common/services/phone_number_formatter_service.dart';
import '../../../Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import '../../../Aliv-Mobile/account-information/cubit/account_info_state.dart';
import '../../../Home/best-plans/best_plan_injection.dart';
import '../models/home_roaming_confirmation_models.dart';
import '../theme/home_roaming_confirmation_theme.dart';
import 'home_roaming_confirmation_purchase_item_row.dart';

class HomeRoamingConfirmationPurchaseSummaryCard extends StatelessWidget {
  final HomeRoamingConfirmationData data;
  final void Function(String itemId) onRemoveItem;
  final bool showDateField;

  const HomeRoamingConfirmationPurchaseSummaryCard({
    this.showDateField = true,
    super.key,
    required this.data,
    required this.onRemoveItem,
  });

  HomeRoamingConfirmationPurchaseLineItem _resolveDisplayItem(
    HomeRoamingConfirmationPurchaseLineItem item,
  ) {
    if (showDateField) return item;

    return item.copyWith(subtitle: 'begins immediately');
  }

  String _accountDisplayName(AccountInfoState accountState) {
    final fullName = accountState.fullName?.trim();
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }

    return _nameFromEmail(accountState.email);
  }

  String _accountUsername(
    AccountInfoState accountState, {
    required String fallbackPhoneNumber,
  }) {
    final username = accountState.accountInfo?.username.trim() ?? '';
    if (username.isNotEmpty) {
      return username;
    }

    final fallback = fallbackPhoneNumber.trim();
    return fallback.isEmpty ? '--' : fallback;
  }

  String _nameFromEmail(String? email) {
    final normalizedEmail = email?.trim() ?? '';
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      return 'User';
    }

    return normalizedEmail.split('@').first;
  }

  @override
  Widget build(BuildContext context) {
    final accountState = instance<AccountInfoCubit>().state;
    final userName = _accountDisplayName(accountState);
    final userPhoneNumber = _accountUsername(
      accountState,
      fallbackPhoneNumber: data.phoneNumber,
    );

    return Container(
      decoration: BoxDecoration(
        color: HomeRoamingConfirmationTheme.cardWhite,
        borderRadius: BorderRadius.circular(
          HomeRoamingConfirmationTheme.purchaseSummaryCardRadius,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 10),
            color: HomeRoamingConfirmationTheme.shadow,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header block: strict 16/14/16/14 spacing from Figma.
          Padding(
            padding: HomeRoamingConfirmationTheme.purchaseSummaryHeaderPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: HomeRoamingConfirmationTheme
                      .purchaseSummaryHeaderTitleTextStyle,
                ),
                const SizedBox(
                  height: HomeRoamingConfirmationTheme
                      .purchaseSummaryHeaderTitleToPhoneGap,
                ),
                Text(
                  PhoneNumberFormatterService.format(userPhoneNumber),
                  style: HomeRoamingConfirmationTheme
                      .purchaseSummaryHeaderPhoneTextStyle,
                ),
              ],
            ),
          ),

          Divider(
            height: HomeRoamingConfirmationTheme.purchaseSummaryDividerHeight,
            thickness:
                HomeRoamingConfirmationTheme.purchaseSummaryDividerThickness,
            color: HomeRoamingConfirmationTheme.purchaseSummaryDividerColor,
          ),

          // Item blocks: strict 16/20/16/20 spacing from Figma.
          for (int i = 0; i < data.items.length; i++) ...[
            Padding(
              padding: HomeRoamingConfirmationTheme
                  .purchaseSummaryItemSectionPadding,
              child: HomeRoamingConfirmationPurchaseItemRow(
                item: _resolveDisplayItem(data.items[i]),
                onRemove: () {
                  final itemId = data.items[i].id;
                  final remainingItemCount =
                      data.items.where((item) => item.id != itemId).length;

                  onRemoveItem(itemId);

                  // Leave confirmation when there is no purchase item left.
                  if (remainingItemCount == 0 && context.canPop()) {
                    context.pop();
                  }
                },
              ),
            ),
            if (i != data.items.length - 1)
              Divider(
                height:
                    HomeRoamingConfirmationTheme.purchaseSummaryDividerHeight,
                thickness: HomeRoamingConfirmationTheme
                    .purchaseSummaryDividerThickness,
                color: HomeRoamingConfirmationTheme.purchaseSummaryDividerColor,
              ),
          ],
        ],
      ),
    );
  }
}
