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
            borderRadius: BorderRadius.circular(8),
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
                color: const Color(0xFF707070),
                fontSize: 14,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
                height: 1.43,
              ),
            ),
            style: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
