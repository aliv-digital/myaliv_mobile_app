import 'package:flutter/material.dart';
import '../theme/enter_password_prepaid_theme.dart';

class EnterPasswordPrepaidBiometricButtons extends StatelessWidget {
  final VoidCallback onFaceId;
  final VoidCallback onFingerprint;

  const EnterPasswordPrepaidBiometricButtons({
    super.key,
    required this.onFaceId,
    required this.onFingerprint,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: onFaceId,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: EnterPasswordPrepaidTheme.brand),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Face ID',
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: EnterPasswordPrepaidTheme.brand,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: onFingerprint,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: EnterPasswordPrepaidTheme.brand),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Fingerprint',
                style: TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: EnterPasswordPrepaidTheme.brand,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
