import 'package:flutter/material.dart';
import '../theme/fingerprint_security_theme.dart';

class FingerPrintSecurityBodyText extends StatelessWidget {
  final String header;
  final String body;

  const FingerPrintSecurityBodyText({
    super.key,
    required this.header,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header, style: FingerPrintSecurityTheme.title),
        const SizedBox(height: 16),
        Text(body, style: FingerPrintSecurityTheme.body),
      ],
    );
  }
}
