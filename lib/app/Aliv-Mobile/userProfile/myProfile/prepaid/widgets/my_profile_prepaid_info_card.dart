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
      padding: const EdgeInsets.only(left: 16,right: 16,top: 16,bottom: 16),
      child: Column(
        children: [
          _RowItem(label: 'phone:', value: phone),
          const SizedBox(height: 10),
          _RowItem(label: 'active on:', value: activeOn),
          const SizedBox(height: 10),
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
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 14,
              height: 1.43,
              fontWeight: FontWeight.w500,
              color: MyProfilePrepaidTheme.muted,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 14,
              height: 1.43,
              fontWeight: FontWeight.w500,
              color: MyProfilePrepaidTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
