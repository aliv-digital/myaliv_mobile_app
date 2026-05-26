import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/bucket-usage-summary/cubit/bucket_usage_summary_state.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/view/my_limits_cards.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/roaming_card.dart';
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
        _planNameHeader(),
        const SizedBox(height: 16),
        config.userType == UserType.postpaid
            ? _postpaidUsageCards()
            : _usageCards(),
        const SizedBox(height: 28),
        _roamingSection(config),
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

  Widget _usageCards() {
    return BlocBuilder<BucketUsageSummaryCubit, BucketUsageSummaryState>(
      buildWhen: (a, b) =>
          a.summary != b.summary || a.activePlans != b.activePlans,
      builder: (context, state) {
        final nonRoamingUsage = state.activePlanBucketUsage
            .where((u) => !_isRoamingBucket(u.bucketName))
            .toList(growable: false);

        if (nonRoamingUsage.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 160,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: nonRoamingUsage.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final usage = nonRoamingUsage[i];
              final style = _styleFor(usage.bucketName);
              return UsageCard(
                icon: style.icon,
                title: usage.bucketName,
                color: style.color,
                isUnlimited: usage.isUnlimited,
                totalValue: _formatAmount(usage.remaining, usage.unitLabel),
                totalRemaining: _formatAmount(usage.initial, usage.unitLabel),
                remainingLabel: 'remaining',
                progress: usage.progress,
                isPostpaid: false,
              );
            },
          ),
        );
      },
    );
  }

  // ================= Roaming =================
  Widget _roamingSection(HomeUiConfig config) {
    return BlocBuilder<BucketUsageSummaryCubit, BucketUsageSummaryState>(
      buildWhen: (a, b) =>
          a.summary != b.summary || a.activePlans != b.activePlans,
      builder: (context, state) {
        final roamingUsage = state.activePlanBucketUsage
            .where((u) => _isRoamingBucket(u.bucketName))
            .toList(growable: false);

        if (roamingUsage.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                config.userType == UserType.postpaid
                    ? 'travel20'
                    : 'roameasy usa and can',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < roamingUsage.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: RoamingCard(
                  title: roamingUsage[i].bucketName,
                  isUnlimited: roamingUsage[i].isUnlimited,
                  used: _formatAmount(
                    roamingUsage[i].remaining,
                    roamingUsage[i].unitLabel,
                  ),
                  total: _formatAmount(
                    roamingUsage[i].initial,
                    roamingUsage[i].unitLabel,
                  ),
                  progress: roamingUsage[i].progress,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // ================= Helpers =================

  /// Renders the section's plan-name header from the cubit's active plan set
  /// (first plan wins; lowercased to match the design's aesthetic). Hides the
  /// header entirely when no plan name is available.
  Widget _planNameHeader() {
    return BlocBuilder<BucketUsageSummaryCubit, BucketUsageSummaryState>(
      buildWhen: (a, b) => a.activePlans != b.activePlans,
      builder: (context, state) {
        final apiPlanName = state.activePlans.isNotEmpty
            ? state.activePlans.first.planName.trim()
            : '';
        if (apiPlanName.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            apiPlanName.toLowerCase(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
    );
  }

  /// Heuristic: roaming buckets carry "roam" in their name (e.g. "Roaming
  /// Data", "RoamEasy"). When the API contract is finalized this can be
  /// tightened to an exact match list.
  bool _isRoamingBucket(String bucketName) {
    return bucketName.toLowerCase().contains('roam');
  }

  /// Formats `value unit` (e.g. "2.4 GB", "30 mins"). Whole numbers drop the
  /// decimal; fractional values are kept to one decimal place.
  String _formatAmount(double value, String unit) {
    final formatted = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    if (unit.isEmpty) return formatted;
    return '$formatted $unit';
  }

  _CardStyle _styleFor(String bucketName) {
    final normalized = bucketName.trim().toLowerCase();
    if (normalized.contains('data')) {
      return const _CardStyle(
        icon: 'assets/icons/Rss.svg',
        color: Color(0xFFFF6C36),
      );
    }
    if (normalized.contains('voice') ||
        normalized.contains('talk') ||
        normalized.contains('minute') ||
        normalized.contains('mins')) {
      return const _CardStyle(
        icon: 'assets/icons/phone_call.svg',
        color: Color(0xFF00B3E3),
      );
    }
    if (normalized.contains('sms') ||
        normalized.contains('text')) {
      return const _CardStyle(
        icon: 'assets/icons/message.svg',
        color: Color(0xFF5045A7),
      );
    }
    return const _CardStyle(
      icon: 'assets/icons/Rss.svg',
      color: Color(0xFF707070),
    );
  }
}

class _CardStyle {
  const _CardStyle({required this.icon, required this.color});
  final String icon;
  final Color color;
}
