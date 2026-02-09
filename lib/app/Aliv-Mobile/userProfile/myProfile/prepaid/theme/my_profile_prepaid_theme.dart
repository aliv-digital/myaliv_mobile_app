import 'package:flutter/material.dart';

class MyProfilePrepaidTheme {
  static const Color brand = Color(0xFF645D9C); // top bar purple-ish
  static const Color bg = Color(0xFFF1F2FA);

  static const Color cardBg = Colors.white;
  static const Color muted = Color(0xFF8B8B8B);
  static const Color textDark = Color(0xFF111111);
  // Greys
  static const Color textMuted = Color(0xFF8B8B8B);
  static const Color statusActiveBg = Color(0xFF21C7B7);
  static const TextStyle deviceValue = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.black,
    height: 1.43,
  );




  static const TextStyle deviceTitle = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textMuted,
    height: 1.43,
  );
  static const TextStyle textTitleWhite = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle textName = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 18,
    letterSpacing: -0.30,
    fontWeight: FontWeight.w500,
    color: textDark,
  );
  // Status pill
  static const Color statusPillBg = Color(0xFF19C3A5);

  static const TextStyle textMutedSmall = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 12,
    letterSpacing: -0.30,
    fontWeight: FontWeight.w500,
    color: muted,
  );

  static const TextStyle textBodyBold = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: textDark,
  );

  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 16,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
