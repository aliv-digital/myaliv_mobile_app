import 'package:flutter/material.dart';

class RevLandingHeroImage extends StatelessWidget {
  const RevLandingHeroImage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.5),
      child: Image.asset(
        'assets/images/rev_top_image.png',
        width: double.infinity,
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
      ),
    );
  }
}
