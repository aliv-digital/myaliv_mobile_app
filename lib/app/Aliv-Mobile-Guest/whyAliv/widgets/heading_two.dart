
import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/whyAliv/theme/why_aliv_theme.dart';

class HeadingTwo extends StatelessWidget {
  const HeadingTwo({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        height: 1.25,
        fontFamily: 'CircularPro',
        fontWeight: FontWeight.w700,
        color: WhyAlivTheme.headingColor,
      ),
    );
  }
}