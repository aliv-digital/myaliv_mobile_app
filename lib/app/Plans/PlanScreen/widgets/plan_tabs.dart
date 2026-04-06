import 'package:flutter/material.dart';
import '../repository/plan_types.dart';
import '../theme/theme.dart';

class HomePlanTabs extends StatelessWidget {
  final HomePlanTab selected;
  final ValueChanged<HomePlanTab> onChanged;

  const HomePlanTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _tabs = <HomePlanTab, String>{
    HomePlanTab.daily: 'daily',
    HomePlanTab.weekly: 'weekly',
    HomePlanTab.monthly: 'monthly',
    HomePlanTab.roaming: 'roaming',
    HomePlanTab.roameasy: 'roameasy',
    HomePlanTab.addOns: 'add ons',
    HomePlanTab.mifi: 'mifi',
    HomePlanTab.libertyGlobal: 'liberty global'
  };

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
      color: HomePlanTheme.tabBarBackground,
      padding: const EdgeInsets.only(
        top: HomePlanTheme.tabTopGapFromAppBar,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.only(left: 16, right: 16),
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
                    // Keep tab text row aligned to the bottom area.
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        label,
                        style: isActive
                            ? HomePlanTheme.tabLabelActive
                            : HomePlanTheme.tabLabelInactive,
                      ),
                      SizedBox(
                        height: isActive
                            ? HomePlanTheme.tabSelectedLabelToIndicatorGap
                            : HomePlanTheme.tabUnselectedLabelBottomGap,
                      ),

                      // ✅ purple indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        height: isActive ? HomePlanTheme.tabIndicatorHeight : 0,
                        width: isActive
                            ? _indicatorWidth(label)
                            : 0, // ✅ inactive হলে hide
                        decoration: BoxDecoration(
                          color: HomePlanTheme.brandPurple,
                          borderRadius: BorderRadius.circular(
                            HomePlanTheme.tabIndicatorRadius,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ✅ thin grey divider under the whole bar
          Container(height: 1, color: HomePlanTheme.tabDivider),
        ],
      ),
    );
  }
}
