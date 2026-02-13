import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

import '../theme/guest_pay_bill_theme.dart';

class GuestPayBillReadOnlyBox extends StatelessWidget {
  final String text;

  const GuestPayBillReadOnlyBox({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: GuestPayBillTheme.fieldBg,
        borderRadius: BorderRadius.circular(GuestPayBillTheme.radius),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontFamily: AppConstants.defaultFontFamily,
          fontWeight: FontWeight.w500,
          color: GuestPayBillTheme.labelText,
        ),
      ),
    );
  }
}
