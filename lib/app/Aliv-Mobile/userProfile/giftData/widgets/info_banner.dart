import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';

/// Inline info banner used in the gift-data form.
///
/// Shape: `(i) <text>`. The icon + gap + copy are identical across both
/// usages; the only difference is the surrounding container:
///   - [bordered] `false` (default) — no fill, no border (e.g. the top
///     `until {date} you can gift up to {X}` line).
///   - [bordered] `true` — white fill + 1px grey border + 8px radius
///     (e.g. the `{recipient} can receive up to {X}` line above the CTA).
class InfoBanner extends StatelessWidget {
  const InfoBanner({super.key, required this.text, this.bordered = false});

  final String text;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: GiftDataTheme.textMuted,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: GiftDataTheme.bannerText)),
      ],
    );

    if (!bordered) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 12, 12),
        child: row,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GiftDataTheme.pageBg,
        border: Border.all(color: GiftDataTheme.bannerBorder, width: 1),
        borderRadius: BorderRadius.circular(GiftDataTheme.fieldRadius),
      ),
      child: row,
    );
  }
}
