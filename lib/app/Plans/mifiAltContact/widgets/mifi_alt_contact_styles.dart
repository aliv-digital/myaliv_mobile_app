import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

class MifiAltContactStyles {
  const MifiAltContactStyles._();

  static const TextStyle bodyText = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF1C1C1C),
    height: 1.4,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF1C1C1C),
  );

  static const TextStyle radioLabel = TextStyle(
    fontFamily: AppConstants.defaultFontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: Color(0xFF1C1C1C),
  );
}
