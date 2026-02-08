import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomTabIcon extends StatelessWidget {
  final String asset;
  final bool isActive;

  const BottomTabIcon({
    super.key,
    required this.asset,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        isActive
            ? const Color(0xFF645D9C) // active purple
            : const Color(0xFFB0AEDA), // inactive
        BlendMode.srcIn,
      ),
    );
  }
}
