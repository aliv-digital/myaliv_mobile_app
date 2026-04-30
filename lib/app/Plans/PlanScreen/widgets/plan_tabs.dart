import 'package:flutter/material.dart';
import '../repository/plan_types.dart';
import '../theme/theme.dart';

class HomePlanTabs extends StatefulWidget {
  final HomePlanTab selected;
  final ValueChanged<HomePlanTab> onChanged;
  final List<HomePlanTab>? tabs;

  const HomePlanTabs({
    super.key,
    required this.selected,
    required this.onChanged,
    this.tabs,
  });

  static const tabLabels = <HomePlanTab, String>{
    HomePlanTab.daily: 'daily',
    HomePlanTab.weekly: 'weekly',
    HomePlanTab.monthly: 'monthly',
    HomePlanTab.roaming: 'roaming',
    HomePlanTab.roameasy: 'roameasy',
    HomePlanTab.addOns: 'add ons',
    HomePlanTab.mifi: 'mifi',
    HomePlanTab.libertyGlobal: 'liberty global',
    HomePlanTab.postpaidRoaming: 'roaming data',
  };

  @override
  State<HomePlanTabs> createState() => _HomePlanTabsState();
}

class _HomePlanTabsState extends State<HomePlanTabs> {
  final Map<HomePlanTab, GlobalKey> _itemKeys = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(covariant HomePlanTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  void _scrollToSelected() {
    if (!mounted) return;
    final ctx = _itemKeys[widget.selected]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      alignment: 0.5,
    );
  }

  double _indicatorWidth(String label) {
    if (label.length <= 5) return 44;
    if (label.length <= 7) return 54;
    if (label.length <= 10) return 66;
    return 78;
  }

  @override
  Widget build(BuildContext context) {
    final visibleTabs =
        widget.tabs ?? HomePlanTabs.tabLabels.keys.toList(growable: false);
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
              itemCount: visibleTabs.length,
              separatorBuilder: (_, index) => const SizedBox(width: 26),
              itemBuilder: (context, i) {
                final tab = visibleTabs[i];
                final label = HomePlanTabs.tabLabels[tab]!;
                final isActive = tab == widget.selected;
                final itemKey = _itemKeys.putIfAbsent(tab, () => GlobalKey());

                return InkWell(
                  key: itemKey,
                  onTap: () => widget.onChanged(tab),
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
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
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        height: isActive ? HomePlanTheme.tabIndicatorHeight : 0,
                        width: isActive ? _indicatorWidth(label) : 0,
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
          Container(height: 1, color: HomePlanTheme.tabDivider),
        ],
      ),
    );
  }
}
