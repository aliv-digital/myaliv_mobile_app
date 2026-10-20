import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/widgets/upgrade_credit_limit_button.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';

/// Current plan card for postpaid users in Usage screen.
///
/// Displays plan name, active/expire dates from PrimaryPlans[0] (earliest plan).
class PostpaidCurrentPlan extends StatelessWidget {
  final bool showRenewButton;
  final bool showUpgradeCreditLimitButton;

  const PostpaidCurrentPlan({
    super.key,
    this.showRenewButton = true,
    this.showUpgradeCreditLimitButton = false,
  });

  static const Color red = Color(0xFFD94B4B);
  static const Color redDark = Color(0xFFCC3F3F);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlansCubit, PlansState>(
      buildWhen: (previous, current) {
        return previous.earliestAddOnsPrimaryPlan !=
                current.earliestAddOnsPrimaryPlan ||
            previous.addOnsApiLastSyncedAt != current.addOnsApiLastSyncedAt;
      },
      builder: (context, state) {
        final activePlan = state.earliestAddOnsPrimaryPlan;
        final expiry = _displayExpiry(
          planEndDate: activePlan?.endDateTime,
          isPostpaid: true,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Container(
            constraints: BoxConstraints(
              minHeight: showUpgradeCreditLimitButton ? 216 : 151,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/icons/sm.png'),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopRow(activePlan?.planName),
                SizedBox(height: showUpgradeCreditLimitButton ? 12 : 20),
                _buildDatesRow(
                  activeDate: (activePlan?.startDateTime).formatDdMmYyOrDash(),
                  expireDate: expiry.formatDdMmYy(),
                  expireTime: expiry.formatHmAOrEmpty(),
                ),
                if (showUpgradeCreditLimitButton) ...[
                  const SizedBox(height: 14),
                  const UpgradeCreditLimitButton(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopRow(String? planName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: ' plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'CircularPro',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                planName?.trim().isNotEmpty == true
                    ? planName!
                    : 'no active plan',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatesRow({
    required String activeDate,
    required String expireDate,
    required String expireTime,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DateBlock(title: 'active', value: activeDate),
        const Spacer(),
        _DateBlock(
          title: 'expire',
          value: expireDate,
          subtitle: expireTime,
          alignRight: true,
        ),
      ],
    );
  }
}

// Postpaid plans carry a far-future sentinel EndDate (2036-01-01, 2106-01-01…).
// Never surface that to the user — show the billing-cycle end instead.
bool _isSentinelEnd(DateTime end) => end.year >= 2035;

DateTime _endOfCurrentMonth() {
  final now = DateTime.now();
  return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
}

DateTime _displayExpiry({
  required DateTime? planEndDate,
  required bool isPostpaid,
}) {
  if (isPostpaid || planEndDate == null || _isSentinelEnd(planEndDate)) {
    return _endOfCurrentMonth();
  }
  return planEndDate;
}

// ================= Date Block =================
class _DateBlock extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final bool alignRight;

  const _DateBlock({
    required this.title,
    required this.value,
    this.subtitle = '',
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontFamily: 'CircularPro',
            fontWeight: FontWeight.w700,
            letterSpacing: 2.25,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
