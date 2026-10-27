import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';

/// One of the three selectable chips in the "choose gift amount" row.
/// Selected = pale-purple fill + 1.5px purple border + filled check circle.
/// Unselected = white fill + 1px grey border + empty grey circle.
class GiftAmountOptionChip extends StatelessWidget {
  const GiftAmountOptionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: GiftDataTheme.fieldHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: selected ? GiftDataTheme.chipBg : GiftDataTheme.pageBg,
        borderRadius: BorderRadius.circular(GiftDataTheme.fieldRadius),
        border: selected
            ? Border.all(color: GiftDataTheme.chipSelectedBorder, width: 1.5)
            : Border.all(color: GiftDataTheme.bannerBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: selected
                  ? GiftDataTheme.chipLabelSelected
                  : GiftDataTheme.chipLabel,
            ),
          ),
          _RadioMark(selected: selected),
        ],
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: content,
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        width: 18,
        height: 18,
        decoration: const BoxDecoration(
          color: GiftDataTheme.chipSelectedBorder,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 12, color: Colors.white),
      );
    }
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: GiftDataTheme.chipRadioEmpty, width: 1.5),
      ),
    );
  }
}
