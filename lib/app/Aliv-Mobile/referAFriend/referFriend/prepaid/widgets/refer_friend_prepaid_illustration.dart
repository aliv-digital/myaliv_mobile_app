import 'package:flutter/material.dart';

class ReferFriendPrepaidIllustration extends StatelessWidget {
  final String assetPath; // user will set later
  final double width;
  final double height;

  const ReferFriendPrepaidIllustration({
    super.key,
    required this.assetPath,
    this.width = 220,
    this.height = 190,
  });

  @override
  Widget build(BuildContext context) {
    if (assetPath.trim().isEmpty) {
      return SizedBox(width: width, height: height);
    }
    return Image.asset(assetPath, width: width, height: height);
  }
}
