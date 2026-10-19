import 'package:flutter/material.dart';
import '../theme/enter_password_prepaid_theme.dart';

class EnterPasswordPrepaidBiometricButtons extends StatelessWidget {
  final VoidCallback onFaceId;
  final VoidCallback onFingerprint;
  final bool showFaceId;
  final bool showFingerprint;

  const EnterPasswordPrepaidBiometricButtons({
    super.key,
    required this.onFaceId,
    required this.onFingerprint,
    this.showFaceId = true,
    this.showFingerprint = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showFaceId && !showFingerprint) return const SizedBox.shrink();

    return Row(
      children: [
        if (showFaceId) ...[
          Expanded(
            child: SizedBox(
              height: 40,
              child: OutlinedButton(
                onPressed: onFaceId,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: EnterPasswordPrepaidTheme.biometricButtonBorder,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Face ID',
                  textAlign: TextAlign.center,
                  style: EnterPasswordPrepaidTheme.biometricButtonText,
                ),
              ),
            ),
          ),
          if (showFingerprint) const SizedBox(width: 14),
        ],
        if (showFingerprint)
          Expanded(
            child: SizedBox(
              height: 40,
              child: OutlinedButton(
                onPressed: onFingerprint,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: EnterPasswordPrepaidTheme.biometricButtonBorder,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Fingerprint',
                  textAlign: TextAlign.center,
                  style: EnterPasswordPrepaidTheme.biometricButtonText,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
