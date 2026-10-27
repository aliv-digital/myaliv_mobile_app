import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

/// Pill-style chip showing the sender's remaining giftable allowance:
///   "[wifi]  you have 4 gb available to send"
class AvailableDataChip extends StatelessWidget {
  const AvailableDataChip({super.key, required this.amountLabel});

  final String amountLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: GiftDataTheme.textLightGrey,
        borderRadius: BorderRadius.circular(GiftDataTheme.fieldRadius),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            AssetConstant.wifiIconSVG,
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(
              GiftDataTheme.accentOrange,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 10),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'you have ',
                  style: GiftDataTheme.availableText,
                ),
                TextSpan(
                  text: amountLabel,
                  style: GiftDataTheme.availableAmount,
                ),
                const TextSpan(
                  text: ' available to send',
                  style: GiftDataTheme.availableText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
