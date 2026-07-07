import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/models/new_card_details.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/save_credit_card_button.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';

/// Post-payment "save credit card" affordance. Renders nothing unless a
/// fresh [NewCardDetails] is available; hides itself after a successful
/// save so the button is a true one-shot.
///
/// Reuses [SavedCardsCubit.addCard] — same API path the add/edit-cards
/// screen uses — so no receipt-specific save endpoint or envelope exists.
class SaveCardOnReceiptSection extends StatefulWidget {
  const SaveCardOnReceiptSection({super.key, required this.details});

  final NewCardDetails? details;

  @override
  State<SaveCardOnReceiptSection> createState() =>
      _SaveCardOnReceiptSectionState();
}

class _SaveCardOnReceiptSectionState extends State<SaveCardOnReceiptSection> {
  bool _saved = false;

  Future<void> _onTap() async {
    final details = widget.details;
    if (details == null) return;

    final cubit = instance<SavedCardsCubit>();
    final ok = await cubit.addCard(details);
    if (!mounted) return;

    if (ok) {
      setState(() => _saved = true);
      AppToast.show(
        message: 'your card has been saved successfully',
        type: ToastType.success,
      );
      return;
    }

    final msg = cubit.state.errorMessage?.trim();
    AppToast.show(
      message: (msg == null || msg.isEmpty)
          ? 'Failed to save card. Try again.'
          : msg,
      type: ToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.details == null || _saved) return const SizedBox.shrink();

    return BlocProvider<SavedCardsCubit>.value(
      value: instance<SavedCardsCubit>(),
      child: BlocBuilder<SavedCardsCubit, SavedCardsState>(
        buildWhen: (prev, curr) => prev.isAddingCard != curr.isAddingCard,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SaveCreditCardButton(
              onTap: _onTap,
              isLoading: state.isAddingCard,
            ),
          );
        },
      ),
    );
  }
}
