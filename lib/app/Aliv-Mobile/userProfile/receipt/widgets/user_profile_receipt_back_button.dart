import 'package:flutter/material.dart';

import '../theme/user_profile_receipt_theme.dart';

class UserProfileReceiptBackButton extends StatelessWidget {
  const UserProfileReceiptBackButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: UserProfileReceiptTheme.backButtonHeight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: UserProfileReceiptTheme.backButtonWidth,
        ),
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            backgroundColor: UserProfileReceiptTheme.backButtonBackgroundColor,
            elevation: 0,
            minimumSize: const Size(
              UserProfileReceiptTheme.backButtonWidth,
              UserProfileReceiptTheme.backButtonHeight,
            ),
            padding: UserProfileReceiptTheme.backButtonPadding,
            side: BorderSide(
              width: 1,
              color: UserProfileReceiptTheme.backButtonBorderColor,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                UserProfileReceiptTheme.backButtonRadius,
              ),
            ),
          ),
          child: Text(
            'back to home page',
            textAlign: TextAlign.center,
            style: UserProfileReceiptTheme.backButtonText,
          ),
        ),
      ),
    );
  }
}
