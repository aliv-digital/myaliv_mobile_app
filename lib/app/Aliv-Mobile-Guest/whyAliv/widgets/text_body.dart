import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/whyAliv/theme/why_aliv_theme.dart';

class TextBody extends StatelessWidget {
  const TextBody({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.43,
        fontFamily: 'CircularPro',
        fontWeight: FontWeight.w400,
        color: WhyAlivTheme.bodyTextColor,
      ),
    );
  }
}