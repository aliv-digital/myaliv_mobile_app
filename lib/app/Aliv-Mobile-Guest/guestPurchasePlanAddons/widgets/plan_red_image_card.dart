import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../theme/guest_purchase_plan_add_ons_theme.dart';

/// Reusable red plan card using design image background.
/// Texts are drawn on top of the image using fixed, pixel-safe positions.
class PlanRedImageCard extends StatelessWidget {
  const PlanRedImageCard({
    super.key,
    required this.planLabel,
    required this.planName,
    required this.activeLabel,
    required this.activeDate,
    required this.expireLabel,
    required this.expireDate,
    this.expireTime = '',
    this.topRight,
    this.maxWidth = 340,
    this.height = 184,
    this.borderRadius = 12,
  });

  final String planLabel;
  final String planName;
  final String activeLabel;
  final String activeDate;
  final String expireLabel;
  final String expireDate;

  /// Optional expire time subtitle (e.g. `"11:59 PM"`), rendered on a
  /// second line under [expireDate]. Mirrors prepaid's active-plan card
  /// at `active_plan_card_with_data.dart:124`. Pass empty to hide.
  final String expireTime;

  final Widget? topRight;

  final double maxWidth;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: maxWidth),
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  AssetConstant.planRedCardPNG,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: GuestPurchasePlanAddOnsTheme.planRed),
                ),
                Padding(
                  padding:
                      GuestPurchasePlanAddOnsTheme.planRedCardContentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            planLabel,
                            style: GuestPurchasePlanAddOnsTheme.t(
                              12,
                              weight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          ?topRight,
                        ],
                      ),
                      Text(
                        planName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GuestPurchasePlanAddOnsTheme.t(
                          24,
                          weight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  activeLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontFamily: 'CircularPro',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  expireLabel,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontFamily: 'CircularPro',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                activeDate,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontFamily: 'CircularPro',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.25,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                expireDate,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontFamily: 'CircularPro',
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.25,
                                ),
                              ),
                            ],
                          ),
                          if (expireTime.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                expireTime,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontFamily: 'CircularPro',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
