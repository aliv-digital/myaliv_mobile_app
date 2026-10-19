import 'package:flutter/material.dart';
import '../../../../../../resources/widgets/default_app_bar.dart';
import '../theme/privacy_theme.dart';

class PrivacyAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onHomeTap;

  const PrivacyAppBar({
    super.key,
    required this.title,
    required this.onHomeTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PrivacyTheme.appBarHeight,
      child: DefaultAppBar(
        title: title,
        height: PrivacyTheme.appBarHeight,
        backgroundColor: PrivacyTheme.appBarBg,
        showBackArrow: true,
        showHome: true,
        onHomeTap: onHomeTap,
      ),
    );
  }
}
