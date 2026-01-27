import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ReferFriendResponsePrepaidIcon extends StatelessWidget {
  /// ✅ You will set this SVG path later.
  /// If empty => fallback icon shows.
  final String assetPath;

  const ReferFriendResponsePrepaidIcon({
    super.key,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final hasAsset = assetPath.trim().isNotEmpty;

    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer light green circle
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8F7EF),
            ),
          ),

          // Inner green circle
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2BB673),
            ),
            child: Center(
              child: hasAsset
                  ? SvgPicture.asset(
                assetPath,
                width: 18,
                height: 18,
                // NOTE: If your SVG uses its own color, leave as-is.
                // If you want to force white icon, tell me—I'll add a color override.
              )
                  : const Icon(
                Icons.sms_outlined,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
