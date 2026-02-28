import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/refer_friend_response_prepaid_theme.dart';

class ReferFriendResponsePrepaidReferralRow extends StatelessWidget {
  final String code;
  final VoidCallback onCopied;

  const ReferFriendResponsePrepaidReferralRow({
    super.key,
    required this.code,
    required this.onCopied,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 38,

            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: ReferFriendResponsePrepaidTheme.border),
            ),
            child: Text(
              code,
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: ReferFriendResponsePrepaidTheme.muted,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: code));
            onCopied();
          },
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: ReferFriendResponsePrepaidTheme.border),
            ),
            child: Row(
              children: const [
                Icon(Icons.copy, size: 16, color: ReferFriendResponsePrepaidTheme.brand),
                SizedBox(width: 6),
                Text(
                  'copy',
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: ReferFriendResponsePrepaidTheme.brand,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
