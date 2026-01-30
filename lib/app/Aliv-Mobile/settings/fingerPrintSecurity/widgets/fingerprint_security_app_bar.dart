import 'package:flutter/material.dart';
import '../../../../../../resources/widgets/default_app_bar.dart';
import '../theme/fingerprint_security_theme.dart';

class FingerPrintSecurityAppBar extends StatelessWidget {
  final String title;

  const FingerPrintSecurityAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: FingerPrintSecurityTheme.appBarHeight,
      child: DefaultAppBar(
        title: title,
        height: FingerPrintSecurityTheme.appBarHeight,
        backgroundColor: FingerPrintSecurityTheme.appBarBg,
        showBackArrow: true,
        showHome: false,
      ),
    );
  }
}
