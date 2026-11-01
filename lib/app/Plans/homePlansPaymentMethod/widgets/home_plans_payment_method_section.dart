import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
// Previous action rows used PaymentOptionTile, with different saved-card metrics.
// import 'package:myaliv_mobile_app/resources/widgets/cards/payment_option_tile.dart';

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
    return BlocBuilder<SavedCardsCubit, SavedCardsState>(
      bloc: instance<SavedCardsCubit>(),
      builder: (context, savedCardsState) {
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
              _buildPaymentMethodList(savedCardsState),
              const SizedBox(
                height: HomePlansPaymentMethodTheme.firstToSecondCardGap,
              ),
              _alignWithSavedCards(_buildPayWithCardRow(), savedCardsState),
              if (widget.showPayFromWallet) ...[
                const SizedBox(
                  height: HomePlansPaymentMethodTheme.firstToSecondCardGap,
                ),
                _alignWithSavedCards(_buildPayFromWalletRow(), savedCardsState),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _alignWithSavedCards(Widget child, SavedCardsState state) {
    // The scrolling list reserves this same space for its scrollbar.
    return Padding(
      padding: EdgeInsetsDirectional.only(
        end:
            state.cards.length >
                HomePlansPaymentMethodTheme.maxVisibleSavedCards
            ? HomePlansPaymentMethodTheme.savedCardsScrollbarPadding
            : 0,
      ),
      child: child,
    );
  }

  Widget _buildPaymentMethodList(SavedCardsState savedCardsState) {
    final chargeToAccountMethods = widget.methods
        .where((HomePlansSavedPaymentMethod m) => m.isChargeToMyAccount)
        .toList(growable: false);
    final List<Widget> tiles = <Widget>[];

    if (savedCardsState.isLoading && !savedCardsState.hasCards) {
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
      tiles.add(
        _alignWithSavedCards(
          _buildChargeToAccountTile(method),
          savedCardsState,
        ),
      );
    }

    return Column(children: tiles);
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
    // Previous saved-card artwork retained for reference.
    // return SvgPicture.asset(
    //   AssetConstant.walletIconSVG,
    //   width: HomePlansPaymentMethodTheme.paymentActionIconSize,
    //   height: HomePlansPaymentMethodTheme.payWithCardChevronSize,
    //   fit: BoxFit.contain,
    // );
    return _buildPaymentIcon(AssetConstant.savedCreditCardsPNG);
  }

  Widget _buildPaymentIcon(String asset) {
    return Container(
      width: HomePlansPaymentMethodTheme.savedCardLogoWidth,
      height: HomePlansPaymentMethodTheme.savedCardLogoHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: HomePlansPaymentMethodTheme.cardBg,
        border: Border.all(
          color: HomePlansPaymentMethodTheme.paymentIconBorder,
          width: HomePlansPaymentMethodTheme.paymentIconBorderWidth,
        ),
        borderRadius: BorderRadius.circular(
          HomePlansPaymentMethodTheme.paymentIconCornerRadius,
        ),
      ),
      child: Image.asset(
        asset,
        width: HomePlansPaymentMethodTheme.paymentActionIconSize,
        height: HomePlansPaymentMethodTheme.paymentActionIconSize,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildPayWithCardRow() {
    // Previously PaymentOptionTile with a fixed black title and 40px minimum content height.
    return HomePlansPaymentMethodTile(
      logoSvgAsset: AssetConstant.creditCardIconSVG,
      title: 'pay with card',
      selected: widget.paymentMode == HomePlansPaymentMode.payWithCard,
      onTap: widget.onPayWithCard,
      indicatorSize: HomePlansPaymentMethodTheme.selectedIndicatorSize,
      textToIndicatorGap:
          HomePlansPaymentMethodTheme.savedCardTextToIndicatorGap,
      // Previous add-card artwork retained for reference.
      // leading: const Icon(
      //   Icons.add,
      //   size: HomePlansPaymentMethodTheme.paymentActionIconSize,
      //   color: HomePlansPaymentMethodTheme.plus,
      // ),
      leadingWidget: _buildPaymentIcon(AssetConstant.plusAddPNG),
    );
  }

  Widget _buildPayFromWalletRow() {
    // Previously PaymentOptionTile; use the same row as every saved card.
    return HomePlansPaymentMethodTile(
      logoSvgAsset: AssetConstant.walletIconSVGPayment,
      title: 'pay from wallet',
      selected: widget.paymentMode == HomePlansPaymentMode.payFromWallet,
      onTap: widget.onPayFromWallet,
      indicatorSize: HomePlansPaymentMethodTheme.selectedIndicatorSize,
      textToIndicatorGap:
          HomePlansPaymentMethodTheme.savedCardTextToIndicatorGap,
      leadingWidget: SizedBox(
        width: HomePlansPaymentMethodTheme.savedCardLogoWidth,
        height: HomePlansPaymentMethodTheme.savedCardLogoHeight,
        child: SvgPicture.asset(
          AssetConstant.walletIconSVGPayment,
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
