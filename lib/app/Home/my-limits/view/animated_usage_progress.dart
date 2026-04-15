import 'package:flutter/material.dart';

class AnimatedUsageProgress extends StatelessWidget {
  final int percent;
  final double width;
  final double height;

  const AnimatedUsageProgress({
    super.key,
    required this.percent,
    this.width = 120,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = percent.clamp(0, 100);
    final progress = clamped / 100;
    final style = _resolveStyle(clamped);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Stack(
                children: [
                  Container(
                    width: width,
                    height: height,
                    color: style.backgroundColor,
                  ),
                  Container(
                    width: width * value,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: style.gradient,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "$clamped% used",
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

  _ProgressStyle _resolveStyle(int percent) {
    if (percent == 0) {
      return _ProgressStyle(
        backgroundColor: const Color(0x3F808080),
        gradient: const LinearGradient(
          colors: [Colors.transparent, Colors.transparent],
        ),
      );
    }

    if (percent > 80) {
      return _ProgressStyle(
        backgroundColor: const Color(0x26DD3038),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0x00DD3038), Color(0xFFDD3038)],
        ),
      );
    }

    if (percent > 50) {
      return _ProgressStyle(
        backgroundColor: const Color(0x26FFC627),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0x00FFC627), Color(0xFFFFC627)],
        ),
      );
    }

    return _ProgressStyle(
      backgroundColor: const Color(0x2617B26A),
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0x0017B26A), Color(0xFF17B26A)],
      ),
    );
  }
}

class _ProgressStyle {
  final Color backgroundColor;
  final LinearGradient gradient;

  _ProgressStyle({required this.backgroundColor, required this.gradient});
}
