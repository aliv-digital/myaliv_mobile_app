import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/my_profile_prepaid_theme.dart';

class MyProfilePrepaidActionTile extends StatelessWidget {
  final String iconPath;
  final String title;
  final VoidCallback onTap;

  const MyProfilePrepaidActionTile({
    super.key,
    required this.iconPath,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: MyProfilePrepaidTheme.cardDecoration(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F1F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(
                    iconPath,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 16,
                    letterSpacing: -0.32,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: MyProfilePrepaidTheme.muted),
            ],
          ),
        ),
      ),
    );
  }
}
