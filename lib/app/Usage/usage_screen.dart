import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'current_plan_tab.dart';
import 'future_plan_tab.dart';

class UsageScreen extends StatelessWidget {
  const UsageScreen({super.key});

  static const Color purple = Color(0xFF6C63A6);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: AppBar(
          centerTitle: false
          ,
          backgroundColor: purple,
          elevation: 0,
          title: const Text(
            'my plans',
            style: TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(IconsaxPlusLinear.notification),
              color: Colors.white,
              onPressed: () {},
            ),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(52),
            child: _UsageTabBar(),
          ),
        ),
        body: const TabBarView(
          children: [
            CurrentPlanTab(),
            FuturePlansTab(),
          ],
        ),
      ),
    );
  }
}
class _UsageTabBar extends StatelessWidget {
  const _UsageTabBar();

  static const Color purple = Color(0xFF6C63A6);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color dividerBg = Color(0xFFF4F6FB);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Tabs
          TabBar(
            indicatorSize: TabBarIndicatorSize.tab, // 🔥 full tab width
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(
                color: purple,
                width: 3,
              ),
              insets: EdgeInsets.symmetric(horizontal: 32),
            ),
            labelColor: purple,
            unselectedLabelColor: grey,
            labelStyle: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            tabs: const [
              Tab(text: 'current plan'),
              Tab(text: 'future plans'),
            ],
          ),

          // Divider background (important!)
          Container(
            height: 10,
            color: dividerBg,
          ),
        ],
      ),
    );
  }
}

