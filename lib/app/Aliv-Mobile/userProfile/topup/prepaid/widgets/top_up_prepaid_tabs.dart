import 'package:flutter/material.dart';
import '../theme/top_up_prepaid_theme.dart';

class TopUpPrepaidTabs extends StatelessWidget {
  final TabController controller;

  const TopUpPrepaidTabs({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.white,
          child: TabBar(
            controller: controller,
            indicatorColor: TopUpPrepaidTheme.primary,
            indicatorWeight: 2,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TopUpPrepaidTheme.tabSelected(),
            unselectedLabelStyle: TopUpPrepaidTheme.tabUnselected(),
            labelColor: TopUpPrepaidTheme.primary,
            unselectedLabelColor: TopUpPrepaidTheme.textMuted,
            tabs: const [
              Tab(text: 'my number'),
              Tab(text: 'auto top-up'),
              Tab(text: 'send top-up'),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: TopUpPrepaidTheme.divider),
      ],
    );
  }
}
