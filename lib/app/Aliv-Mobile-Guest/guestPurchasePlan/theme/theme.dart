
import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';
import 'package:myaliv_mobile_app/resources/extentions/hex_color.dart';

class GuestPurchasePlanTheme {
  // Screen background and app bar
  static final Color screenBackground = HexColor.fromHex('#F6F6F8');
  static final Color appBarColor = HexColor.fromHex('#5D5A8B');

  // Brand + shared colors
  static final Color brandPurple = HexColor.fromHex('#5D5A8B');
  static final Color dividerColor = HexColor.fromHex('#707070');
  static final Color subtitleColor = HexColor.fromHex('#707070');
  static final Color scrollBarBackgroundColor = HexColor.fromHex('#F2F2F7');
  static final Color viewDetailsButtonColor = HexColor.fromHex('#F2F1F9');
  static final Color addOnCardBackground = HexColor.fromHex('#F6F6FB');

  // Metric label colors
  static final Color talkMinsColor = HexColor.fromHex('#00B3E3');
  static final Color smsColor = HexColor.fromHex('#5146A8');
  static final Color dataColor = HexColor.fromHex('#FF6C36');
  static final Color bonusDataColor = HexColor.fromHex('#00C4B3');
  static final Color intlTalkTextColor = HexColor.fromHex('#FF6C36');
  static final Color mmsColor = HexColor.fromHex('#00C4B3');

  // Section title above plan list
  static final TextStyle sectionTitle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
    color: Colors.black.withValues(alpha: 0.75),
  );

  // Error message in screen
  static final TextStyle errorText = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  // Add-on card title
  static final TextStyle addOnTitle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: Colors.black,
  );

  // Add-on label (e.g., data balance)
  static final TextStyle addOnLabel = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: HexColor.fromHex('#FF5A3C'),
  );

  // Add-on value (e.g., 1GB)
  static final TextStyle addOnValue = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: Colors.black,
  );

  // Add-on price pill
  static final TextStyle addOnPrice = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: brandPurple,
  );

  // Plan tabs label
  static final TextStyle tabLabel = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // Plan tabs bar colors
  static final Color tabBarBackground = Colors.white;
  static final Color tabTextInactive = HexColor.fromHex('#8B8B8B');
  static final Color tabDivider = HexColor.fromHex('#E6E6EC');

  // Plan tab label (active)
  static final TextStyle tabLabelActive = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: brandPurple,
  );

  // Plan tab label (inactive)
  static final TextStyle tabLabelInactive = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: tabTextInactive,
  );

  // Plan metric title (e.g., mins/data)
  static final TextStyle metricTitle = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: brandPurple,
  );

  // Plan metric value (main number)
  static final TextStyle metricValue = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: Colors.black,
  );

  // Plan metric sub text
  static final TextStyle metricSub = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 10.5,
    fontWeight: FontWeight.w400,
    color: HexColor.fromHex('#8B8B8B'),
  );
}
