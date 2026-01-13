import 'package:flutter/material.dart';
import '../theme/profile_prepaid_theme.dart';

class ProfileMenuItemTile extends StatelessWidget {
  const ProfileMenuItemTile({
    super.key,
    required this.title,
    required this.enabled,
    required this.onTap,
    this.showDivider = true,
  });

  final String title;
  final bool enabled;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final titleColor = enabled ? ProfilePrepaidTheme.textBlack : ProfilePrepaidTheme.textGrey;
    final chevronColor = enabled ? ProfilePrepaidTheme.chevron : ProfilePrepaidTheme.textGrey;

    return Column(
      children: [
        InkWell(
          onTap: enabled ? onTap : null,
          child: SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ProfilePrepaidTheme.t(
                        13,
                        weight: FontWeight.w400,
                        color: titleColor,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 22, color: chevronColor),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: ProfilePrepaidTheme.divider,
          ),
      ],
    );
  }
}
