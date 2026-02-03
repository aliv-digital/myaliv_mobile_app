import 'package:flutter/material.dart';

class RevAppBarSliver extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  RevAppBarSliver({
    required this.height,
    required this.child,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(covariant RevAppBarSliver oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
