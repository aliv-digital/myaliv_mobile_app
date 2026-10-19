import 'package:flutter/material.dart';
import '../theme/enter_password_postpaid_theme.dart';

class EnterPasswordPostpaidBiometricButtons extends StatelessWidget {
  final VoidCallback onFaceId;
  final VoidCallback onFingerprint;

  const EnterPasswordPostpaidBiometricButtons({
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
                side: const BorderSide(color: EnterPasswordPostpaidTheme.brand),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: const Text(
                'Face ID',
                style: TextStyle(
                  color: const Color(0xCC5146A8),
                  fontSize: 14,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                  height: 1.43,
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
                side: const BorderSide(color: EnterPasswordPostpaidTheme.brand),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: const Text(
                'Fingerprint',
                style: TextStyle(
                  color: const Color(0xCC5146A8),
                  fontSize: 14,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                  height: 1.43,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
