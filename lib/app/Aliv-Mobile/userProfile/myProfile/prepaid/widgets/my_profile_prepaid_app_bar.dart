import 'package:flutter/material.dart';
import '../theme/my_profile_prepaid_theme.dart';

class MyProfilePrepaidAppBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onHome;

  const MyProfilePrepaidAppBar({
    super.key,
    required this.title,
    required this.onBack,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: MyProfilePrepaidTheme.brand,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          ),
          Expanded(
            child: Text(
              title,
              style: MyProfilePrepaidTheme.textTitleWhite,
            ),
          ),
          IconButton(
            onPressed: onHome,
            icon: const Icon(Icons.home_outlined, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
}
