import 'package:flutter/material.dart';
import '../theme/face_id_security_theme.dart';

class FaceIdSecurityBodyText extends StatelessWidget {
  final String header;
  final String body;

  const FaceIdSecurityBodyText({
    super.key,
    required this.header,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header, style: FaceIdSecurityTheme.title),
        const SizedBox(height: 12),
        Text(body, style: FaceIdSecurityTheme.body),
      ],
    );
  }
}
