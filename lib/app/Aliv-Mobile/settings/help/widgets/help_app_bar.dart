import 'package:flutter/material.dart';
import '../../../../../../resources/widgets/default_app_bar.dart';
import '../theme/help_theme.dart';

class HelpAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onHomeTap;

  const HelpAppBar({
    super.key,
    required this.title,
    required this.onHomeTap,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultAppBar(
      title: title,
      height: HelpTheme.appBarHeight,
      backgroundColor: HelpTheme.appBarBg,
      showBackArrow: true,
      showHome: true,
      onHomeTap: onHomeTap,
    );
  }
}
