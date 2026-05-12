import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:myaliv_mobile_app/resources/extentions/dateformatter.dart';

import '../../start_plan_bottom_sheet.dart';

class ConfirmationBeginOnCard extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onDateChanged;

  const ConfirmationBeginOnCard({
    super.key,
    required this.date,
    required this.onDateChanged,
  });

  Future<void> _openCalendarPickerSheet(BuildContext context) async {
    final pickedDate = await showStartPlanCalendarPickerSheet(
      context,
      initialDate: date,
    );
    if (pickedDate == null) return;
    onDateChanged(pickedDate);
  }

  @override
  Widget build(BuildContext context) {
    final formatted = formatWithOrdinal(date);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'begins on | ',
                  style: TextStyle(fontSize: 14),
                ),
                TextSpan(
                  text: formatted,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF707070),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _openCalendarPickerSheet(context),
            child: SvgPicture.asset('assets/icons/calender_post.svg'),
          ),
        ],
      ),
    );
  }
}
