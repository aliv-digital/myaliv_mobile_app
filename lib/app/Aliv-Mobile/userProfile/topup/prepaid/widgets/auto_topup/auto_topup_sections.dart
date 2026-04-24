import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/purchases/prepaid/widgets/currency_amount_input.dart';
import 'auto_topup_amount_grid.dart';
import 'auto_topup_widgets.dart';
import 'saved_card_dropdown.dart';

/// Card selection section for auto top-up.
class AutoTopupCardSection extends StatelessWidget {
  final SavedCardModel? selectedCard;
  final ValueChanged<SavedCardModel?> onCardSelected;

  const AutoTopupCardSection({
    super.key,
    required this.selectedCard,
    required this.onCardSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AutoTopupSectionLabel('select card'),
        SavedCardDropdown(
          selectedCard: selectedCard,
          onCardSelected: onCardSelected,
        ),
      ],
    );
  }
}

/// Balance threshold section for auto top-up.
class AutoTopupThresholdSection extends StatelessWidget {
  /// The threshold value to display (e.g., 20.0 → "$ 20.00")
  final double value;

  const AutoTopupThresholdSection({
    super.key,
    this.value = 10.0,
  });

  String get _formattedValue => '\$ ${value.abs().toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AutoTopupSectionLabel('when balance falls below'),
        AutoTopupInputField(value: _formattedValue),
        const SizedBox(height: 8),
        Text(
          'amount must be above \$ ${value.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Color(0xFF707070),
            fontSize: 14,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
            height: 1.43,
          ),
        ),
      ],
    );
  }
}

/// Amount selection section for auto top-up.
class AutoTopupAmountSection extends StatelessWidget {
  /// Selected amount. Null means no selection.
  final int? selectedAmount;
  final ValueChanged<int> onAmountSelected;

  /// Whether the section is enabled. Disabled when custom amount is entered.
  final bool enabled;

  const AutoTopupAmountSection({
    super.key,
    this.selectedAmount,
    required this.onAmountSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AutoTopupSectionLabel('select a top-up amount'),
            const SizedBox(height: 10),
            AutoTopupAmountGrid(
              selectedAmount: selectedAmount,
              onAmountSelected: onAmountSelected,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom amount input section for auto top-up.
class AutoTopupCustomAmountSection extends StatelessWidget {
  /// Controller for the custom amount input field.
  final TextEditingController? controller;

  /// Callback when the custom amount value changes.
  final ValueChanged<String>? onChanged;

  const AutoTopupCustomAmountSection({
    super.key,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AutoTopupSectionLabel('custom amount'),
        const SizedBox(height: 8),
        TopUpFormInputField(
          hint: 'enter a custom amount',
          isAmountType: true,
          controller: controller,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
