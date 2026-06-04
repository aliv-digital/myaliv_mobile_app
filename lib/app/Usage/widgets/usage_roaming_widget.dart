import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

/// Visual header for the Usage tab's "roaming plan" section. Reads its
/// label + activation/expiry dates from a `BasePlanModel` so the same
/// card works for any stand-alone plan (roameasy, travel20, …) without
/// hardcoding text per variant.
class UsageRoamingPlanCard extends StatelessWidget {
  const UsageRoamingPlanCard({super.key, required this.plan});

  final BasePlanModel plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('assets/icons/Future Plan 3.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
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
            plan.planName.toLowerCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              _DateColumn(
                title: 'active',
                value: _format(plan.startDateTime),
              ),
              const Spacer(),
              _DateColumn(
                title: 'expire',
                value: _format(plan.endDateTime),
                alignRight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Renders an unparseable / missing API date as a stable placeholder
  /// rather than throwing, so the card still lays out cleanly when the
  /// bundles API drops a date string.
  static String _format(DateTime? date) {
    if (date == null) return '--/--/--';
    final adjustedDate = date.add(const Duration(hours: 6));
    return DateFormat('dd/MM/yy').format(adjustedDate);
  }
}

class _DateColumn extends StatelessWidget {
  final String title;
  final String value;
  final bool alignRight;

  const _DateColumn({
    required this.title,
    required this.value,
    this.alignRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
      ],
    );
  }
}
