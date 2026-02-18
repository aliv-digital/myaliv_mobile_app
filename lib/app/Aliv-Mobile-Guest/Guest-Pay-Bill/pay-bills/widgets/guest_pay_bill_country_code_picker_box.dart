import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/appConstants.dart';

import '../model/guest_pay_bill_models.dart';
import '../theme/guest_pay_bill_theme.dart';

class GuestPayBillCountryCodePickerBox extends StatelessWidget {
  final PayBillCountry country;
  final bool showArrow;
  final VoidCallback? onTap;

  const GuestPayBillCountryCodePickerBox({
    super.key,
    required this.country,
    required this.showArrow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String assetIsoCode = country.isoCode.toUpperCase() == 'AC'
        ? 'sh'
        : country.isoCode.toLowerCase();

    final pickerContent = Container(
      width: 96,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: GuestPayBillTheme.fieldBg,
        borderRadius: BorderRadius.circular(GuestPayBillTheme.radius),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/$assetIsoCode.png',
            package: 'country_pickers',
            width: 26,
            height: 20,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                country.flagEmoji,
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: AppConstants.defaultFontFamily,
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          Text(
            country.dialCode,
            style: const TextStyle(
              color: GuestPayBillTheme.labelText,
              fontSize: 13,
              fontFamily: AppConstants.defaultFontFamily,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (showArrow) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: GuestPayBillTheme.primary,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return pickerContent;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GuestPayBillTheme.radius),
      child: pickerContent,
    );
  }
}
