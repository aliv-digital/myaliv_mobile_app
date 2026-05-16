import 'package:flutter/material.dart';
import '../model/add_or_edit_cards_prepaid_models.dart';
import '../theme/add_or_edit_cards_prepaid_theme.dart';
import 'saved_card_tile.dart';

class PaymentMethodSection extends StatelessWidget {
  final List<SavedCard> cards;
  final Set<String> deletingIds;
  final ValueChanged<String> onDelete;

  const PaymentMethodSection({
    super.key,
    required this.cards,
    required this.deletingIds,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AddOrEditCardsPrepaidTheme.cardBg,
        borderRadius: BorderRadius.circular(AddOrEditCardsPrepaidTheme.radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'payment method',
            style: AddOrEditCardsPrepaidTheme.sectionTitle(),
          ),
          const SizedBox(height: 12),

          if (cards.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'No saved cards',
                style: AddOrEditCardsPrepaidTheme.cardSubTitle(),
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < cards.length; i++) ...[
                  // ✅ Each saved card is its own bordered rounded tile
                  SavedCardTile(
                    card: cards[i],
                    deleting: deletingIds.contains(cards[i].id),
                    onDelete: () => onDelete(cards[i].id),
                  ),

                  // ✅ Gap between tiles (NOT divider)
                  if (i != cards.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
