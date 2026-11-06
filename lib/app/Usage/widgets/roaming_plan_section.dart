import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_state.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/logic/plan_bucket_usage.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/view/bucket_usage_view_helpers.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/usage_limit_row.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/usage_roaming_widget.dart';

/// Drives the "roaming plan" block on the Usage tab.
///
/// Plan cards (name, dates) come from [PlansCubit] — a HydratedCubit restored
/// from disk on app start, so the section appears immediately without waiting
/// for a network call. Usage metric rows come from [BucketUsageSummaryCubit]
/// via an inner builder and fill in once the bucket usage API responds.
class RoamingPlanSection extends StatelessWidget {
  const RoamingPlanSection({super.key});

  static const Color _divider = Color(0xFFE0E0E0);
  static const Color _titleBg = Color(0xFFF1F2FA);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlansCubit, PlansState>(
      buildWhen: (a, b) => a.standAlonePlans != b.standAlonePlans,
      builder: (context, plansState) {
        // standAlonePlansForBucketUsage already filters to current-only
        // (StartDate ≤ today) and merges duplicate planIds. Future slots
        // appear on the Future Plans tab instead.
        final plans = plansState.standAlonePlansForBucketUsage;
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
              _UsageRows(plan: plans[i]),
              if (i < plans.length - 1) const SizedBox(height: 24),
            ],
            const SizedBox(height: 16),
            const _BottomSpacer(),
          ],
        );
      },
    );
  }
}

/// Usage metric rows for a single stand-alone plan. Reads from
/// [BucketUsageSummaryCubit] independently so the plan cards above
/// render immediately from the hydrated [PlansCubit] cache while these
/// rows fill in once the bucket usage API responds.
class _UsageRows extends StatelessWidget {
  const _UsageRows({required this.plan});

  final BasePlanModel plan;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BucketUsageSummaryCubit, BucketUsageSummaryState>(
      buildWhen: (a, b) => a.summary != b.summary,
      builder: (context, state) {
        final rows = state.bucketUsageForPlan(plan);
        if (rows.isEmpty) return const SizedBox.shrink();
        return _MetricRows(rows: rows);
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
        'current standalones',
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
