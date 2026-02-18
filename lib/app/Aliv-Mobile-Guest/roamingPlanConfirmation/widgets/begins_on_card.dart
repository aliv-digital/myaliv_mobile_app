import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../theme/roaming_plan_confirmation_theme.dart';

class BeginsOnCard extends StatelessWidget {
  const BeginsOnCard({
    super.key,
    required this.dateText,
    this.onCalendarTap,
  });

  final String dateText;
  final VoidCallback? onCalendarTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RoamingPlanConfirmationTheme.beginsOnCardBackgroundColor,
        borderRadius: BorderRadius.circular(
          RoamingPlanConfirmationTheme.beginsOnCardRadius,
        ),
      ),
      padding: RoamingPlanConfirmationTheme.beginsOnCardPadding,
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'begins on',
                    style: RoamingPlanConfirmationTheme.beginsOnLabelTextStyle,
                  ),
                  TextSpan(
                    text: ' | ',
                    style: RoamingPlanConfirmationTheme.beginsOnDateTextStyle,
                  ),
                  TextSpan(
                    text: dateText,
                    style: RoamingPlanConfirmationTheme.beginsOnDateTextStyle,
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(
            width: RoamingPlanConfirmationTheme.beginsOnCardTextToIconGap,
          ),
          InkWell(
            onTap: onCalendarTap,
            borderRadius: BorderRadius.circular(8),
            child: SvgPicture.asset(
              AssetConstant.dateIconSVG,
              width: RoamingPlanConfirmationTheme.beginsOnCardCalendarIconSize,
              height: RoamingPlanConfirmationTheme.beginsOnCardCalendarIconSize,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
