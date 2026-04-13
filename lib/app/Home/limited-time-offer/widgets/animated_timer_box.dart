import 'package:flutter/material.dart';

/// Animated timer box with slide transition when numbers change
///
/// Shows smooth vertical slide animation when the timer value updates.
class AnimatedTimerBox extends StatelessWidget {
  final String value;
  final String label;
  final bool compact;

  const AnimatedTimerBox(
    this.value,
    this.label, {
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelSize = compact ? 9.0 : 10.0;
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 3, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 10);

    return Container(
      height: 64,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated number value
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              // Slide transition from bottom to top
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Text(
              value,
              key: ValueKey<String>(value), // Key triggers animation on change
              maxLines: 1,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                color: Color(0xFF0F1313),
                fontSize: 20,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.10,
              ),
            ),
          ),
          const SizedBox(height: 2),
          // Static label
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: const Color(0xFF0F1313),
              fontSize: labelSize,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
              letterSpacing: 0.05,
            ),
          ),
        ],
      ),
    );
  }
}
