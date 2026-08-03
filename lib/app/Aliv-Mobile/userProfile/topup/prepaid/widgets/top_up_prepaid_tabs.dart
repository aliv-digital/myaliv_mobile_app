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
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TabBar(
              controller: controller,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 2,
                  color: TopUpPrepaidTheme.primary,
                ),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: TopUpPrepaidTheme.tabSelected(),
              unselectedLabelStyle: TopUpPrepaidTheme.tabUnselected(),
              labelColor: TopUpPrepaidTheme.primary,
              unselectedLabelColor: TopUpPrepaidTheme.textMuted,
              tabs: const [
                Tab(height: 32, text: 'my number'),
                Tab(height: 32, text: 'auto top-up'),
                Tab(height: 32, text: 'send top-up'),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 1, color: TopUpPrepaidTheme.divider),
      ],
    );
  }
}
