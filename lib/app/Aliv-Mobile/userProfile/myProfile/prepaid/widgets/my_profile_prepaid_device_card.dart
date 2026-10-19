import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';
import '../theme/my_profile_prepaid_theme.dart';

class MyProfilePrepaidDeviceCard extends StatelessWidget {
  final String title; // e.g. "your device"
  final String deviceModel; // e.g. "iphone 14 pro"

  const MyProfilePrepaidDeviceCard({
    super.key,
    required this.title,
    required this.deviceModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(
            AssetConstant.phonePNG,
            width: 25,
            height: 42,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            title.toLowerCase(),
            style: MyProfilePrepaidTheme.deviceTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            deviceModel.toLowerCase(),
            style: MyProfilePrepaidTheme.deviceValue,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
