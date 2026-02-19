import 'package:flutter/material.dart';

import '../postpaid_usage_item.dart';

class PostpaidUsageTile extends StatelessWidget {
  final PostpaidUsageItem item;

  const PostpaidUsageTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        // color: Colors.white,
        // border: Border.all(color: const Color(0xFFDBDBDB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LEFT SIDE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 12,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF707070),
                    fontSize: 12,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          /// RIGHT SIDE
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildProgressBar(),
              const SizedBox(height: 6),
              Text(
                item.trailingText,
                style: const TextStyle(
                  color: Color(0xFF707070),
                  fontSize: 12,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    if (item.isUnlimited) {
      return Container(
        width: 80,
        height: 5,
        decoration: BoxDecoration(
          color: const Color(0xFF17B26A),
          borderRadius: BorderRadius.circular(30),
        ),
      );
    }

    if (item.progress == null) {
      return Container(
        width: 80,
        height: 5,
        decoration: BoxDecoration(
          color: const Color(0x3F808080),
          borderRadius: BorderRadius.circular(30),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: SizedBox(
        width: 80,
        height: 5,
        child: LinearProgressIndicator(
          value: item.progress,
          backgroundColor: const Color(0x2617B26A),
          valueColor: const AlwaysStoppedAnimation(Color(0xFF17B26A)),
        ),
      ),
    );
  }
}
