import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_state.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/logic/plan_bucket_usage.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/view/bucket_usage_view_helpers.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/bucket_detail_modal.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/sticky_labels_row.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/usage_card.dart';
import 'package:myaliv_mobile_app/resources/constants/asset_constants.dart';

/// Horizontal usage-cards row with a sticky labels header. Shared between
/// prepaid and postpaid — the only difference is the [isPostpaid] flag that
/// gets forwarded to [UsageCard] (postpaid renders the red bar + "X of Y"
/// treatment).
///
/// Cards are the union of `activePlanBucketUsage` and `roamingPlanBucketUsage`
/// (deduped by normalized name, first-seen wins) partitioned by
/// `isRoamingBucket(name)`. The active-plan label is pinned to the leading
/// edge; the "roaming" label sits above the first roaming card and slides
/// left with the scroll. When the two labels collide, the roaming label
/// pushes the plan-name label off-screen — classic horizontal sticky-header
/// behaviour.
class UsageGroup extends StatefulWidget {
  const UsageGroup({super.key, required this.isPostpaid});

  final bool isPostpaid;

  @override
  State<UsageGroup> createState() => _UsageGroupState();
}

class _UsageGroupState extends State<UsageGroup> {
  // Geometry constants mirror `UsageCard`'s fixed width + the row's padding.
  // If `UsageCard.width` ever becomes responsive, update `_cardWidth` to match.
  static const double _cardWidth = 124;
  static const double _cardSeparator = 12;
  static const double _groupGap = 24;
  static const double _leadingPad = 24;
  static const double _labelToCardsGap = 16;
  static const double _cardsRowHeight = 160;
  static const double _labelInterGap = 12;

  static const TextStyle _labelStyle = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontFamily: 'CircularPro',
    fontWeight: FontWeight.w700,
  );

  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BucketUsageSummaryCubit, BucketUsageSummaryState>(
      buildWhen: (a, b) =>
          a.summary != b.summary ||
          a.activePlans != b.activePlans ||
          a.standAlonePlans != b.standAlonePlans,
      builder: (context, state) {
        final union = _unionByName(
          state.activePlanBucketUsage,
          state.roamingPlanBucketUsage,
        );
        final active = <PlanBucketUsage>[];
        final roaming = <PlanBucketUsage>[];
        for (final u in union) {
          (isRoamingBucket(u.bucketName) ? roaming : active).add(u);
        }

        if (active.isEmpty && roaming.isEmpty) {
          return const SizedBox.shrink();
        }

        final activeLabel = active.isEmpty
            ? ''
            : (state.activePlans.isNotEmpty
                ? state.activePlans.first.planName.trim().toLowerCase()
                : '');
        final roamingLabel = roaming.isEmpty ? null : 'roaming';

        final roamingStartX = active.isEmpty
            ? 0.0
            : active.length * _cardWidth +
                (active.length - 1) * _cardSeparator +
                _groupGap;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StickyLabelsRow(
              scrollController: _scrollCtrl,
              leadingPad: _leadingPad,
              labelGap: _labelInterGap,
              activeLabel: activeLabel,
              roamingLabel: roamingLabel,
              roamingStartX: roamingStartX,
              style: _labelStyle,
            ),
            const SizedBox(height: _labelToCardsGap),
            SizedBox(
              height: _cardsRowHeight,
              child: _cardsList(context, active, roaming),
            ),
          ],
        );
      },
    );
  }

  Widget _cardsList(
    BuildContext cardContext,
    List<PlanBucketUsage> active,
    List<PlanBucketUsage> roaming,
  ) {
    final children = <Widget>[];
    for (var i = 0; i < active.length; i++) {
      children.add(_card(cardContext, active[i]));
      if (i < active.length - 1) {
        children.add(const SizedBox(width: _cardSeparator));
      }
    }
    if (active.isNotEmpty && roaming.isNotEmpty) {
      children.add(const SizedBox(width: _groupGap));
    }
    for (var i = 0; i < roaming.length; i++) {
      children.add(_card(cardContext, roaming[i]));
      if (i < roaming.length - 1) {
        children.add(const SizedBox(width: _cardSeparator));
      }
    }
    return ListView(
      controller: _scrollCtrl,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: _leadingPad),
      children: children,
    );
  }

  Widget _card(BuildContext cardContext, PlanBucketUsage usage) {
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
      isPostpaid: widget.isPostpaid,
      onTap: () {
         if(kDebugMode){
           debugPrint("we hid showing bottom sheet");
         }
        // BucketDetailModal.show(cardContext, usage.bucketName);
      }
    );
  }

  /// Dedupe by normalized bucket name (first-seen wins). Active list takes
  /// precedence over roaming when the same bucket appears in both (rare —
  /// primary plans don't typically declare roaming buckets — but possible).
  List<PlanBucketUsage> _unionByName(
    List<PlanBucketUsage> a,
    List<PlanBucketUsage> b,
  ) {
    final seen = <String>{};
    final out = <PlanBucketUsage>[];
    for (final u in [...a, ...b]) {
      final key = u.bucketName.trim().toLowerCase();
      if (key.isEmpty || seen.contains(key)) continue;
      seen.add(key);
      out.add(u);
    }
    return out;
  }
}
