import 'package:flutter/material.dart';
import '../../../../../../resources/widgets/defaultButton.dart';
import '../theme/face_id_security_theme.dart';

class FaceIdSecurityBottomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const FaceIdSecurityBottomButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultButton(
      label: text,
      isLoading: false,
      onPressed: onTap,
      backgroundColor: FaceIdSecurityTheme.bottomButtonBg,
      textStyle: FaceIdSecurityTheme.bottomButtonText,
    );
  }
}
