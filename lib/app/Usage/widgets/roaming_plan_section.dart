import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_state.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/logic/plan_bucket_usage.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/view/bucket_usage_view_helpers.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/usage_limit_row.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/usage_roaming_widget.dart';

/// Drives the entire "roaming plan" block on the Usage tab from
/// `BucketUsageSummaryState`. Hidden when the user has no stand-alone
/// plan. Renders one card per stand-alone plan, followed immediately by
/// that plan's own usage rows (computed via
/// `state.bucketUsageForPlan(plan)` so shared bucket names from sibling
/// roaming plans don't bleed across cards).
class RoamingPlanSection extends StatelessWidget {
  const RoamingPlanSection({super.key});

  static const Color _divider = Color(0xFFE0E0E0);
  static const Color _titleBg = Color(0xFFF1F2FA);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BucketUsageSummaryCubit, BucketUsageSummaryState>(
      buildWhen: (a, b) =>
          a.summary != b.summary || a.standAlonePlans != b.standAlonePlans,
      builder: (context, state) {
        final plans = state.standAlonePlans;
        if (plans.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionTitle(),
            for (int i = 0; i < plans.length; i++) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: UsageRoamingPlanCard(plan: plans[i]),
              ),
              Builder(
                builder: (_) {
                  final rows = state.bucketUsageForPlan(plans[i]);
                  if (rows.isEmpty) return const SizedBox.shrink();
                  return _MetricRows(rows: rows);
                },
              ),
              if (i < plans.length - 1) const SizedBox(height: 24),
            ],
            const SizedBox(height: 16),
            const _FooterTagline(),
            const SizedBox(height: 8),
            const _BottomSpacer(),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(color: RoamingPlanSection._titleBg),
      child: const Text(
        'roaming plan',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontFamily: 'CircularPro',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetricRows extends StatelessWidget {
  const _MetricRows({required this.rows});

  final List<PlanBucketUsage> rows;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            UsageLimitRow(
              title: rows[i].bucketName,
              subtitle: rows[i].isUnlimited
                  ? 'unlimited'
                  : '${formatBucketAmount(rows[i].remaining, rows[i].unitLabel)}'
                      ' of ${formatBucketAmount(rows[i].initial, rows[i].unitLabel)}',
              percentUsed: rows[i].progress,
              isUnlimited: rows[i].isUnlimited,
            ),
            const Divider(color: RoamingPlanSection._divider),
            if (i < rows.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _FooterTagline extends StatelessWidget {
  const _FooterTagline();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(32, 0, 32, 20),
      child: Text(
        'Roameasy Begins Immediately Bundle\nCalls Unlimited',
        style: TextStyle(
          color: Color(0xFF222222),
          fontSize: 12,
          fontFamily: 'CircularPro',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BottomSpacer extends StatelessWidget {
  const _BottomSpacer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(color: RoamingPlanSection._titleBg),
      child: const SizedBox(height: 20),
    );
  }
}
