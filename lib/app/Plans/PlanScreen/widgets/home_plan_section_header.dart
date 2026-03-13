import 'package:flutter/material.dart';

import '../repository/home_plan_repository.dart';
import '../theme/theme.dart';

class HomePlanSectionHeader extends StatelessWidget {
  const HomePlanSectionHeader({
    super.key,
    required this.selectedTab,
  });

  final HomePlanTab selectedTab;

  String _titleForTab(HomePlanTab tab) {
    switch (tab) {
      case HomePlanTab.daily:
        return 'choose a prepaid daily primary plan';
      case HomePlanTab.weekly:
        return 'choose a prepaid weekly primary plan';
      case HomePlanTab.monthly:
        return 'choose a prepaid monthly primary plan';
      case HomePlanTab.roaming:
        return 'choose a roaming data add-on. these add-ons will only work in the usa, canada and or digicel caribbean countries.';
      case HomePlanTab.roameasy:
        return 'choose a roameasy standalone plan';
      case HomePlanTab.addOns:
        return '';
      case HomePlanTab.mifi:
        return 'choose a prepaid mifi primary plan';
      case HomePlanTab.libertyGlobal:
        return 'choose an international calling plan';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedTab == HomePlanTab.addOns) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(31, 20, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          _titleForTab(selectedTab),
          style: HomePlanTheme.sectionTitle,
        ),
      ),
    );
  }
}
