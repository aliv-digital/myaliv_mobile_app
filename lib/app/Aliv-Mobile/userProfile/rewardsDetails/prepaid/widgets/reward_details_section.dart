import 'package:flutter/material.dart';
import '../theme/reward_details_theme.dart';

class RewardDetailsSection extends StatelessWidget {
  final String label;
  final String value;

  const RewardDetailsSection({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF1C1C1C) /* Black-100% */,
            fontSize: 14,
            fontFamily: 'Circular Pro',
            fontWeight: FontWeight.w700,
            height: 1.43,
          ),
          // style: RewardDetailsTheme.t(
          //   12,
          //   weight: FontWeight.w700,
          //   color: RewardDetailsTheme.textBlack,
          // ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF707070),
            fontSize: 14,
            fontFamily: 'Circular Pro',
            fontWeight: FontWeight.w500,
            height: 1.43,
          ),
          // style: RewardDetailsTheme.t(
          //   13,
          //   weight: FontWeight.w400,
          //   color: RewardDetailsTheme.textGrey,
          //   height: 1.25,
          // ),
        ),
      ],
    );
  }
}
