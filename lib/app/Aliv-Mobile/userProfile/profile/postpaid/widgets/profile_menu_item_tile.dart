import 'package:flutter/material.dart';
import '../theme/profile_postpaid_theme.dart';

class ProfilePostpaidMenuItemTile extends StatelessWidget {
  const ProfilePostpaidMenuItemTile({
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
    final titleColor = enabled ? ProfilePostpaidTheme.textBlack : ProfilePostpaidTheme.textGrey;
    final chevronColor = enabled ? ProfilePostpaidTheme.chevron : ProfilePostpaidTheme.textGrey;

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
                      style: ProfilePostpaidTheme.t(
                        14,
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
            color: ProfilePostpaidTheme.divider,
          ),
      ],
    );
  }
}
