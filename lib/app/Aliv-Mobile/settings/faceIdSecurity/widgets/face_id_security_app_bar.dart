import 'package:flutter/material.dart';
import '../../../../../../resources/widgets/default_app_bar.dart';
import '../theme/face_id_security_theme.dart';

class FaceIdSecurityAppBar extends StatelessWidget {
  final String title;

  const FaceIdSecurityAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: FaceIdSecurityTheme.appBarHeight,
      child: DefaultAppBar(
        title: title,
        height: FaceIdSecurityTheme.appBarHeight,
        backgroundColor: FaceIdSecurityTheme.appBarBg,
        showBackArrow: true,
        showHome: false,
      ),
    );
  }
}
