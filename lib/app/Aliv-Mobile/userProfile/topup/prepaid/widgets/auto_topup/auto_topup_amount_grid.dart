import 'package:flutter/material.dart';
import '../../theme/top_up_prepaid_theme.dart';

/// Grid widget for selecting preset top-up amounts.
class AutoTopupAmountGrid extends StatelessWidget {
  /// Selected amount. Null means no selection.
  final int? selectedAmount;
  final ValueChanged<int> onAmountSelected;

  /// Preset amounts to display in the grid.
  static const List<int> presetAmounts = [10, 15, 20, 25, 30, 35];

  const AutoTopupAmountGrid({
    super.key,
    this.selectedAmount,
    required this.onAmountSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: presetAmounts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, index) {
        final amount = presetAmounts[index];
        final isSelected = selectedAmount != null && amount == selectedAmount;

        return _AmountTile(
          amount: amount,
          isSelected: isSelected,
          onTap: () => onAmountSelected(amount),
        );
      },
    );
  }
}

/// Individual amount tile in the grid.
class _AmountTile extends StatelessWidget {
  final int amount;
  final bool isSelected;
  final VoidCallback onTap;

  const _AmountTile({
    required this.amount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: TopUpPrepaidTheme.amountBorderGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : TopUpPrepaidTheme.lightBg,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            '\$ $amount.00',
            style: TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.43,
              color: isSelected ? Colors.black : TopUpPrepaidTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
