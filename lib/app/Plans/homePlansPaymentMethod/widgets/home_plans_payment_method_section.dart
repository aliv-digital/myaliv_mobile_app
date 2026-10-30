import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import 'package:myaliv_mobile_app/resources/widgets/cards/payment_option_tile.dart';

import '../bloc/home_plans_payment_method_state.dart';
import '../model/home_plans_payment_method_models.dart';
import '../theme/home_plans_payment_method_theme.dart';
import 'home_plans_payment_method_tile.dart';

class HomePlansPaymentMethodSection extends StatefulWidget {
  final List<HomePlansSavedPaymentMethod> methods;
  final String? selectedId;
  final HomePlansPaymentMode paymentMode;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onChargeToAccountSelect;
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
    required this.onChargeToAccountSelect,
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
  final _savedCardsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    instance<SavedCardsCubit>().fetchSavedCards();
  }

  @override
  void dispose() {
    _savedCardsScrollController.dispose();
    super.dispose();
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
              height: HomePlansPaymentMethodTheme
                  .firstToSecondCardGap, //payWithCardToWalletGap,
            ),
            _buildPayFromWalletRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodList() {
    final chargeToAccountMethods = widget.methods
        .where((HomePlansSavedPaymentMethod m) => m.isChargeToMyAccount)
        .toList(growable: false);

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
        } else if (savedCardsState.hasCards) {
          tiles.add(_buildSavedCardsList(savedCardsState.cards));
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

  Widget _buildSavedCardsList(List<SavedCardModel> cards) {
    const limit = HomePlansPaymentMethodTheme.maxVisibleSavedCards;
    const gap = HomePlansPaymentMethodTheme.firstToSecondCardGap;
    if (cards.length <= limit) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: gap),
            _buildSavedCardTile(cards[i]),
          ],
        ],
      );
    }

    return SizedBox(
      height:
          limit * HomePlansPaymentMethodTheme.savedCardMinHeight +
          (limit - 1) * gap,
      child: Scrollbar(
        controller: _savedCardsScrollController,
        thumbVisibility: true,
        thickness: HomePlansPaymentMethodTheme.savedCardsScrollbarThickness,
        child: ListView.separated(
          controller: _savedCardsScrollController,
          primary: false,
          padding: const EdgeInsetsDirectional.only(
            end: HomePlansPaymentMethodTheme.savedCardsScrollbarPadding,
          ),
          physics: const ClampingScrollPhysics(),
          itemCount: cards.length,
          separatorBuilder: (_, _) => const SizedBox(height: gap),
          itemBuilder: (_, index) => _buildSavedCardTile(cards[index]),
        ),
      ),
    );
  }

  bool get _cardModeActive => widget.paymentMode == HomePlansPaymentMode.card;

  bool get _chargeToAccountModeActive {
    return widget.paymentMode == HomePlansPaymentMode.chargeToMyAccount;
  }

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
      selected: _chargeToAccountModeActive && widget.selectedId == method.id,
      onTap: () => widget.onChargeToAccountSelect(method.id),
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
      leadingWidget: _buildCardIcon(),
    );
  }

  Widget _buildCardIcon() {
    return Image.asset(
      AssetConstant.cardIconPNG,
      width: HomePlansPaymentMethodTheme.savedCardLogoWidth,
      height: HomePlansPaymentMethodTheme.savedCardLogoHeight,
      fit: BoxFit.contain,
    );
  }

  Widget _buildPayWithCardRow() {
    return PaymentOptionTile(
      title: 'pay with card',
      titleColor: Colors.black,
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
      titleColor: Colors.black,
      selected: widget.paymentMode == HomePlansPaymentMode.payFromWallet,
      onTap: widget.onPayFromWallet,
      tileRadius: 10,
      radioSize: HomePlansPaymentMethodTheme.selectedIndicatorSize,
      leadingWidth: HomePlansPaymentMethodTheme.savedCardLogoWidth,
      leadingHeight: HomePlansPaymentMethodTheme.savedCardLogoHeight,
      unselectedRadioFill: HomePlansPaymentMethodTheme.unselectedIndicatorColor,
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      leadingToTextGap: 12,
      leading: _buildCardIcon(),
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
