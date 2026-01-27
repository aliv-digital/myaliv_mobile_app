import 'package:flutter/material.dart';
import '../theme/refer_friend_prepaid_theme.dart';

class ReferFriendPrepaidLabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final String value;
  final ValueChanged<String> onChanged;

  const ReferFriendPrepaidLabeledField({
    super.key,
    required this.label,
    required this.hint,
    required this.keyboardType,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ReferFriendPrepaidTheme.label),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: ReferFriendPrepaidTheme.fieldBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ReferFriendPrepaidTheme.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            keyboardType: keyboardType,
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9CA3AF),
              ),
            ),
            style: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
