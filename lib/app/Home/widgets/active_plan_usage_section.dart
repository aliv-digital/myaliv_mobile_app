import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/roaming_card.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/usage_card.dart';

import '../../../router/app_routes.dart';
import '../home/home_screen.dart';

class ActivePlanUsageSection extends StatelessWidget {
  const ActivePlanUsageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            config.userType == UserType.postpaid
                ? 'liberty prime'
                : 'liberty70',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        config.userType == UserType.postpaid
            ? _postpaidUsageCards()
            : _usageCards(),

        const SizedBox(height: 28),
        _roamingSection(),
        const SizedBox(height: 20),

        if (config.userType == UserType.postpaid) _myLimitsHeader(context),
        if (config.userType == UserType.postpaid) const SizedBox(height: 10),
        if (config.userType == UserType.postpaid) _postpaidUsageCards(),
      ],
    );
  }

  // ================= Header =================
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.go(AppRoutes.usage);
            },
            child: Text(
              'active plan usage remaining',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              context.go(AppRoutes.usage);
            },
            child: Text(
              'view all',
              style: TextStyle(
                color: const Color(0xFF645D9C),
                fontSize: 13,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _myLimitsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.go(
                AppRoutes.usage,
                extra: HomeUiConfig(
                  userType: config.userType,
                  hasActivePlan: true,
                  openMyLimits: true, // 🔥 KEY LINE
                  isFuturePlan: false,
                ),
              );
            },
            child: Text(
              'my limits',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              context.go(
                AppRoutes.usage,
                extra: HomeUiConfig(
                  userType: config.userType,
                  hasActivePlan: true,
                  openMyLimits: true, // 🔥 KEY LINE
                  isFuturePlan: false,
                ),
              );
            },
            child: Text(
              'view all',
              style: TextStyle(
                color: const Color(0xFF645D9C),
                fontSize: 13,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
  // ================= Usage Cards =================

  Widget _postpaidUsageCards() {
    return SizedBox(
      height: 160,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        scrollDirection: Axis.horizontal,
        children: const [
          UsageCard(
            icon: 'assets/icons/message.svg',
            title: 'local text',
            value: '\$25.00',
            total: '\$30.00',
            remainingLabel: 'remaining',
            progress: 0.8,
            color: Color(0xFF5045A7),
            isPostpaid: true,
          ),
          SizedBox(width: 12),

          UsageCard(
            icon: 'assets/icons/Rss.svg',
            title: 'local data',
            value: '\$25.00',
            total: '\$30.00',
            remainingLabel: 'remaining',
            progress: 0.5,
            color: Color(0xFFFF6C36),
            isPostpaid: true,
          ),
          SizedBox(width: 12),
          UsageCard(
            icon: 'assets/icons/phone_call.svg',
            title: 'local talk mins',
            value: '\$27.00',
            total: '\$30.00',
            remainingLabel: 'remaining',
            progress: 0.7,
            color: Color(0xFF00B3E3),
            isPostpaid: true,
          ),
          SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _usageCards() {
    return SizedBox(
      height: 160,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        scrollDirection: Axis.horizontal,
        children: const [
          UsageCard(
            icon: 'assets/icons/Rss.svg',
            title: 'data',
            value: '2.4 GB',
            total: '14 GB',
            remainingLabel: 'remaining',
            progress: 0.17,
            color: Color(0xFFFF6C36),
            isPostpaid: false,
          ),
          SizedBox(width: 12),
          UsageCard(
            icon: 'assets/icons/phone_call.svg',
            title: 'talk mins',
            value: 'unlimited',
            total: 'local',
            remainingLabel: 'remaining',
            progress: 1,//0.8,
            color: Color(0xFF00B3E3),
            isPostpaid: false,
          ),
          SizedBox(width: 12),
          UsageCard(
            icon: 'assets/icons/message.svg',
            title: 'sms',
            value: 'unlimited',
            total: 'local',
            remainingLabel: 'remaining',
            progress: 1,//0.8,
            color: Color(0xFF5045A7),
            isPostpaid: false,
          ),
        ],
      ),
    );
  }

  // ================= Roaming =================
  Widget _roamingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            config.userType == UserType.postpaid
                ? 'travel20'
                : 'roameasy usa and can',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: config.userType == UserType.postpaid
              ? const RoamingCard(used: '0.6GB ', total: '25GB', progress: 0.9)
              : const RoamingCard(used: '1.5 ', total: '2GB', progress: 0.5),
        ),
      ],
    );
  }
}
