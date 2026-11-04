import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

/// Red error banner shown when recipient check returns an ineligible reason
/// (e.g. `{"Reason": "NoDataSharesActive", "AvailablePlans": []}`).
class GiftDataErrorBanner extends StatelessWidget {
  const GiftDataErrorBanner({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GiftDataTheme.errorBannerRed,
        borderRadius: BorderRadius.circular(GiftDataTheme.fieldRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 24, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: AppConstants.defaultFontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: AppConstants.defaultFontFamily,
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
