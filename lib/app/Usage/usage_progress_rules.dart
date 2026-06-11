import 'package:flutter/material.dart';

/// Shared rules for usage progress bars.
///
/// Input value is always the fraction used:
/// 0.0 = 0% used, 1.0 = 100% used.
///
/// Color rule for metered buckets:
/// 0% to 50% = green
/// >50% to 80% = yellow
/// >80% to 100% = red
///
/// Unlimited buckets always render as a full green bar.
class UsageProgressRules {
  const UsageProgressRules._();

  static const Color green = Color(0xFF17B26A);
  static const Color greenBackground = Color(0x2617B26A);

  static const Color yellow = Color(0xFFFFC627);
  static const Color yellowBackground = Color(0x26FFC627);

  static const Color red = Color(0xFFDD3038);
  static const Color redBackground = Color(0x26DD3038);

  static const Duration animationDuration = Duration(milliseconds: 300);

  static int usedPercent(double usedFraction) {
    final clampedFraction = usedFraction.clamp(0.0, 1.0);
    return (clampedFraction * 100).round();
  }

  static double fillFraction({
    required double usedFraction,
    required bool isUnlimited,
  }) {
    if (isUnlimited) {
      return 1.0;
    }

    return usedFraction.clamp(0.0, 1.0);
  }

  static UsageProgressStyle styleFor({
    required double usedFraction,
    required bool isUnlimited,
  }) {
    if (isUnlimited) {
      return const UsageProgressStyle(
        color: green,
        backgroundColor: greenBackground,
      );
    }

    final percent = usedPercent(usedFraction);

    if (percent > 80) {
      return const UsageProgressStyle(
        color: red,
        backgroundColor: redBackground,
      );
    }

    if (percent > 50) {
      return const UsageProgressStyle(
        color: yellow,
        backgroundColor: yellowBackground,
      );
    }

    return const UsageProgressStyle(
      color: green,
      backgroundColor: greenBackground,
    );
  }

  static Widget progressBar({
    required double usedFraction,
    required bool isUnlimited,
    double width = 80,
    double height = 6,
    double borderRadius = 8,
  }) {
    final style = styleFor(
      usedFraction: usedFraction,
      isUnlimited: isUnlimited,
    );

    final fraction = fillFraction(
      usedFraction: usedFraction,
      isUnlimited: isUnlimited,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Container(color: style.backgroundColor),
            AnimatedContainer(
              duration: animationDuration,
              width: width * fraction,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: LinearGradient(
                  colors: [
                    style.color.withValues(alpha: 0),
                    style.color,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UsageProgressStyle {
  const UsageProgressStyle({
    required this.color,
    required this.backgroundColor,
  });

  final Color color;
  final Color backgroundColor;
}
