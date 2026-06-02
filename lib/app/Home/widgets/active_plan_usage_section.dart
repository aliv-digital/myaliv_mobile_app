import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_state.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/logic/plan_bucket_usage.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/view/bucket_usage_view_helpers.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/view/my_limits_cards.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/active_plans_expander.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/bucket_detail_modal.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/usage_card.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class ActivePlanUsageSection extends StatelessWidget {
  const ActivePlanUsageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeUiConfig config = context.watch<AppUiConfigCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context),
        const SizedBox(height: 16),
        config.userType == UserType.postpaid
            ? _postpaidUsageCards()
            : const _PrepaidUsageGroup(),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: ActivePlansExpander(),
        ),
        const SizedBox(height: 20),
        if (config.userType == UserType.postpaid) _myLimitsHeader(context),
        if (config.userType == UserType.postpaid) const SizedBox(height: 10),
        if (config.userType == UserType.postpaid) const MyLimitsCards(),
      ],
    );
  }

  // ================= Header =================
  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.go(AppRoutes.usage);
            },
            child: Text(
              'active plan usage remaining',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              context.go(AppRoutes.usage);
            },
            child: Text(
              'view all',
              style: TextStyle(
                color: const Color(0xFF645D9C),
                fontSize: 13,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF645D9C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _myLimitsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              context.read<AppUiConfigCubit>().showMyLimitsView();
              context.go(AppRoutes.usage);
            },
            child: Text(
              'my limits',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              context.read<AppUiConfigCubit>().showMyLimitsView();
              context.go(AppRoutes.usage);
            },
            child: Text(
              'view all',
              style: TextStyle(
                color: const Color(0xFF645D9C),
                fontSize: 13,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF645D9C),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // ================= Usage Cards =================

  Widget _postpaidUsageCards() {
    return SizedBox(
      height: 160,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        scrollDirection: Axis.horizontal,
        children: const [
          UsageCard(
            icon: 'assets/icons/message.svg',
            title: 'local text',
            totalValue: '\$25.00',
            totalRemaining: '\$30.00',
            remainingLabel: 'remaining',
            progress: 0.8,
            color: Color(0xFF5045A7),
            isPostpaid: true,
          ),
          SizedBox(width: 12),
          UsageCard(
            icon: 'assets/icons/Rss.svg',
            title: 'local data',
            totalValue: '\$25.00',
            totalRemaining: '\$30.00',
            remainingLabel: 'remaining',
            progress: 0.5,
            color: Color(0xFFFF6C36),
            isPostpaid: true,
          ),
          SizedBox(width: 12),
          UsageCard(
            icon: 'assets/icons/phone_call.svg',
            title: 'local talk mins',
            totalValue: '\$27.00',
            totalRemaining: '\$30.00',
            remainingLabel: 'remaining',
            progress: 0.7,
            color: Color(0xFF00B3E3),
            isPostpaid: true,
          ),
          SizedBox(width: 12),
        ],
      ),
    );
  }
}

/// Prepaid usage cards row with a sticky labels header.
///
/// Cards are the union of `activePlanBucketUsage` and `roamingPlanBucketUsage`
/// (deduped by normalized name, first-seen wins) partitioned by
/// `isRoamingBucket(name)`. The active-plan label is pinned to the leading
/// edge; the "roaming" label sits above the first roaming card and slides
/// left with the scroll. When the two labels collide, the roaming label
/// pushes the plan-name label off-screen — classic horizontal sticky-header
/// behaviour.
class _PrepaidUsageGroup extends StatefulWidget {
  const _PrepaidUsageGroup();

  @override
  State<_PrepaidUsageGroup> createState() => _PrepaidUsageGroupState();
}

class _PrepaidUsageGroupState extends State<_PrepaidUsageGroup> {
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
            _StickyLabelsRow(
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
      isPostpaid: false,
      onTap: () => BucketDetailModal.show(cardContext, usage.bucketName),
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

/// Sticky labels row drawn above the cards list.
///
/// `activeLabel` is pinned to [leadingPad]. `roamingLabel`'s natural position
/// tracks the first roaming card (so it scrolls left with the cards). When
/// the roaming label's natural position would overlap the active label, the
/// active label is pushed left and clipped — iOS section-header style.
class _StickyLabelsRow extends StatelessWidget {
  const _StickyLabelsRow({
    required this.scrollController,
    required this.leadingPad,
    required this.labelGap,
    required this.activeLabel,
    required this.roamingLabel,
    required this.roamingStartX,
    required this.style,
  });

  final ScrollController scrollController;
  final double leadingPad;
  final double labelGap;
  final String activeLabel;
  final String? roamingLabel;
  final double roamingStartX;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final activeWidth = _measure(activeLabel);
    final height = math.max(
      _measureHeight(activeLabel),
      _measureHeight(roamingLabel ?? ''),
    );

    if (height == 0) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: AnimatedBuilder(
        animation: scrollController,
        builder: (context, _) {
          final offset =
              scrollController.hasClients ? scrollController.offset : 0.0;

          final roamingNaturalX = leadingPad + roamingStartX - offset;
          // Pin roaming at the leading edge once it reaches it.
          final roamingX = roamingLabel == null
              ? double.infinity
              : math.max(leadingPad, roamingNaturalX);

          double activeX = leadingPad;
          if (roamingLabel != null) {
            final pushedX = roamingNaturalX - activeWidth - labelGap;
            if (pushedX < leadingPad) {
              activeX = pushedX;
            }
          }

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              if (activeLabel.isNotEmpty)
                Positioned(
                  left: activeX,
                  top: 0,
                  child: Text(
                    activeLabel,
                    style: style,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              if (roamingLabel != null)
                Positioned(
                  left: roamingX,
                  top: 0,
                  child: Text(
                    roamingLabel!,
                    style: style,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _measure(String text) {
    if (text.isEmpty) return 0;
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return tp.width;
  }

  double _measureHeight(String text) {
    if (text.isEmpty) return 0;
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return tp.height;
  }
}
