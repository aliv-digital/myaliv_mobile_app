import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

class NoRewardsPrepaid extends StatelessWidget {
  final String prefixText;   // "looks like ... visit "
  final String linkText;     // "bealiv.com/\ndeals"
  final String suffixText;   // " to discover ...!"
  final VoidCallback onLinkPressed;

  const NoRewardsPrepaid({
    super.key,
    required this.prefixText,
    required this.linkText,
    required this.suffixText,
    required this.onLinkPressed,
  });

  @override
  Widget build(BuildContext context) {
    const cardRadius = 16.0;
    const cardHeight = 210.0;

    final baseStyle = const TextStyle(
      fontSize: 14, // figma-like bigger
      fontFamily: 'CircularPro',
      fontWeight: FontWeight.w500,
      color: Colors.black,
      height: 1.30,
    );

    final linkStyle = baseStyle.copyWith(
      fontWeight: FontWeight.w700,
      color: const Color(0xFF4B4ACF), // purple-blue like figma
      decoration: TextDecoration.underline,
      decorationThickness: 2,
      height: 1.25,
    );

    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              AssetConstant.rewardsCardBackgroundPNG,
              fit: BoxFit.cover,
            ),

            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 22),
                padding: const EdgeInsets.fromLTRB(26, 20, 26, 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFF3B30),
                    width: 1.5,
                  ),
                ),
                child: Text.rich(
                  TextSpan(
                    style: baseStyle,
                    children: [
                      TextSpan(text: prefixText),
                      TextSpan(
                        text: linkText,
                        style: linkStyle,
                        recognizer: TapGestureRecognizer()..onTap = onLinkPressed,
                      ),
                      TextSpan(text: suffixText),
                    ],
                  ),
                  textAlign: TextAlign.left,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
