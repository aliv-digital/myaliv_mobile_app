import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

import '../theme/guest_pay_bill_theme.dart';

class GuestPayBillRequiredLabel extends StatelessWidget {
  final String text;

  const GuestPayBillRequiredLabel({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text, style: GuestPayBillTheme.labelStyle()),
        const Text(
          '*',
          style: TextStyle(
            color: Colors.red,
            fontSize: 13,
            fontFamily: AppConstants.defaultFontFamily,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
