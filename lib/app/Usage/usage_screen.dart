import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';

import 'current_plan_tab.dart';
import 'future_plan_tab.dart';
import 'my_limits_tab.dart';

class UsageScreen extends StatelessWidget {
  final HomeUiConfig config;

  const UsageScreen({super.key, required this.config});

  static const Color purple = Color(0xFF6C63A6);
// ---------------- CONFIG ----------------

  List<Tab> _tabs() {
    return [
      const Tab(text: 'current plan'),
      const Tab(text: 'future plans'),
      if (config.isPostpaid) const Tab(text: 'my limits'),
    ];
  }

  List<Widget> _tabViews() {
    return [
      const CurrentPlanTab(),
      const FuturePlansTab(),
      if (config.isPostpaid) const MyLimitsTab(),
    ];
  }

  int _initialTabIndex() {
    if (config.isPostpaid && config.openMyLimits) {
      return 2; // 🔥 my limits
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {

    final tabs = _tabs();
    final views = _tabViews();

    return DefaultTabController(
      length: tabs.length,
      initialIndex: _initialTabIndex(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: AppBar(
          centerTitle: false,
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
          bottom:  PreferredSize(
            preferredSize: Size.fromHeight(52),
            child: UsageTabBar(tabs),
          ),
        ),
        body: TabBarView(children: views),
      ),
    );
  }
}

class UsageTabBar extends StatelessWidget {

  static const Color purple = Color(0xFF6C63A6);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color dividerBg = Color(0xFFF4F6FB);
  final List<Tab> tabs;
  const UsageTabBar(this.tabs, {super.key});

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
              borderSide: BorderSide(color: purple, width: 3),
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
            tabs:tabs
            // const [
            //   Tab(text: 'current plan'),
            //   Tab(text: 'future plans'),
            // ],
          ),

          // Divider background (important!)
          Container(height: 10, color: dividerBg),
        ],
      ),
    );
  }
}
