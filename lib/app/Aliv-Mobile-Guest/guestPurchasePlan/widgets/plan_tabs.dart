import 'package:flutter/material.dart';
import '../repository/guest_purchase_plan_repository.dart';

class PlanTabs extends StatelessWidget {
  final PlanTab selected;
  final ValueChanged<PlanTab> onChanged;

  const PlanTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _tabs = <PlanTab, String>{
    PlanTab.daily: 'daily',
    PlanTab.weekly: 'weekly',
    PlanTab.monthly: 'monthly',
    PlanTab.roaming: 'roaming',
    PlanTab.roameasy: 'roameasy',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final tab = _tabs.keys.elementAt(i);
          final label = _tabs[tab]!;
          final isActive = tab == selected;

          return InkWell(
            onTap: () => onChanged(tab),
            borderRadius: BorderRadius.circular(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'CircularPro',
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive ? const Color(0xFF5D5A8B) : const Color(0xFF6D6D6D),
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 2,
                  width: 44,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF5D5A8B) : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
