import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../model/support_models.dart';

class QuickHelpContent extends StatelessWidget {
  final SupportQuickHelpInfo info;
  final VoidCallback onCallTap;

  const QuickHelpContent({
    super.key,
    required this.info,
    required this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            info.title,
            style: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x0C000000),
                  blurRadius: 16,
                  offset: Offset(8, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                SvgPicture.asset(info.assetPath),
                const SizedBox(height: 8),
                CallSupportCard(info: info, onTap: onCallTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CallSupportCard extends StatelessWidget {
  final SupportQuickHelpInfo info;
  final VoidCallback onTap;

  const CallSupportCard({super.key, required this.info, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: info.leadingText,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: info.dialNumber,
              style: const TextStyle(
                color: Color(0xFF645D9C),
                fontSize: 18,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: info.trailingText,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
