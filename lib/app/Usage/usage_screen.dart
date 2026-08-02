import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Home/home/data/home_ui_config.dart';
import 'package:myaliv_mobile_app/core/appConfig/app_ui_config_cubit.dart';

import 'package:myaliv_mobile_app/app/Home/my-limits/view/my_limits_view.dart';
import 'package:myaliv_mobile_app/app/Usage/current_plan_tab.dart';
import 'package:myaliv_mobile_app/app/Usage/future_plan_tab.dart';

class UsageScreen extends StatefulWidget {
  const UsageScreen({super.key});

  static const Color purple = Color(0xFF645D9C);

  @override
  State<UsageScreen> createState() => _UsageScreenState();
}

class _UsageScreenState extends State<UsageScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  int _tabLength = 0;

  @override
  void initState() {
    super.initState();

    final HomeUiConfig config = context.read<AppUiConfigCubit>().state;
    _tabLength = _tabs(config).length;
    _tabController = TabController(
      length: _tabLength,
      initialIndex: _resolveInitialTabIndex(config),
      vsync: this,
    )..addListener(_handleTabChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppUiConfigCubit>().clearNavigationIntent();
    });
  }

  @override
  void dispose() {
    _tabController?.removeListener(_handleTabChanged);
    _tabController?.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _syncControllerLength(HomeUiConfig config) {
    final newLength = _tabs(config).length;
    if (newLength == _tabLength) return;

    final oldIndex = _tabController?.index ?? 0;
    _tabController?.removeListener(_handleTabChanged);
    _tabController?.dispose();
    _tabLength = newLength;
    _tabController = TabController(
      length: newLength,
      initialIndex: oldIndex.clamp(0, newLength - 1),
      vsync: this,
    )..addListener(_handleTabChanged);
  }

  void _handleNavigationIntent(HomeUiConfig state) {
    final controller = _tabController;
    if (controller == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetIndex = _resolveInitialTabIndex(state);
      if (targetIndex < controller.length && targetIndex != controller.index) {
        controller.animateTo(targetIndex);
      }
      context.read<AppUiConfigCubit>().clearNavigationIntent();
    });
  }

  // ---------------- CONFIG ----------------
  List<Tab> _tabs(HomeUiConfig config) {
    return [
      const Tab(text: 'current plan'),
      const Tab(text: 'future plans'),
      if (config.isPostpaid) const Tab(text: 'my limits'),
    ];
  }

  List<Widget> _tabViews(HomeUiConfig config) {
    return [
      const CurrentPlanTab(),
      const FuturePlansTab(),
      if (config.isPostpaid) const MyLimitsTab(),
    ];
  }

  String _titleForIndex(int index, HomeUiConfig config) {
    if (index == 0) return 'my plans';
    final tabs = _tabs(config);
    if (index < 0 || index >= tabs.length) return 'my plans';
    return tabs[index].text ?? 'my plans';
  }

  int _resolveInitialTabIndex(HomeUiConfig config) {
    if (config.isPostpaid && config.openMyLimits) {
      return 2;
    }
    if (config.isFuturePlan == true) {
      return 1;
    }
    if (config.isCurrentPlan == true) {
      return 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final HomeUiConfig config = context.watch<AppUiConfigCubit>().state;
    _syncControllerLength(config);
    final tabs = _tabs(config);
    final views = _tabViews(config);
    final controller = _tabController!;
    final title = _titleForIndex(controller.index, config);

    return BlocListener<AppUiConfigCubit, HomeUiConfig>(
      listenWhen: (p, c) =>
          (!p.isFuturePlan && c.isFuturePlan) ||
          (!p.openMyLimits && c.openMyLimits) ||
          (!p.isCurrentPlan && c.isCurrentPlan),
      listener: (_, state) => _handleNavigationIntent(state),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: UsageScreen.purple,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: UsageScreen.purple,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontFamily: 'CircularPro',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(82),
            child: UsageTabBar(tabs: tabs, controller: controller),
          ),
        ),
        body: TabBarView(controller: controller, children: views),
      ),
    );
  }
}

class UsageTabBar extends StatelessWidget {
  static const Color purple = Color(0xFF645D9C);
  static const Color grey = Color(0xFF9E9E9E); // Color(0xFF707070)
  static const Color dividerBg = Color(0xFFF4F6FB);
  final List<Tab> tabs;
  final TabController controller;

  const UsageTabBar({super.key, required this.tabs, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Tabs
          SizedBox(height: 20),
          TabBar(
            controller: controller,
            indicatorSize: TabBarIndicatorSize.tab,
            // 🔥 full tab width
            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(color: purple, width: 2),
              insets: EdgeInsets.symmetric(horizontal: 8),
            ),
            labelColor: purple,
            unselectedLabelColor: Color(0xFF707070),
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
            tabs: tabs,
          ),

          // Divider background (important!)
          Container(height: 24, color: dividerBg),
        ],
      ),
    );
  }
}
