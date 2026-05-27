import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_state.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/view/bucket_usage_view_helpers.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plan_card_with_data.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/no_active_plan_card.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Usage/postpaid_usage_item.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/postpage_usage_tile.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/postpaid_current_plan.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/purchase_addon_button.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/usage_metric_row.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/usage_roaming_widget.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Home/home/data/home_ui_config.dart';

class CurrentPlanTab extends StatelessWidget {
  const CurrentPlanTab({super.key});

  static const Color purple = Color(0xFF645D9C);
  static const Color bg = Color(0xFFF1F2FA);

  @override
  Widget build(BuildContext context) {
    final HomeUiConfig config = context.watch<AppUiConfigCubit>().state;

    return Container(
      color: Colors.white,
      child: ListView(
        // padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        children: [
          // 🔴 Active plan card (reuse your existing widget)
          BlocBuilder<PlansCubit, PlansState>(
            buildWhen: (previous, current) =>
                previous.status != current.status ||
                previous.addOnsApiPrimaryPlans !=
                    current.addOnsApiPrimaryPlans,
            builder: (context, plansState) {
              final isResolving =
                  plansState.status == PlansStatus.initial ||
                  plansState.status == PlansStatus.loading;
              final showActiveCard = isResolving ||
                  plansState.addOnsApiPrimaryPlans.isNotEmpty;

              if (!showActiveCard) {
                return const Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: NoActivePlanCard(),
                );
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: config.isPostpaid == true
                    ? PostpaidCurrentPlan()
                    : const PrepaidActivePlanCardWithData(
                        showRenewButton: false,
                      ),
              );
            },
          ),

          // const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  final Uri uri = Uri.parse(
                    'https://www.bealiv.com/fair-use-policy/',
                  );
                  if (!await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  )) {
                    throw 'Could not launch dialer';
                  }
                },
                child: Text(
                  'fair use policy',
                  style: TextStyle(
                    color: const Color(0xFF645D9C),
                    fontSize: 13,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF645D9C),
                  ),
                ),
              ),
            ),
          ),

          if (config.isPostpaid == true)
            BlocBuilder<BucketUsageSummaryCubit, BucketUsageSummaryState>(
              buildWhen: (a, b) =>
                  a.summary != b.summary || a.activePlans != b.activePlans,
              builder: (context, state) {
                final rows = state.activePlanBucketUsage
                    .where((u) => !isRoamingBucket(u.bucketName))
                    .map(
                      (u) => PostpaidUsageItem(
                        title: u.bucketName,
                        subtitle: u.isUnlimited
                            ? 'unlimited'
                            : '${formatBucketAmount(u.remaining, u.unitLabel)}'
                                ' of ${formatBucketAmount(u.initial, u.unitLabel)}',
                        trailingText: u.isUnlimited
                            ? 'unlimited'
                            : '${(u.progress * 100).round()}% used',
                        isUnlimited: u.isUnlimited,
                        progress: u.progress,
                      ),
                    )
                    .toList(growable: false);

                if (rows.isEmpty) return const SizedBox.shrink();
                return buildUsageSection(rows);
              },
            ),

          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: const _ActiveAddOns(),
            ),

          if (config.isPostpaid == false) const SizedBox(height: 16),

          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: const _UsageSection(),
            ),

          // const SizedBox(height: 16),
          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: const PurchaseAddOnButton(),
            ),

          if (config.isPostpaid == false)
            Container(
              // padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(color: Color(0xFFF1F2FA)),
              child: const Text(
                'roaming plan',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (config.isPostpaid == false)
            Container(
              // padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: const _RoamingPlanSection(),
            ),
          if (config.isPostpaid == false) const SizedBox(height: 16),

          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: const UsageMetricRow(
                title: 'roaming data',
                subtitle: '0 of 2 GB',
                progress: 0.0,
                percentUsed: 0,
                gradient: [Color(0xFFFAD4C0), Color(0xFFF2994A)],
              ),
            ),
          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: const UsageMetricRow(
                title: 'local data',
                subtitle: '0 of 0 MB',
                progress: 0.0,
                percentUsed: 0,
                gradient: [Color(0xFFFAD4C0), Color(0xFFF2994A)],
              ),
            ),
          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: const UsageMetricRow(
                title: 'roaming talk mins',
                subtitle: '0 of 0 minutes',
                progress: 0.02,
                percentUsed: 2,
                gradient: [Color(0xFF9ADAF0), Color(0xFF2D9CDB)],
              ),
            ),
          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: const UsageMetricRow(
                title: 'local talk mins',
                subtitle: '0 of 0 minutes',
                progress: 0.02,
                percentUsed: 2,
                gradient: [Color(0xFF9ADAF0), Color(0xFF2D9CDB)],
              ),
            ),
          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: const UsageMetricRow(
                title: 'roaming sms',
                subtitle: '0 of 0 sms',
                progress: 0.55,
                percentUsed: 55,
                gradient: [Color(0xFFC5C3E6), Color(0xFF6B63C5)],
              ),
            ),
          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: const UsageMetricRow(
                title: 'local sms',
                subtitle: '0 of 0 sms',
                progress: 0.55,
                percentUsed: 55,
                gradient: [Color(0xFFC5C3E6), Color(0xFF6B63C5)],
              ),
            ),

          if (config.isPostpaid == false)
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 20),
              child: Text(
                'Roameasy Begins Immediately Bundle\nCalls Unlimited',
                style: TextStyle(
                  color: const Color(0xFF222222),
                  fontSize: 12,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (config.isPostpaid == false) SizedBox(height: 8),
          if (config.isPostpaid == false)
            Container(
              // padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(color: Color(0xFFF1F2FA)),
              child: SizedBox(height: 20),
            ),
        ],
      ),
    );
  }

  Widget buildUsageSection(List<PostpaidUsageItem> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      color: Colors.white,
      child: Column(
        children: items.map(
          (e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PostpaidUsageTile(item: e),
            );
          },
        ).toList(),
      ),
    );
  }
}

