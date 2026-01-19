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
          style: RewardDetailsTheme.t(
            12,
            weight: FontWeight.w700,
            color: RewardDetailsTheme.textBlack,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: RewardDetailsTheme.t(
            13,
            weight: FontWeight.w400,
            color: RewardDetailsTheme.textGrey,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}
