
import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile-Guest/whyAliv/theme/why_aliv_theme.dart';

class HeadingOne extends StatelessWidget {
  const HeadingOne({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: WhyAlivTheme.headingOne,
    );
  }
}
