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
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'liberty70',
            style: TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.go(AppRoutes.usage);
              },
            child: const Text(
              'active plan usage remaining',
              style: TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              context.go(AppRoutes.usage);
            },
            child: const Text(
              'view more',
              style: TextStyle(
                fontFamily: 'CircularPro',
                color: Color(0xFF2F80ED),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= Usage Cards =================
  Widget _usageCards() {
    return SizedBox(
      height: 190,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: const [
          UsageCard(
            icon: IconsaxPlusLinear.wifi,
            title: 'data',
            value: '2.4 GB',
            total: '14 GB',
            remainingLabel: 'remaining',
            progress: 0.17,
            color: Color(0xFFF2994A),
          ),
          SizedBox(width: 12),
          UsageCard(
            icon: IconsaxPlusLinear.call,
            title: 'talk mins',
            value: 'unlimited',
            total: 'local',
            remainingLabel: 'remaining',
            progress: 1,
            color: Color(0xFF2D9CDB),
          ),
          SizedBox(width: 12),
          UsageCard(
            icon: IconsaxPlusLinear.message_text,
            title: 'sms',
            value: 'unlimited',
            total: 'local',
            remainingLabel: 'remaining',
            progress: 1,
            color: Color(0xFF9B51E0),
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
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'roameasy usa and can',
            style: TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: RoamingCard(
            used: '0',
            total: '2 GB',
            progress: 0.0,
          ),
        ),
      ],
    );
  }
}
