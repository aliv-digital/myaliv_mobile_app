import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../resources/constants/asset_constants.dart'; // AssetConstant er path

class DefaultBackButton extends StatelessWidget {
  /// default padding: left: 24, top: 53
  final EdgeInsetsGeometry padding;

  /// default alignment: বাম দিকে
  final Alignment alignment;

  /// custom action লাগলে onPressed দেবে, নাহলে Navigator.maybePop()
  final VoidCallback? onPressed;

  /// SVG icon-এর width / height
  final double iconWidth;
  final double iconHeight;

  const DefaultBackButton({
    super.key,
    this.padding = const EdgeInsets.only(left: 24, top: 53),
    this.alignment = Alignment.centerLeft,
    this.onPressed,
    this.iconWidth = 16.64,
    this.iconHeight = 14.43,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: SvgPicture.asset(
            AssetConstant.backButtonSVG,
            width: iconWidth,
            height: iconHeight,
          ),
          onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}
