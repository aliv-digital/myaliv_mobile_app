import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_state.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/view/bucket_usage_view_helpers.dart';
import 'package:myaliv_mobile_app/app/Usage/postpaid_usage_item.dart';
import 'package:myaliv_mobile_app/app/Usage/widgets/postpage_usage_tile.dart';

/// Postpaid view of the user's primary/secondary bucket usage. Renders
/// one [PostpaidUsageTile] per non-roaming bucket. Same data source as
/// the prepaid section — only the tile widget differs.
class PostpaidUsageSection extends StatelessWidget {
  const PostpaidUsageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BucketUsageSummaryCubit, BucketUsageSummaryState>(
      buildWhen: (a, b) =>
          a.summary != b.summary || a.activePlans != b.activePlans,
      builder: (context, state) {
        final items = state.activePlanBucketUsage
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

        if (items.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          color: Colors.white,
          child: Column(
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PostpaidUsageTile(item: item),
                ),
            ],
          ),
        );
      },
    );
  }
}
