import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/resources/widgets/cards/payment_option_tile.dart';
import 'package:myaliv_mobile_app/resources/widgets/cards/saved_cards_radio_list.dart';

import '../theme/make_payment_postpaid_theme.dart';

class MpPaymentMethodSection extends StatelessWidget {
  final String? selectedToken;
  final bool payWithCardSelected;
  final ValueChanged<SavedCardModel> onCardSelected;
  final VoidCallback onPayWithCardSelected;

  const MpPaymentMethodSection({
    super.key,
    required this.selectedToken,
    required this.payWithCardSelected,
    required this.onCardSelected,
    required this.onPayWithCardSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MakePaymentPostPaidTheme.cardBg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 8),
            color: Color(0x14000000),
          ),
        ],
      ),
      padding: MakePaymentPostPaidTheme.paymentMethodSectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'payment method',
            textAlign: TextAlign.center,
            style: MakePaymentPostPaidTheme.paymentMethodSectionTitle,
          ),
          const SizedBox(
            height: MakePaymentPostPaidTheme
                .paymentMethodSectionTitleToFirstCardGap,
          ),
          _MpSavedCardsList(
            selectedToken: payWithCardSelected ? null : selectedToken,
            onCardSelected: onCardSelected,
            autoSelectFirst: !payWithCardSelected,
          ),
          const SizedBox(
            height: MakePaymentPostPaidTheme
                .paymentMethodLastCardToPayWithCardGap,
          ),
          _PayWithCardTile(
            selected: payWithCardSelected,
            onTap: onPayWithCardSelected,
          ),
        ],
      ),
    );
  }
}

class _MpSavedCardsList extends StatelessWidget {
  final String? selectedToken;
  final ValueChanged<SavedCardModel> onCardSelected;
  final bool autoSelectFirst;

  const _MpSavedCardsList({
    required this.selectedToken,
    required this.onCardSelected,
    this.autoSelectFirst = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SavedCardsCubit, SavedCardsState>(
      listener: (context, state) {
        if (autoSelectFirst &&
            state.isSuccess &&
            state.hasCards &&
            selectedToken == null) {
          onCardSelected(state.cards.first);
        }
      },
      builder: (context, state) {
        if (state.isLoading && !state.hasCards) {
          return const _LoadingPlaceholder();
        }
        if (state.hasError && !state.hasCards) {
          return const _ErrorPlaceholder();
        }
        if (state.isEmpty) return const _EmptyPlaceholder();

        return SavedCardsRadioList(
          cards: state.cards,
          selectedToken: selectedToken,
          onCardSelected: onCardSelected,
          maxVisibleItems: 4,
          tileHeight: 64,
          unselectedRadioFill:
              MakePaymentPostPaidTheme.paymentMethodUnselectedIndicatorColor,
        );
      },
    );
  }
}

class _PayWithCardTile extends StatelessWidget {
  const _PayWithCardTile({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PaymentOptionTile(
      title: 'pay with card',
      selected: selected,
      onTap: onTap,
      contentPadding:
          MakePaymentPostPaidTheme.paymentMethodPayWithCardRowPadding,
      leadingWidth:
          MakePaymentPostPaidTheme.paymentMethodPayWithCardLeadingWidth,
      leadingHeight:
          MakePaymentPostPaidTheme.paymentMethodPayWithCardLeadingHeight,
      leadingToTextGap:
          MakePaymentPostPaidTheme.paymentMethodPayWithCardLeadingToTextGap,
      unselectedRadioFill:
          MakePaymentPostPaidTheme.paymentMethodUnselectedIndicatorColor,
      leading: const Icon(
        Icons.add,
        size: 18,
        color: MakePaymentPostPaidTheme.paymentMethodAccent,
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Text(
        'no saved cards',
        style: TextStyle(
          color: Color(0xFF707070),
          fontSize: 14,
          fontFamily: 'CircularPro',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  const _ErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'failed to load cards',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontSize: 14,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.read<SavedCardsCubit>().refreshSavedCards(),
            child: const Icon(Icons.refresh, color: Color(0xFFE53935)),
          ),
        ],
      ),
    );
  }
}
