import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/topUpPayment/prepaid/theme/top_up_payment_radio_metrics.dart';
import 'package:myaliv_mobile_app/resources/widgets/cards/saved_cards_radio_list.dart';

class TopUpPaymentSavedCardsSection extends StatelessWidget {
  final String? selectedToken;
  final ValueChanged<SavedCardModel> onCardSelected;
  final bool autoSelectFirst;

  const TopUpPaymentSavedCardsSection({
    super.key,
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
        if (state.isLoading) return const _LoadingPlaceholder();
        if (state.hasError) return const _ErrorPlaceholder();
        if (state.isEmpty) return const _EmptyPlaceholder();

        return SavedCardsRadioList(
          cards: state.cards,
          selectedToken: selectedToken,
          onCardSelected: onCardSelected,
          maxVisibleItems: 4,
          tileHeight: 56,
          tileRadius: TopUpPaymentRadioMetrics.tileRadius,
          radioSize: TopUpPaymentRadioMetrics.radioSize,
          logoBoxWidth: TopUpPaymentRadioMetrics.logoBoxWidth,
          logoBoxHeight: TopUpPaymentRadioMetrics.logoBoxHeight,
          unselectedRadioFill: TopUpPaymentRadioMetrics.unselectedRadioFill,
        );
      },
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
