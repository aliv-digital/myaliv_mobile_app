import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

class ReviewInvoicePostpaidTheme {
  static const Color appBarColor = Color(0xFF6B66A6);
  static const Color cardBg = Colors.white;
  static const Color pageBg = Color(0xFFF6F7FB);

  static const Color title = Color(0xFF1F1F1F);
  static const Color label = Color(0xFF9AA0A6);
  static const Color value = Color(0xFF1F1F1F);
  static const Color amount = Color(0xFF6B66A6);

  static const double radius = 12;
  static const String fontFamily = 'CircularPro';

  static TextStyle invoiceNo(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: title,
  );

  static TextStyle metaLabel(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: label,
  );

  static TextStyle metaValue(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: value,
  );

  static TextStyle amountStyle(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: amount,
  );
}

class ReviewInvoicePostpaidAssets {
  static const String pdfSvg = AssetConstant.pdfIconSVG;
}
