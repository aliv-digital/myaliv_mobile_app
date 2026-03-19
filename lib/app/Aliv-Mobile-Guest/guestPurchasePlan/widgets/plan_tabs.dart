import 'package:flutter/material.dart';
import '../repository/guest_purchase_plan_repository.dart';
import '../theme/theme.dart';

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
    PlanTab.addOns: 'add ons',
    PlanTab.mifi: 'mifi',
    PlanTab.libertyGlobal: 'liberty global'
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
      color: GuestPurchasePlanTheme.tabBarBackground,
      padding: const EdgeInsets.only(
        top: GuestPurchasePlanTheme.tabTopGapFromAppBar,
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
                            ? GuestPurchasePlanTheme.tabLabelActive
                            : GuestPurchasePlanTheme.tabLabelInactive,
                      ),
                      SizedBox(
                        height: isActive
                            ? GuestPurchasePlanTheme
                                .tabSelectedLabelToIndicatorGap
                            : GuestPurchasePlanTheme
                                .tabUnselectedLabelBottomGap,
                      ),

                      // ✅ purple indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        height: isActive
                            ? GuestPurchasePlanTheme.tabIndicatorHeight
                            : 0,
                        width: isActive
                            ? _indicatorWidth(label)
                            : 0, // ✅ inactive হলে hide
                        decoration: BoxDecoration(
                          color: GuestPurchasePlanTheme.brandPurple,
                          borderRadius: BorderRadius.circular(
                            GuestPurchasePlanTheme.tabIndicatorRadius,
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
          Container(height: 1, color: GuestPurchasePlanTheme.tabDivider),
        ],
      ),
    );
  }
}
