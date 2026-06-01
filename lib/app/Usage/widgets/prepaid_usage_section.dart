import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_state.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/view/bucket_usage_view_helpers.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/usage_limit_row.dart';

/// Prepaid view of the user's primary/secondary bucket usage. Renders
/// one [UsageLimitRow] per non-roaming bucket. Hidden when the active
/// plan has no buckets to surface (no data loaded yet, or all-suppressed).
class PrepaidUsageSection extends StatelessWidget {
  const PrepaidUsageSection({super.key});

  static const Color _divider = Color(0xFFE0E0E0);

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
              const Divider(color: _divider),
              if (i < rows.length - 1) const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}
