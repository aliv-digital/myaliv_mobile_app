import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Format phone number as XXX-XXX-XXXX
String _formatPhone(String phone) {
  // Remove all non-digits
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 10) {
    return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
  }
  if (digits.length == 11 && digits.startsWith('1')) {
    // Handle 1-XXX-XXX-XXXX format
    return '${digits.substring(1, 4)}-${digits.substring(4, 7)}-${digits.substring(7)}';
  }
  // Return original if can't format
  return phone;
}

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
    final displayNumber = number.isNotEmpty
        ? _formatPhone(number)
        : 'No phone number';

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
    final displayNumber = number.isNotEmpty
        ? _formatPhone(number)
        : 'No phone number';

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