class _ActiveAddOns extends StatelessWidget {
  const _ActiveAddOns();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'active add-ons',
          style: TextStyle(
            color: const Color(0xFF222222),
            fontSize: 12,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: ShapeDecoration(
        color: const Color(0xFFF4F4F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: const Color(0xFF222222),
          fontSize: 14,
          fontFamily: 'CircularPro',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _UsageSection extends StatelessWidget {
  const _UsageSection();
  static const Color divider = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BucketUsageSummaryCubit, BucketUsageSummaryState>(
      buildWhen: (a, b) =>
          a.summary != b.summary || a.activePlans != b.activePlans,
      builder: (context, state) {
        final rows = state.activePlanBucketUsage
            .where((u) => !isRoamingBucket(u.bucketName))
            .toList(growable: false);

        if (rows.isEmpty) return const SizedBox.shrink();

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < rows.length; i++) ...[
              _LimitRow(
                title: rows[i].bucketName,
                subtitle: rows[i].isUnlimited
                    ? 'unlimited'
                    : '${formatBucketAmount(rows[i].remaining, rows[i].unitLabel)}'
                        ' of ${formatBucketAmount(rows[i].initial, rows[i].unitLabel)}',
                percentUsed: rows[i].progress,
                progressColor: styleForBucket(rows[i].bucketName).color,
                isUnlimited: rows[i].isUnlimited,
              ),
              const Divider(color: divider),
              if (i < rows.length - 1) const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}

class _LimitRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final double percentUsed;
  final Color progressColor;
  final bool isUnlimited;

  const _LimitRow({
    required this.title,
    required this.subtitle,
    required this.percentUsed,
    required this.progressColor,
    this.isUnlimited = false,
  });

  @override
  Widget build(BuildContext context) {
    final HomeUiConfig config = context.watch<AppUiConfigCubit>().state;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: const Color(0xFF222222),
                    fontSize: 12,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: const Color(0xFF707070),
                    fontSize: 12,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Unlimited buckets render a full green bar regardless of
                    // progress (matches the home-screen UsageCard treatment).
                    final isPrepaidGreen =
                        config.userType != UserType.postpaid;
                    final showFullGreen = isUnlimited && isPrepaidGreen;
                    final progressFraction = showFullGreen
                        ? 1.0
                        : percentUsed.clamp(0.0, 1.0);
                    final width = 80 * progressFraction;

                    return Stack(
                      children: [
                        // Background
                        Container(
                          height: 6,
                          width: 80,
                          color: config.userType == UserType.postpaid
                              ? const Color(0x26DD3038)
                              : const Color(0x2617B26A)
                                  .withValues(alpha: 0.2),
                        ),

                        // Gradient progress (width = percentage)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 6,
                          width: width.toDouble(),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              colors: config.userType == UserType.postpaid
                                  ? [
                                      const Color(0x00DD3038),
                                      const Color(0xFFDD3038),
                                    ]
                                  : [
                                      const Color(0x0017B26A),
                                      const Color(0xFF17B26A),
                                    ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isUnlimited
                    ? 'unlimited'
                    : '${(percentUsed.clamp(0.0, 1.0) * 100).round()}% used',
                style: const TextStyle(
                  color: Color(0xFF707070),
                  fontSize: 12,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.only(
        top: 24.0,
        bottom: 16,
        left: 24,
        right: 24,
      ),
      child: UsageRoamingPlanCard(),
    );
  }
}
