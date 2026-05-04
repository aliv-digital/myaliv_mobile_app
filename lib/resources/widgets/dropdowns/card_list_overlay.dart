import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/savedCards/models/saved_card_model.dart';
import 'dropdown_content_widgets.dart';

class CardListOverlay extends StatelessWidget {
  final LayerLink layerLink;
  final List<SavedCardModel> cards;
  final String? selectedToken;
  final ValueChanged<SavedCardModel> onCardSelected;

  const CardListOverlay({
    super.key,
    required this.layerLink,
    required this.cards,
    required this.selectedToken,
    required this.onCardSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: MediaQuery.of(context).size.width - 48,
      child: CompositedTransformFollower(
        link: layerLink,
        offset: const Offset(0, 56),
        showWhenUnlinked: false,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: cards.length,
              itemBuilder: (context, index) => _CardListItem(
                card: cards[index],
                isSelected: cards[index].token == selectedToken,
                isFirst: index == 0,
                isLast: index == cards.length - 1,
                onTap: () => onCardSelected(cards[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardListItem extends StatelessWidget {
  final SavedCardModel card;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _CardListItem({
    required this.card,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(12) : Radius.zero,
        bottom: isLast ? const Radius.circular(12) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                card.displayLabel,
                style: const TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 15,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: dropdownSelectedAccent,
              ),
          ],
        ),
      ),
    );
  }
}
