import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/purchase_addon_button.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/usage_metric_row.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/usage_roaming_widget.dart';


class CurrentPlanTab extends StatelessWidget {
  const CurrentPlanTab({super.key});

  static const Color purple = Color(0xFF645D9C);
  static const Color bg = Color(0xFFF4F6FB);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        // 🔴 Active plan card (reuse your existing widget)
        const PrepaidActivePlanCard(showRenewButton: false),

        const SizedBox(height: 12),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text(
              'fair use policy',
              style: TextStyle(
                fontFamily: 'CircularPro',
                color: purple,
                fontSize: 13,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        const _ActiveAddOns(),

        const SizedBox(height: 24),

        const _UsageSection(),

        const SizedBox(height: 28),

        const PurchaseAddOnButton(),

        const _RoamingPlanSection(),
        const UsageMetricRow(
          title: 'roaming data',
          subtitle: '0 of 2 GB',
          progress: 0.0,
          percentUsed: 0,
          gradient: [Color(0xFFFAD4C0), Color(0xFFF2994A)],
        ),
        const UsageMetricRow(
          title: 'local data',
          subtitle: '0 of 0 MB',
          progress: 0.0,
          percentUsed: 0,
          gradient: [Color(0xFFFAD4C0), Color(0xFFF2994A)],
        ),
        const UsageMetricRow(
          title: 'roaming talk mins',
          subtitle: '0 of 0 minutes',
          progress: 0.02,
          percentUsed: 2,
          gradient: [Color(0xFF9ADAF0), Color(0xFF2D9CDB)],
        ),
        const UsageMetricRow(
          title: 'local talk mins',
          subtitle: '0 of 0 minutes',
          progress: 0.02,
          percentUsed: 2,
          gradient: [Color(0xFF9ADAF0), Color(0xFF2D9CDB)],
        ),
        const UsageMetricRow(
          title: 'roaming sms',
          subtitle: '0 of 0 sms',
          progress: 0.55,
          percentUsed: 55,
          gradient: [Color(0xFFC5C3E6), Color(0xFF6B63C5)],
        ),
        const UsageMetricRow(
          title: 'local sms',
          subtitle: '0 of 0 sms',
          progress: 0.55,
          percentUsed: 55,
          gradient: [Color(0xFFC5C3E6), Color(0xFF6B63C5)],
        ),

        const Text(
          'Roameasy Begins Immediately Bundle\nCalls Unlimited',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActiveAddOns extends StatelessWidget {
  const _ActiveAddOns();

  static const Color purple = Color(0xFF645D9C);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'active add-ons',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: const [
            _AddOnChip('voice'),
            _AddOnChip('sms'),
            _AddOnChip('data'),
          ],
        ),
      ],
    );
  }
}

class _AddOnChip extends StatelessWidget {
  final String label;
  const _AddOnChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF645D9C)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'CircularPro',
          color: Color(0xFF6C63A6),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _UsageSection extends StatelessWidget {
  const _UsageSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        UsageRow(
          title: 'data',
          subtitle: '2.4 GB of 14 GB',
          rightText: '25% used',
          progress: 0.25,
        ),
        UsageRow(
          title: 'sms',
          subtitle: 'unlimited local',
          rightText: 'unlimited',
          progress: 1,
        ),
        UsageRow(
          title: 'talk mins',
          subtitle: 'unlimited local',
          rightText: 'unlimited',
          progress: 1,
        ),
        UsageRow(
          title: 'bonus data',
          subtitle: 'unlimited whatsapp messaging',
          rightText: 'unlimited',
          progress: 1,
        ),
      ],
    );
  }
}

class UsageRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final String rightText;
  final double progress;

  const UsageRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rightText,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                rightText,
                style: const TextStyle(
                  fontFamily: 'CircularPro',
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'CircularPro',
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFF2994A)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoamingPlanSection extends StatelessWidget {
  const _RoamingPlanSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'roaming plan',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        UsageRoamingPlanCard(),
      ],
    );
  }
}
