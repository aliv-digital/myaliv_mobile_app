import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../theme/home_roaming_confirmation_theme.dart';

class HomeRoamingConfirmationBeginsOnCard extends StatelessWidget {
  const HomeRoamingConfirmationBeginsOnCard({
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
        color: HomeRoamingConfirmationTheme.beginsOnCardBackgroundColor,
        borderRadius: BorderRadius.circular(
          HomeRoamingConfirmationTheme.beginsOnCardRadius,
        ),
      ),
      padding: HomeRoamingConfirmationTheme.beginsOnCardPadding,
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'begins on',
                    style: HomeRoamingConfirmationTheme.beginsOnLabelTextStyle,
                  ),
                  TextSpan(
                    text: ' | ',
                    style: HomeRoamingConfirmationTheme.beginsOnDateTextStyle,
                  ),
                  TextSpan(
                    text: dateText,
                    style: HomeRoamingConfirmationTheme.beginsOnDateTextStyle,
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(
            width: HomeRoamingConfirmationTheme.beginsOnCardTextToIconGap,
          ),
          InkWell(
            onTap: onCalendarTap,
            borderRadius: BorderRadius.circular(8),
            child: SvgPicture.asset(
              AssetConstant.dateIconSVG,
              width: HomeRoamingConfirmationTheme.beginsOnCardCalendarIconSize,
              height: HomeRoamingConfirmationTheme.beginsOnCardCalendarIconSize,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
