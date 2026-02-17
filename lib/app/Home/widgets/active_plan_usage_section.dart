import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/roaming_card.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/usage_card.dart';

import '../../../router/app_routes.dart';

class ActivePlanUsageSection extends StatelessWidget {
  const ActivePlanUsageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'liberty70',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
            ),
          )
        ),
        const SizedBox(height: 16),
        _usageCards(),
        const SizedBox(height: 28),
        _roamingSection(),
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
            )
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
            )
          ),
        ],
      ),
    );
  }

  // ================= Usage Cards =================
  Widget _usageCards() {
    return SizedBox(
      height: 154,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 0),
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
          ),
          SizedBox(width: 12),
          UsageCard(
            icon: 'assets/icons/phone_call.svg',
            title: 'talk mins',
            value: 'unlimited',
            total: 'local',
            remainingLabel: 'remaining',
            progress: 0.8,
            color: Color(0xFF00B3E3),
          ),
          SizedBox(width: 12),
          UsageCard(
            icon: 'assets/icons/message.svg',
            title: 'sms',
            value: 'unlimited',
            total: 'local',
            remainingLabel: 'remaining',
            progress: 0.8,
            color: Color(0xFF5045A7),
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'roameasy usa and can',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: RoamingCard(
            used: '1.5 ',
            total: '2GB',
            progress: 0.5,
          ),
        ),
      ],
    );
  }
}
