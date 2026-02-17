import 'package:flutter/material.dart';

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
            style: TextStyle(
              color: GuestPayBillTheme.labelText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: services
              .map(
                (service) => DropdownMenuItem(
                  value: service,
                  child: Text(
                    service.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: GuestPayBillTheme.labelText,
                    ),
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
