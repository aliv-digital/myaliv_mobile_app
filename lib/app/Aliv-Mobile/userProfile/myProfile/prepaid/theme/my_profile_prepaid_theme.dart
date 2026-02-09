import 'package:flutter/material.dart';

class MyProfilePrepaidTheme {
  static const Color brand = Color(0xFF6E6AA6); // top bar purple-ish
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
    // Closest available weight for requested w450.
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );




  static const TextStyle deviceTitle = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 14,
    // Closest available weight for requested w450.
    fontWeight: FontWeight.w500,
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
    // Figma asks for 450; Flutter supports 400/500 steps, so 500 is the closest.
    fontWeight: FontWeight.w500,
    color: textDark,
  );
  // Status pill
  static const Color statusPillBg = Color(0xFF00C4B3);
  static const TextStyle statusPillText = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

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

  // First info card (phone / active on / email) styles from Figma.
  static const TextStyle infoCardLabel = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 14,
    fontWeight: FontWeight.w500, // closest available to requested w450
    height: 1.43,
    color: Color(0xFF989898),
  );

  static const TextStyle infoCardValue = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 14,
    fontWeight: FontWeight.w500, // closest available to requested w450
    color: Colors.black,
  );

  // Action card (edit email / change password)
  static const Color actionIconBg = Color(0xFFF6F8F9);
  static const TextStyle actionTitle = TextStyle(
    fontFamily: 'CircularPro',
    fontSize: 16,
    letterSpacing: -0.32,
    fontWeight: FontWeight.w700,
    color: Colors.black,
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
