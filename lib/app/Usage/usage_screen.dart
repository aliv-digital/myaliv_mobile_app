import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';

import 'current_plan_tab.dart';
import 'future_plan_tab.dart';
import 'my_limits_tab.dart';

class UsageScreen extends StatefulWidget {
  final HomeUiConfig config;

  const UsageScreen({super.key, required this.config});

  static const Color purple = Color(0xFF645D9C);

  @override
  State<UsageScreen> createState() => _UsageScreenState();
}

class _UsageScreenState extends State<UsageScreen> {
// ---------------- CONFIG ----------------
  List<Tab> _tabs() {
    return [
      const Tab(text: 'current plan'),
      const Tab(text: 'future plans'),
      if (widget.config.isPostpaid) const Tab(text: 'my limits'),
    ];
  }

  List<Widget> _tabViews() {
    return [
      const CurrentPlanTab(),
      const FuturePlansTab(),
      if (widget.config.isPostpaid) const MyLimitsTab(),
    ];
  }

  int _initialTabIndex() {
    if (widget.config.isPostpaid && widget.config.openMyLimits) {
      return 2; // 🔥 my limits
    }
    if(widget.config.isFuturePlan == true){
      return 1;
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
          backgroundColor: UsageScreen.purple,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: const Text(
              'my plans',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: SvgPicture.asset('assets/icons/bell with red.svg'),
              color: Colors.white,
              onPressed: () {},
            ),
            SizedBox(width: 13,)
          ],
          bottom:  PreferredSize(
            preferredSize: Size.fromHeight(82),
            child: UsageTabBar(tabs),
          ),
        ),
        body: TabBarView(children: views),
      ),
    );
  }
}

class UsageTabBar extends StatelessWidget {

  static const Color purple = Color(0xFF645D9C);
  static const Color grey = Color(0xFF9E9E9E);// Color(0xFF707070)
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
          SizedBox(height: 20,),
          TabBar(
            indicatorSize: TabBarIndicatorSize.tab, // 🔥 full tab width
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(color: purple, width: 2),
              insets: EdgeInsets.symmetric(horizontal: 8),
            ),
            labelColor: purple,
            unselectedLabelColor:  Color(0xFF707070),
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
          Container(height: 24, color: dividerBg),
        ],
      ),
    );
  }
}
