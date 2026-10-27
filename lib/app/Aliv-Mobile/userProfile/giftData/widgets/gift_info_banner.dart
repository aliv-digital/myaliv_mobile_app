import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';

/// Bordered banner displayed above the "continue" CTA:
///   (i)  "until April 08, 2027 you can gift up to 4gb"
class GiftInfoBanner extends StatelessWidget {
  const GiftInfoBanner({
    super.key,
    required this.validUntilLabel,
    required this.senderMaxLabel,
  });

  final String validUntilLabel;
  final String senderMaxLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 12.0, 12.0),
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
              'until $validUntilLabel you can gift up to $senderMaxLabel',
              style: GiftDataTheme.bannerText,
            ),
          ),
        ],
      ),
    );
  }
}
