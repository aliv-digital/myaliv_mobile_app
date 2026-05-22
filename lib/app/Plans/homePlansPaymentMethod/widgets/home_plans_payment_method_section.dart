import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/cards/payment_option_tile.dart';
import 'package:myaliv_mobile_app/resources/widgets/cards/saved_card_brand_box.dart';
import 'package:myaliv_mobile_app/resources/widgets/cards/saved_cards_radio_list.dart'
    show CardBrand;

import '../bloc/home_plans_payment_method_state.dart';
import '../model/home_plans_payment_method_models.dart';
import '../theme/home_plans_payment_method_theme.dart';
import 'home_plans_payment_method_tile.dart';

class HomePlansPaymentMethodSection extends StatefulWidget {
  final List<HomePlansSavedPaymentMethod> methods;
  final String? selectedId;
  final HomePlansPaymentMode paymentMode;
  final ValueChanged<String> onSelect;
  final VoidCallback onPayWithCard;
  final bool showPayFromWallet;
  final String walletBalanceText;
  final VoidCallback onPayFromWallet;

  const HomePlansPaymentMethodSection({
    super.key,
    required this.methods,
    required this.selectedId,
    required this.paymentMode,
    required this.onSelect,
    required this.onPayWithCard,
    required this.showPayFromWallet,
    required this.walletBalanceText,
    required this.onPayFromWallet,
  });

  @override
  State<HomePlansPaymentMethodSection> createState() =>
      _HomePlansPaymentMethodSectionState();
}

class _HomePlansPaymentMethodSectionState
    extends State<HomePlansPaymentMethodSection> {
  @override
  void initState() {
    super.initState();
    instance<SavedCardsCubit>().fetchSavedCards();
  }

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
            height: HomePlansPaymentMethodTheme.firstToSecondCardGap,
          ),
          _buildPayWithCardRow(),
          if (widget.showPayFromWallet) ...[
            const SizedBox(
              height: HomePlansPaymentMethodTheme.firstToSecondCardGap,//payWithCardToWalletGap,
            ),
            _buildPayFromWalletRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodList() {
    final chargeToAccountMethods = widget.methods.where((HomePlansSavedPaymentMethod m) => m.isChargeToMyAccount).toList(growable: false);

    return BlocBuilder<SavedCardsCubit, SavedCardsState>(
      bloc: instance<SavedCardsCubit>(),
      builder: (context, savedCardsState) {
        final List<Widget> tiles = <Widget>[];

        if (savedCardsState.isLoading && !savedCardsState.hasCards) {
          if (tiles.isNotEmpty) {
            tiles.add(
              const SizedBox(
                height: HomePlansPaymentMethodTheme.firstToSecondCardGap,
              ),
            );
          }
          tiles.add(
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          );
        } else {
          for (final SavedCardModel card in savedCardsState.cards) {
            if (tiles.isNotEmpty) {
              tiles.add(
                const SizedBox(
                  height: HomePlansPaymentMethodTheme.firstToSecondCardGap,
                ),
              );
            }
            tiles.add(_buildSavedCardTile(card));
          }
        }
        for (final method in chargeToAccountMethods) {
          if (tiles.isNotEmpty) {
            tiles.add(
              const SizedBox(
                height: HomePlansPaymentMethodTheme.firstToSecondCardGap,
              ),
            );
          }
          tiles.add(_buildChargeToAccountTile(method));
        }

        return Column(children: tiles);
      },
    );
  }

  bool get _cardModeActive => widget.paymentMode == HomePlansPaymentMode.card;

  Widget _buildChargeToAccountTile(HomePlansSavedPaymentMethod method) {
    return HomePlansPaymentMethodTile(
      logoSvgAsset: method.logoSvgAsset,
      title: 'charge to my account',
      subtitle: null,
      showLogo: false,
      titleStyle: HomePlansPaymentMethodTheme.chargeToAccount,
     // tilePadding: HomePlansPaymentMethodTheme.chargeToAccountTilePadding,
      indicatorSize: HomePlansPaymentMethodTheme.selectedIndicatorSize,
      textToIndicatorGap: 16,
      selected: _cardModeActive && widget.selectedId == method.id,
      onTap: () => widget.onSelect(method.id),
    );
  }

  Widget _buildSavedCardTile(SavedCardModel card) {
    return HomePlansPaymentMethodTile(
     // tilePadding: EdgeInsets.only(left: 16,right: 16,top: 28,bottom: 28),
      logoSvgAsset: AssetConstant.creditCardIconSVG,
      title: card.displayLabel,
      showLogo: true,
      indicatorSize: HomePlansPaymentMethodTheme.selectedIndicatorSize,
      textToIndicatorGap: 4,
      selected: _cardModeActive && widget.selectedId == card.token,
      onTap: () => widget.onSelect(card.token),
      // Use the shared brand box so the leading icon reads identically to
      // the saved-card tile on `TopUpPaymentScreen`.
      leadingWidget: SavedCardBrandBox(
        brand: CardBrand.unknown,
        width: HomePlansPaymentMethodTheme.savedCardLogoWidth,
        height: HomePlansPaymentMethodTheme.savedCardLogoHeight,
      ),
    );
  }

  Widget _buildPayWithCardRow() {
    return PaymentOptionTile(
      title: 'pay with card',
      selected: widget.paymentMode == HomePlansPaymentMode.payWithCard,
      onTap: widget.onPayWithCard,
      tileRadius: 10,
      radioSize: HomePlansPaymentMethodTheme.selectedIndicatorSize,
      leadingWidth: HomePlansPaymentMethodTheme.savedCardLogoWidth,
      leadingHeight: HomePlansPaymentMethodTheme.savedCardLogoHeight,
      unselectedRadioFill: HomePlansPaymentMethodTheme.unselectedIndicatorColor,
      leading: const Icon(
        Icons.add,
        size: HomePlansPaymentMethodTheme.paymentActionIconSize,
        color: HomePlansPaymentMethodTheme.plus,
      ),
    );
  }

  Widget _buildPayFromWalletRow() {
    return PaymentOptionTile(
      title: 'pay from wallet',
      selected: widget.paymentMode == HomePlansPaymentMode.payFromWallet,
      onTap: widget.onPayFromWallet,
      tileRadius: 10,
      radioSize: HomePlansPaymentMethodTheme.selectedIndicatorSize,
      leadingWidth: HomePlansPaymentMethodTheme.savedCardLogoWidth,
      leadingHeight: HomePlansPaymentMethodTheme.savedCardLogoHeight,
      unselectedRadioFill: HomePlansPaymentMethodTheme.unselectedIndicatorColor,
      leading: SizedBox(
        width: HomePlansPaymentMethodTheme.paymentActionIconSize,
        height: HomePlansPaymentMethodTheme.paymentActionIconSize,
        child: SvgPicture.asset(
          AssetConstant.walletIconSVG,
          fit: BoxFit.contain,
        ),
      ),
      titleTrailing: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: HomePlansPaymentMethodTheme.walletChipHorizontalPadding,
          vertical: HomePlansPaymentMethodTheme.walletChipVerticalPadding,
        ),
        decoration: const BoxDecoration(
          color: HomePlansPaymentMethodTheme.walletChipBackground,
          borderRadius: BorderRadius.all(
            Radius.circular(HomePlansPaymentMethodTheme.walletChipCornerRadius),
          ),
        ),
        child: Text(
          widget.walletBalanceText,
          style: HomePlansPaymentMethodTheme.walletAmount,
        ),
      ),
    );
  }
}
