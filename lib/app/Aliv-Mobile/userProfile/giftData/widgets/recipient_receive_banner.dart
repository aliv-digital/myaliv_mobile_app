import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';

/// Bordered recipient-capacity banner shown just above the Continue CTA once
/// the two recipient fields match and are 10 digits long.
///
///   (i)  (242)-899-9999 can receive up to 2gb
class RecipientReceiveBanner extends StatelessWidget {
  const RecipientReceiveBanner({
    super.key,
    required this.recipientLabel,
    required this.maxLabel,
  });

  final String recipientLabel;
  final String maxLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GiftDataTheme.pageBg,
        border: Border.all(color: GiftDataTheme.bannerBorder, width: 1),
        borderRadius: BorderRadius.circular(GiftDataTheme.fieldRadius),
      ),
      child: Row(
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
          Expanded(
            child: Text(
              '$recipientLabel can receive up to $maxLabel',
              style: GiftDataTheme.bannerText,
            ),
          ),
        ],
      ),
    );
  }
}
