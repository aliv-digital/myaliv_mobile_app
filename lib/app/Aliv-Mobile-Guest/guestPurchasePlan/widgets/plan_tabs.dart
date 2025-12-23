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

  static const Color _bg = Color(0xFFF6F6FB); // ✅ off-white like screenshot
  static const Color _brand = Color(0xFF5D5A8B);
  static const Color _textInactive = Color(0xFF8B8B8B);
  static const Color _divider = Color(0xFFE6E6EC);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // ✅ different from screen bg
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.only(left: 6),
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
                  child: Padding(
                    padding: const EdgeInsets.only(),
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
                        const SizedBox(height: 6),

                        // ✅ purple indicator (label-width-ish)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          height: 3,
                          width: isActive ? 60 : 26, // keep consistent width like screenshot
                          decoration: BoxDecoration(
                            color: isActive ? _brand : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ thin grey divider under the whole bar
          const SizedBox(height: 6),
          Container(height: 0, color: _divider),
        ],
      ),
    );
  }
}
