import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../theme/home_plan_confirmation_theme.dart';

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
        color: HomePlanConfirmationTheme.beginsOnCardBackgroundColor,
        borderRadius: BorderRadius.circular(
          HomePlanConfirmationTheme.beginsOnCardRadius,
        ),
      ),
      padding: HomePlanConfirmationTheme.beginsOnCardPadding,
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'begins on',
                    style: HomePlanConfirmationTheme.beginsOnLabelTextStyle,
                  ),
                  TextSpan(
                    text: ' | ',
                    style: HomePlanConfirmationTheme.beginsOnDateTextStyle,
                  ),
                  TextSpan(
                    text: dateText,
                    style: HomePlanConfirmationTheme.beginsOnDateTextStyle,
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(
            width: HomePlanConfirmationTheme.beginsOnCardTextToIconGap,
          ),
          InkWell(
            onTap: onCalendarTap,
            borderRadius: BorderRadius.circular(8),
            child: SvgPicture.asset(
              AssetConstant.dateIconSVG,
              width: HomePlanConfirmationTheme.beginsOnCardCalendarIconSize,
              height: HomePlanConfirmationTheme.beginsOnCardCalendarIconSize,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
