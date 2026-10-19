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
          width: 100,
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Text(
              avatarLetter,
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.0,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Name
        Text(
          fullName,
          textAlign: TextAlign.center,
          style: MyProfilePrepaidTheme.textName,
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
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                statusLabel.toLowerCase(),
                textAlign: TextAlign.center,
                style: MyProfilePrepaidTheme.statusPillText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
