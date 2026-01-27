import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/refer_friend_prepaid_models.dart';
import '../theme/refer_friend_prepaid_theme.dart';

class ReferFriendPrepaidHistoryCard extends StatelessWidget {
  final ReferralHistoryItem item;
  final VoidCallback onCopy;

  const ReferFriendPrepaidHistoryCard({
    super.key,
    required this.item,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ReferFriendPrepaidTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                item.code,
                style: const TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ReferFriendPrepaidTheme.text,
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: item.code));
                  onCopy();
                },
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.copy, size: 16, color: ReferFriendPrepaidTheme.muted),
                ),
              ),
              const Spacer(),
              if ((item.expiryLabel ?? '').isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFF5A5A)),
                  ),
                  child: Text(
                    item.expiryLabel!,
                    style: const TextStyle(
                      fontFamily: 'CircularPro',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF5A5A),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.email,
            style: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ReferFriendPrepaidTheme.muted,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _Meta(label: 'Sent Date', value: item.sentDate)),
              Container(width: 1, height: 34, color: ReferFriendPrepaidTheme.border),
              Expanded(child: _Meta(label: 'Accepted Date', value: item.acceptedDate)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final String label;
  final String value;

  const _Meta({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: ReferFriendPrepaidTheme.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: ReferFriendPrepaidTheme.text,
            ),
          ),
        ],
      ),
    );
  }
}
