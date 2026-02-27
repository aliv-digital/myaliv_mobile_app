import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../theme/add_ons_confirmation_theme.dart';

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
        color: AddOnsConfirmationTheme.beginsOnCardBackgroundColor,
        borderRadius: BorderRadius.circular(
          AddOnsConfirmationTheme.beginsOnCardRadius,
        ),
      ),
      padding: AddOnsConfirmationTheme.beginsOnCardPadding,
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'begins on',
                    style: AddOnsConfirmationTheme.beginsOnLabelTextStyle,
                  ),
                  TextSpan(
                    text: ' | ',
                    style: AddOnsConfirmationTheme.beginsOnDateTextStyle,
                  ),
                  TextSpan(
                    text: dateText,
                    style: AddOnsConfirmationTheme.beginsOnDateTextStyle,
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(
            width: AddOnsConfirmationTheme.beginsOnCardTextToIconGap,
          ),
          InkWell(
            onTap: onCalendarTap,
            borderRadius: BorderRadius.circular(8),
            child: SvgPicture.asset(
              AssetConstant.dateIconSVG,
              width: AddOnsConfirmationTheme.beginsOnCardCalendarIconSize,
              height: AddOnsConfirmationTheme.beginsOnCardCalendarIconSize,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
