import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_state.dart';

/// "active add-ons" chip row shown above the prepaid usage list.
///
/// Reads the same `BucketUsageSummaryCubit` that drives the usage rows
/// below, so chips and rows always agree. The cubit's `activePlans`
/// already covers primary + secondary plans (roaming contributions are
/// stripped from `activePlanBucketUsage`), giving a single source of
/// truth for which categories the user actually has.
///
/// Hidden entirely (title + chips) when no normalized category is found.
class ActiveAddOnsChips extends StatelessWidget {
  const ActiveAddOnsChips({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BucketUsageSummaryCubit, BucketUsageSummaryState>(
      buildWhen: (a, b) => a.activePlanBucketUsage != b.activePlanBucketUsage,
      builder: (context, state) {
        final categories = _chipCategories(state);
        if (categories.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'active add-ons',
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 12,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                for (final category in categories) _Chip(category),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Encounter-ordered set of chip categories derived from the active
  /// bucket usage rows. Normalizes bucket names to one of `data` /
  /// `voice` / `sms`; unknown buckets are dropped.
  List<String> _chipCategories(BucketUsageSummaryState state) {
    final ordered = <String>{};
    for (final usage in state.activePlanBucketUsage) {
      final category = _categoryFor(usage.bucketName);
      if (category != null) ordered.add(category);
    }
    return ordered.toList(growable: false);
  }

  String? _categoryFor(String bucketName) {
    final n = bucketName.trim().toLowerCase();
    if (n.contains('data') || n.contains('whatsapp')) return 'data';
    if (n.contains('voice') ||
        n.contains('talk') ||
        n.contains('minute') ||
        n.contains('mins')) {
      return 'voice';
    }
    if (n.contains('sms') || n.contains('text')) return 'sms';
    return null;
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: ShapeDecoration(
        color: const Color(0xFFF4F4F6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF222222),
          fontSize: 14,
          fontFamily: 'CircularPro',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
