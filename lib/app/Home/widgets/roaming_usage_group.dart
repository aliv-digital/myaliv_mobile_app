import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_state.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/logic/plan_bucket_usage.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/view/bucket_usage_view_helpers.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/usage_card.dart';

/// Horizontal roaming usage cards. Reads `state.roamingPlanBucketUsage`
/// (standalone roaming plans like roameasy) and currently surfaces only the
/// `roam data us/can` bucket — other roaming buckets are intentionally
/// hidden for now.
class RoamingUsageGroup extends StatelessWidget {
  const RoamingUsageGroup({super.key, required this.isPostpaid});

  final bool isPostpaid;

  static const String _targetBucket = 'roam data us/can';

  static const double _cardSeparator = 12;
  static const double _leadingPad = 24;
  static const double _cardsRowHeight = 160;

  /// Returns true when there is at least one `roam data us/can` card to show.
  /// Used by the home section composer to hide the "roaming" header when the
  /// list would be empty.
  static bool hasRoamingCards(BucketUsageSummaryState state) {
    return _filter(state.roamingPlanBucketUsage).isNotEmpty;
  }

  static List<PlanBucketUsage> _filter(List<PlanBucketUsage> source) {
    return source
        .where((u) => u.bucketName.trim().toLowerCase() == _targetBucket)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BucketUsageSummaryCubit, BucketUsageSummaryState>(
      buildWhen: (a, b) =>
          a.summary != b.summary ||
          a.activePlans != b.activePlans ||
          a.standAlonePlans != b.standAlonePlans,
      builder: (context, state) {
        final cards = _filter(state.roamingPlanBucketUsage);
        if (cards.isEmpty) return const SizedBox.shrink();
        if (cards.length == 1) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: _leadingPad),
            child: _card(context, cards.first, width: double.infinity),
          );
        }
        return SizedBox(
          height: _cardsRowHeight,
          child: _cardsList(context, cards),
        );
      },
    );
  }

  Widget _cardsList(BuildContext context, List<PlanBucketUsage> cards) {
    final children = <Widget>[];
    for (var i = 0; i < cards.length; i++) {
      children.add(_card(context, cards[i]));
      if (i < cards.length - 1) {
        children.add(const SizedBox(width: _cardSeparator));
      }
    }
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: _leadingPad),
      children: children,
    );
  }

  Widget _card(
    BuildContext context,
    PlanBucketUsage usage, {
    double width = 124,
  }) {
    final style = styleForBucket(usage.bucketName);
    return UsageCard(
      icon: style.icon,
      title: usage.bucketName,
      color: style.color,
      isUnlimited: usage.isUnlimited,
      totalValue: formatBucketAmount(usage.remaining, usage.unitLabel),
      totalRemaining: formatBucketAmount(usage.initial, usage.unitLabel),
      remainingLabel: 'remaining',
      progress: usage.progress,
      isPostpaid: isPostpaid,
      width: width,
      onTap: () {
        if (kDebugMode) {
          debugPrint('we hid showing bottom sheet');
        }
      },
    );
  }
}
