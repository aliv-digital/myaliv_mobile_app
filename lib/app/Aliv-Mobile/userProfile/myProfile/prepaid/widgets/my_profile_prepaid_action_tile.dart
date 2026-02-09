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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: MyProfilePrepaidTheme.actionIconBg,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: SvgPicture.asset(
                    iconPath,
                    width: 25,
                    height: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: MyProfilePrepaidTheme.actionTitle,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right, color: Colors.black, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
