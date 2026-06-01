import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

/// Single metered bucket row used in both the prepaid usage list and the
/// roaming section of the Usage tab. Title + subtitle on the left, a
/// small progress bar plus `"N% used"` / `"unlimited"` label on the
/// right. Bar palette is driven by `AppUiConfigCubit.userType`
/// (red for postpaid, green for prepaid) — caller doesn't pick the
/// colour, which keeps the active and roaming sections visually
/// consistent without per-row colour wiring.
class UsageLimitRow extends StatelessWidget {
  const UsageLimitRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.percentUsed,
    this.isUnlimited = false,
  });

  final String title;
  final String subtitle;
  final double percentUsed;
  final bool isUnlimited;

  @override
  Widget build(BuildContext context) {
    final HomeUiConfig config = context.watch<AppUiConfigCubit>().state;
    final isPostpaid = config.userType == UserType.postpaid;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _Label(title: title, subtitle: subtitle)),
          _ProgressColumn(
            percentUsed: percentUsed,
            isUnlimited: isUnlimited,
            isPostpaid: isPostpaid,
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF222222),
            fontSize: 12,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF707070),
            fontSize: 12,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ProgressColumn extends StatelessWidget {
  const _ProgressColumn({
    required this.percentUsed,
    required this.isUnlimited,
    required this.isPostpaid,
  });

  final double percentUsed;
  final bool isUnlimited;
  final bool isPostpaid;

  static const double _barWidth = 80;
  static const double _barHeight = 6;

  @override
  Widget build(BuildContext context) {
    // Prepaid unlimited fills the bar fully (matches home UsageCard);
    // postpaid stays metered even when "unlimited" so the label carries
    // the meaning instead of the bar.
    final showFullGreen = isUnlimited && !isPostpaid;
    final fraction =
        showFullGreen ? 1.0 : percentUsed.clamp(0.0, 1.0);
    final fillColor =
        isPostpaid ? const Color(0xFFDD3038) : const Color(0xFF17B26A);
    final bgColor =
        isPostpaid ? const Color(0x26DD3038) : const Color(0x2617B26A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: _barWidth,
            height: _barHeight,
            child: Stack(
              children: [
                Container(color: bgColor),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _barWidth * fraction,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        fillColor.withValues(alpha: 0),
                        fillColor,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isUnlimited
              ? 'unlimited'
              : '${(percentUsed.clamp(0.0, 1.0) * 100).round()}% used',
          style: const TextStyle(
            color: Color(0xFF707070),
            fontSize: 12,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
