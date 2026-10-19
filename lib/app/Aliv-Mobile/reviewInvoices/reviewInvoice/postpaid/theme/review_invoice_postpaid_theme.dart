import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

class ReviewInvoicePostpaidTheme {
  static const Color appBarColor = Color(0xFF6B66A6);
  static const Color cardBg = Colors.white;
  static const Color pageBg = Color(0xFFF1F2FA);

  static const Color title = Color(0xFF1F1F1F);
  static const Color label = Color(0xFF9AA0A6);
  static const Color value = Color(0xFF1F1F1F);
  static const Color amount = Color(0xFF6B66A6);

  static const double radius = 8;
  static const String fontFamily = 'CircularPro';

  static TextStyle invoiceNo(BuildContext context) => const TextStyle(
    color: const Color(0xFF1C1C1C) /* Black-100% */,
    fontSize: 16,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
  );

  static TextStyle metaLabel(BuildContext context) => const TextStyle(
    color: const Color(0xFF707070),
    fontSize: 12,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w500,
  );

  static TextStyle metaValue(BuildContext context) => const TextStyle(
    color: const Color(0xFF1C1C1C) /* Black-100% */,
    fontSize: 14,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w500,
  );

  static TextStyle amountStyle(BuildContext context) => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: amount,
  );
}

class ReviewInvoicePostpaidAssets {
  static const String pdfSvg = AssetConstant.pdfIconSVG;
}
