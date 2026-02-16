import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: const Color(0xFFDDDAF0),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          shadows: [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 16,
              offset: Offset(8, 10),
              spreadRadius: 0,
            )
          ],),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(8),
      //   border: Border.all(color: ReferFriendPrepaidTheme.border),
      //   boxShadow: const [
      //     BoxShadow(
      //       color: Color(0x14000000),
      //       blurRadius: 10,
      //       offset: Offset(0, 6),
      //     ),
      //   ],
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                item.code,
                style: const TextStyle(
                  color: const Color(0xFF222222),
                  fontSize: 20,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: item.code));
                  onCopy();
                },
                borderRadius: BorderRadius.circular(100),
                child: SvgPicture.asset('assets/icons/copy.svg')
              ),
              const Spacer(),
              if ((item.expiryLabel ?? '').isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: ShapeDecoration(
                    color: Colors.white /* 1 */,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0xFFDD2F37),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    item.expiryLabel!,
                    style: TextStyle(
                      color: const Color(0xFFD92C20) /* Colors-Text-text-error-primary-(600) */,
                      fontSize: 12,
                      fontFamily: 'CircularPro',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.email,
            style: const TextStyle(
              color: const Color(0xFF222222),
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              height: 1.43,
              letterSpacing: 0.10,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _Meta(label: 'Sent Date', value: item.sentDate)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Container(width: 1, height: 34, color: ReferFriendPrepaidTheme.border),
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF222222),
              fontSize: 13,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF222222),
              fontSize: 16,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
