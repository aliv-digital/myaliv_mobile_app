import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton placeholder shown while the active plan card is loading.
/// Each block mirrors a real element of the card so the layout doesn't shift.
class ActivePlanCardSkeleton extends StatelessWidget {
  const ActivePlanCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.25),
      highlightColor: Colors.white.withValues(alpha: 0.55),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: "active plan" label + plan name on the left, toggle on the right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _SkeletonBox(width: 60, height: 12),
                  SizedBox(height: 6),
                  _SkeletonBox(width: 140, height: 24),
                ],
              ),
              const Spacer(),
              Row(
                children: const [
                  _SkeletonBox(width: 44, height: 24, radius: 999),
                  SizedBox(width: 8),
                  _SkeletonBox(width: 62, height: 12),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Dates row: active (left) / expire (right)
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _SkeletonBox(width: 36, height: 10),
                  SizedBox(height: 4),
                  _SkeletonBox(width: 70, height: 15),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  _SkeletonBox(width: 36, height: 10),
                  SizedBox(height: 4),
                  _SkeletonBox(width: 70, height: 15),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Button placeholder
          const _SkeletonBox(
            width: double.infinity,
            height: 50,
            radius: 100,
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 6,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
