import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/cubit/saved_cards_state.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/save_credit_card_button.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/widgets/save_new_card_bottom_sheet.dart';
/// Post-3DS-payment "save credit card" affordance. Opens [SaveNewCardBottomSheet]
/// on tap so the user can confirm the expiry date before calling /CreditCard/savenew.
/// Hides itself permanently after a successful save (one-shot).
class SaveNewCardOnReceiptSection extends StatefulWidget {
  const SaveNewCardOnReceiptSection({super.key, required this.orderId});

  final String orderId;

  @override
  State<SaveNewCardOnReceiptSection> createState() =>
      _SaveNewCardOnReceiptSectionState();
}

class _SaveNewCardOnReceiptSectionState
    extends State<SaveNewCardOnReceiptSection> {
  bool _saved = false;

  Future<void> _onTap() async {
    final result = await SaveNewCardBottomSheet.show(
      context,
      orderId: widget.orderId,
    );
    if (!mounted) return;

    if (result == true) {
      setState(() => _saved = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_saved) return const SizedBox.shrink();

    return BlocProvider<SavedCardsCubit>.value(
      value: instance<SavedCardsCubit>(),
      child: BlocBuilder<SavedCardsCubit, SavedCardsState>(
        buildWhen: (p, c) => p.isAddingCard != c.isAddingCard,
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
