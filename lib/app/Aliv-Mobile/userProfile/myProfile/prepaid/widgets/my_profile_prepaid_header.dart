import 'package:flutter/material.dart';
import '../theme/my_profile_prepaid_theme.dart';

class MyProfilePrepaidHeader extends StatelessWidget {
  final String avatarLetter;
  final String fullName;
  final String statusLabel;

  const MyProfilePrepaidHeader({
    super.key,
    required this.avatarLetter,
    required this.fullName,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 6),

        // Avatar
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            avatarLetter,
            style: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.0,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Name
        Text(
          fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 18,
            letterSpacing: -0.30,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            height: 1.1,
          ),
        ),

        const SizedBox(height: 8),

        // account status + pill
        Column(
          children: [
            Text(
              'account status:',
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 12,
                letterSpacing: -0.30,
                fontWeight: FontWeight.w400,
                color: MyProfilePrepaidTheme.textMuted,
                //height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: MyProfilePrepaidTheme.statusPillBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                statusLabel.toLowerCase(),
                style: const TextStyle(
                  fontFamily: 'CircularPro',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
