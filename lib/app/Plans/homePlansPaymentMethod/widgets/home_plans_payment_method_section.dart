import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../model/home_plans_payment_method_models.dart';
import '../theme/home_plans_payment_method_theme.dart';
import 'home_plans_payment_method_tile.dart';

class HomePlansPaymentMethodSection extends StatefulWidget {
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
            height: HomePlansPaymentMethodTheme.thirdCardToPayWithCardGap,
          ),
          _buildPayWithCardRow(),
          if (widget.showPayFromWallet) ...[
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
    final chargeToAccountMethods = widget.methods
        .where((HomePlansSavedPaymentMethod m) => m.isChargeToMyAccount)
        .toList(growable: false);

    return BlocBuilder<SavedCardsCubit, SavedCardsState>(
      bloc: instance<SavedCardsCubit>(),
      builder: (context, savedCardsState) {
        final List<Widget> tiles = <Widget>[];

        for (final method in chargeToAccountMethods) {
          tiles.add(_buildChargeToAccountTile(method));
        }

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

        return Column(children: tiles);
      },
    );
  }

  Widget _buildChargeToAccountTile(HomePlansSavedPaymentMethod method) {
    return HomePlansPaymentMethodTile(
      logoSvgAsset: method.logoSvgAsset,
      title: 'charge to my account',
      subtitle: null,
      showLogo: false,
      titleStyle: HomePlansPaymentMethodTheme.chargeToAccount,
      tilePadding: HomePlansPaymentMethodTheme.chargeToAccountTilePadding,
      indicatorSize: HomePlansPaymentMethodTheme.selectedIndicatorSize,
      textToIndicatorGap: 16,
      selected: widget.selectedId == method.id,
      onTap: () => widget.onSelect(method.id),
    );
  }

  Widget _buildSavedCardTile(SavedCardModel card) {
    return HomePlansPaymentMethodTile(
      logoSvgAsset: AssetConstant.creditCardIconSVG,
      title: card.displayLabel,
      showLogo: true,
      indicatorSize: HomePlansPaymentMethodTheme.selectedIndicatorSize,
      textToIndicatorGap: 4,
      selected: widget.selectedId == card.token,
      onTap: () => widget.onSelect(card.token),
    );
  }

  Widget _buildPayWithCardRow() {
    return InkWell(
      onTap: widget.onPayWithCard,
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
            Text('pay with card', style: HomePlansPaymentMethodTheme.addCard),
            const Spacer(),
            _buildChevronIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildPayFromWalletRow() {
    return InkWell(
      onTap: widget.onPayFromWallet,
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
            Text('pay from wallet', style: HomePlansPaymentMethodTheme.addCard),
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
                    HomePlansPaymentMethodTheme.walletChipCornerRadius,
                  ),
                ),
              ),
              child: Text(
                widget.walletBalanceText,
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

}
