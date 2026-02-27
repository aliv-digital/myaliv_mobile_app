import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

import '../model/guest_pay_bill_models.dart';
import '../theme/guest_pay_bill_theme.dart';

class GuestPayBillServiceDropdown extends StatelessWidget {
  final List<BillService> services;
  final BillService? selected;
  final ValueChanged<BillService?> onChanged;

  const GuestPayBillServiceDropdown({
    super.key,
    required this.services,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GuestPayBillTheme.fieldBg,
        borderRadius: BorderRadius.circular(GuestPayBillTheme.radius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BillService>(
          isExpanded: true,
          value: selected,
          hint: const Text(
            'ALIV Postpaid',
            style: GuestPayBillTheme.inputHintTextStyle,
          ),
          icon: SizedBox(
            width: 20,
            height: 20,
            child: SvgPicture.asset(
              AssetConstant.downbluArrowSVG,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
          items: services
              .map(
                (service) => DropdownMenuItem(
                  value: service,
                  child: Text(
                    service.label,
                    style: GuestPayBillTheme.inputTextStyle,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
