import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Phone item widget for dropdown menu items
class PhoneDropdownItem extends StatelessWidget {
  final String number;
  final bool isPrimary;
  final bool showRadio;

  const PhoneDropdownItem({
    super.key,
    required this.number,
    required this.isPrimary,
    this.showRadio = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayNumber = number.isNotEmpty ? number : 'No phone number';

    return Row(
      children: [
        SvgPicture.asset('assets/icons/Phone.svg'),
        const SizedBox(width: 8),
        Text(displayNumber),
        const SizedBox(width: 8),
        if (isPrimary)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF00C4B3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Primary',
              style: TextStyle(
                color: Color(0xFF463C6E),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

/// Phone item widget for selected dropdown value (with checkmark)
class PhoneDropdownSelectedItem extends StatelessWidget {
  final String number;
  final bool isPrimary;

  const PhoneDropdownSelectedItem({
    super.key,
    required this.number,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final displayNumber = number.isNotEmpty ? number : 'No phone number';

    return Row(
      children: [
        SvgPicture.asset('assets/icons/Phone.svg'),
        const SizedBox(width: 8),
        Text(displayNumber),
        const SizedBox(width: 8),
        if (isPrimary)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF00C4B3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Primary',
              style: TextStyle(
                color: Color(0xFF463C6E),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const Spacer(),
        SvgPicture.asset('assets/icons/selected.svg'),
      ],
    );
  }
}
