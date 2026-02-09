import 'package:flutter/material.dart';
import '../theme/my_profile_prepaid_theme.dart';

class MyProfilePrepaidInfoCard extends StatelessWidget {
  final String phone;
  final String activeOn;
  final String email;

  const MyProfilePrepaidInfoCard({
    super.key,
    required this.phone,
    required this.activeOn,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MyProfilePrepaidTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _RowItem(label: 'phone:', value: phone),
          const SizedBox(height: 14),
          _RowItem(label: 'active on:', value: activeOn),
          const SizedBox(height: 14),
          _RowItem(label: 'email address:', value: email),
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  final String label;
  final String value;

  const _RowItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Fixed label width keeps all three rows visually aligned like Figma.
        SizedBox(
          width: 120,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: MyProfilePrepaidTheme.infoCardLabel,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: MyProfilePrepaidTheme.infoCardValue,
          ),
        ),
      ],
    );
  }
}
