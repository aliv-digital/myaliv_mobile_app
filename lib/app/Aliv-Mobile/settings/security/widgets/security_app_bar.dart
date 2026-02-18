import 'package:flutter/material.dart';
import '../../../../../../resources/widgets/default_app_bar.dart';
import '../theme/security_theme.dart';

class SecurityAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onHomeTap;

  const SecurityAppBar({
    super.key,
    required this.title,
    required this.onHomeTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //height: SecurityTheme.appBarHeight,
      child: DefaultAppBar(
        title: title,
        height: SecurityTheme.appBarHeight,
        backgroundColor: SecurityTheme.appBarBg,
        showBackArrow: true,
        showHome: true,
        onHomeTap: onHomeTap,
      ),
    );
  }
}
