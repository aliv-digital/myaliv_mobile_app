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
    PlanTab.mifi: 'mifi',
    PlanTab.libertyGlobal: 'liberty global',
    PlanTab.addOns: 'add ons',
  };

  static const Color _barBg = Colors.white; // ✅ bar background
  static const Color _brand = Color(0xFF5D5A8B);
  static const Color _textInactive = Color(0xFF8B8B8B);
  static const Color _divider = Color(0xFFE6E6EC);

  double _indicatorWidth(String label) {
    // ✅ label অনুযায়ী width, যাতে screenshot এর মত লাগে
    // short label = 44-52, long label = 64-78
    if (label.length <= 5) return 44; // daily, mifi
    if (label.length <= 7) return 54; // weekly, roaming
    if (label.length <= 10) return 66; // roameasy, monthly
    return 78; // liberty global, add ons
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _barBg,
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 26),
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
                          fontSize: 16,
                          fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive ? _brand : _textInactive,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ✅ purple indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        height: 3,
                        width: isActive
                            ? _indicatorWidth(label)
                            : 0, // ✅ inactive হলে hide
                        decoration: BoxDecoration(
                          color: _brand,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ✅ thin grey divider under the whole bar
          Container(height: 1, color: _divider),
        ],
      ),
    );
  }
}
