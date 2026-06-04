import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_state.dart';

/// "active add-ons" chip row shown above the prepaid usage list.
///
/// Renders one chip per secondary plan attached to the primary plan,
/// using each plan's `planName` verbatim. Stand-alone (roaming) plans
/// are not represented here.
///
/// Hidden entirely (title + chips) when there are no secondary plans.
class ActiveAddOnsChips extends StatelessWidget {
  const ActiveAddOnsChips({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlansCubit, PlansState>(
      buildWhen: (a, b) => a.secondaryPlans != b.secondaryPlans,
      builder: (context, state) {
        final labels = state.secondaryPlans
            .map((p) => p.planName.trim())
            .where((n) => n.isNotEmpty)
            .toList(growable: false);

        if (labels.isEmpty) return const SizedBox.shrink();

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
              runSpacing: 10,
              children: [
                for (final label in labels) _Chip(label),
              ],
            ),
          ],
        );
      },
    );
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
