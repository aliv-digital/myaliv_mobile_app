import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_state.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/logic/plan_bucket_usage.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/view/bucket_usage_view_helpers.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/usage_card.dart';

/// Horizontal active-plan usage cards. Sources `state.activePlanBucketUsage`,
/// filters out roaming-named buckets (those render in `RoamingUsageGroup`
/// below) and shows a plain plan-name label above the cards row.
class UsageGroup extends StatelessWidget {
  const UsageGroup({super.key, required this.isPostpaid});

  final bool isPostpaid;

  static const double _cardSeparator = 12;
  static const double _leadingPad = 24;
  static const double _labelToCardsGap = 16;
  static const double _cardsRowHeight = 160;

  static const TextStyle _labelStyle = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BucketUsageSummaryCubit, BucketUsageSummaryState>(
      buildWhen: (a, b) =>
          a.summary != b.summary ||
          a.activePlans != b.activePlans ||
          a.standAlonePlans != b.standAlonePlans,
      builder: (context, state) {
        final active = state.activePlanBucketUsage
            .where((u) => !isRoamingBucket(u.bucketName))
            .toList();

        if (active.isEmpty) return const SizedBox.shrink();

        final activeLabel = state.activePlans.isNotEmpty
            ? state.activePlans.first.planName.trim().toLowerCase()
            : '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activeLabel.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _leadingPad),
                child: Text(activeLabel, style: _labelStyle),
              ),
            const SizedBox(height: _labelToCardsGap),
            SizedBox(
              height: _cardsRowHeight,
              child: _cardsList(context, active),
            ),
          ],
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

  Widget _card(BuildContext context, PlanBucketUsage usage) {
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
      onTap: () {
        if (kDebugMode) {
          debugPrint('we hid showing bottom sheet');
        }
      },
    );
  }
}
