import 'package:flutter/material.dart';
import '../theme/refer_friend_prepaid_theme.dart';

class ReferFriendPrepaidTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ReferFriendPrepaidTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          _TabItem(
            label: 'refer a friend',
            active: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          _TabItem(
            label: 'redeem referral',
            active: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
          _TabItem(
            label: 'refer history',
            active: selectedIndex == 2,
            onTap: () => onChanged(2),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: active ? ReferFriendPrepaidTheme.tabActive : ReferFriendPrepaidTheme.tab,
              ),
            ),
            Container(
              height: 2,
              width: 92,
              decoration: BoxDecoration(
                color: active ? ReferFriendPrepaidTheme.brand : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
