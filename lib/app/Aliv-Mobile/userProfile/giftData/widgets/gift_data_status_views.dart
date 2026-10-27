import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/theme/gift_data_theme.dart';

/// Full-screen "something went wrong" view with a retry CTA. Rendered by the
/// gift-data screen when the initial `data-share-status` load errors.
class GiftDataErrorView extends StatelessWidget {
  const GiftDataErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GiftDataTheme.pageHGap),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: GiftDataTheme.sectionLabel,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: GiftDataTheme.ctaHeight,
              width: 180,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GiftDataTheme.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                onPressed: onRetry,
                child: const Text('retry', style: GiftDataTheme.ctaLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the sender account is not eligible to gift data (rare now that
/// the sender-side `can-send-data-share` call is skipped on load, but kept
/// for the future case where the submit path returns an ineligibility code).
class GiftDataIneligibleView extends StatelessWidget {
  const GiftDataIneligibleView({super.key, required this.reason});

  final String? reason;

  @override
  Widget build(BuildContext context) {
    final suffix = (reason == null || reason!.isEmpty) ? '' : '\n($reason)';
    return Padding(
      padding: const EdgeInsets.all(GiftDataTheme.pageHGap),
      child: Center(
        child: Text(
          'this account is not eligible to send a data gift$suffix',
          textAlign: TextAlign.center,
          style: GiftDataTheme.sectionLabel,
        ),
      ),
    );
  }
}
