import 'package:flutter/material.dart';
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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: SizedBox(
          height: FaceIdSecurityTheme.bottomButtonHeight,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: FaceIdSecurityTheme.bottomButtonBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  FaceIdSecurityTheme.bottomButtonRadius,
                ),
              ),
              elevation: 0,
            ),
            onPressed: onTap,
            child: Text(text, style: FaceIdSecurityTheme.bottomButtonText),
          ),
        ),
      ),
    );
  }
}
