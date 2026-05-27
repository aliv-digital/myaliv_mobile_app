import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/models/base_plan_model.dart';

/// Collapsible "your active plans" card listing the user's currently
/// subscribed plans grouped by source (primary, add-on/secondary, roaming
/// stand-alone). Built as a standalone widget so the bucket detail modal
/// can reuse the same UI without duplicating logic.
class ActivePlansExpander extends StatefulWidget {
  const ActivePlansExpander({super.key, this.initiallyExpanded = true});

  /// Whether the list is open on first mount. Home shows expanded by
  /// default; the bucket detail modal opens collapsed.
  final bool initiallyExpanded;

  @override
  State<ActivePlansExpander> createState() => _ActivePlansExpanderState();
}

class _ActivePlansExpanderState extends State<ActivePlansExpander> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlansCubit, PlansState>(
      buildWhen: (a, b) =>
          a.addOnsApiPrimaryPlans != b.addOnsApiPrimaryPlans ||
          a.secondaryPlans != b.secondaryPlans ||
          a.standAlonePlans != b.standAlonePlans,
      builder: (context, state) {
        final rows = _buildRows(state);
        if (rows.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              if (_expanded) ...[
                const SizedBox(height: 12),
                for (int i = 0; i < rows.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  _planRow(rows[i]),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _header() {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome_outlined,
            size: 18,
            color: Color(0xFF645D9C),
          ),
          const SizedBox(width: 8),
          const Text(
            'your active plans',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Icon(
            _expanded ? Icons.expand_less : Icons.expand_more,
            size: 22,
            color: const Color(0xFF707070),
          ),
        ],
      ),
    );
  }

  Widget _planRow(_PlanRow row) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  row.plan.planName.toLowerCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'CircularPro',
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _badge(row.badge),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'expires on: ${_formatDate(row.plan.endDateTime)}',
            style: const TextStyle(
              color: Color(0xFF707070),
              fontSize: 12,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(_PlanBadge badge) {
    final (bg, fg, label) = switch (badge) {
      _PlanBadge.primary => (
          const Color(0xFFB6EBD5),
          const Color(0xFF0C5C44),
          'Primary',
        ),
      _PlanBadge.addOn => (
          const Color(0xFFE4E6EC),
          const Color(0xFF4A4D55),
          'Add-ons',
        ),
      _PlanBadge.roaming => (
          const Color(0xFFE4E6EC),
          const Color(0xFF4A4D55),
          'Roaming plan',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontFamily: 'CircularPro',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Format an API endDate to design spec: `saturday, may 16, 2026 11:07 pm`.
  /// Returns an em dash when the date is missing/unparseable so the row
  /// still renders cleanly.
  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('EEEE, MMMM d, yyyy h:mm a').format(date).toLowerCase();
  }

  /// Flattens the three plan groups into a single ordered list, dedup-ed by
  /// `planId` with first-occurrence wins. Order: primary → add-on → roaming
  /// so the design's column ordering is preserved. Dedup is a safety net for
  /// the bundles API that can echo the same plan in multiple groups (e.g.
  /// two purchases of a stand-alone plan share a single `planId`).
  List<_PlanRow> _buildRows(PlansState state) {
    final rows = <_PlanRow>[];
    final seenIds = <String>{};

    void addGroup(Iterable<BasePlanModel> plans, _PlanBadge badge) {
      for (final plan in plans) {
        if (plan.planId.isEmpty) continue;
        if (!seenIds.add(plan.planId)) continue;
        rows.add(_PlanRow(plan: plan, badge: badge));
      }
    }

    addGroup(state.addOnsApiPrimaryPlans, _PlanBadge.primary);
    addGroup(state.secondaryPlans, _PlanBadge.addOn);
    addGroup(state.standAlonePlans, _PlanBadge.roaming);

    return rows;
  }
}

enum _PlanBadge { primary, addOn, roaming }

class _PlanRow {
  const _PlanRow({required this.plan, required this.badge});
  final BasePlanModel plan;
  final _PlanBadge badge;
}
