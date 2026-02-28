import 'package:flutter/material.dart';

import '../theme/refer_friend_response_prepaid_theme.dart';

class ReferFriendResponsePrepaidButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const ReferFriendResponsePrepaidButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE9E7F6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: ReferFriendResponsePrepaidTheme.brand,
          ),
        ),
      ),
    );
  }
}
