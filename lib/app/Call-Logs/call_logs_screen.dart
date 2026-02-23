import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/transaction_tab.dart';

import 'call_log_tab.dart';

enum CallLogsTabType { transactions, callLogs }

class CallLogsScreen extends StatefulWidget {
  final CallLogsTabType initialTab;

  const CallLogsScreen({
    super.key,
    this.initialTab = CallLogsTabType.transactions,
  });

  @override
  State<CallLogsScreen> createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends State<CallLogsScreen>
    with SingleTickerProviderStateMixin {
  static const Color purple = Color(0xFF645D9C); //Color(0xFF6C63A6);
  static const Color bg = Color(0xFFF4F6FB);

  late final TabController _tabController;
  late final ValueNotifier<String> _titleNotifier;

  @override
  void initState() {
    super.initState();

    final initialIndex = widget.initialTab == CallLogsTabType.transactions
        ? 0
        : 1;

    _titleNotifier = ValueNotifier(_titleForIndex(initialIndex));

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _titleNotifier.value = _titleForIndex(_tabController.index);
    });
  }

  String _titleForIndex(int index) {
    return index == 0 ? 'history' : 'history';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: purple,
        centerTitle: false,
        elevation: 0,
        toolbarHeight: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 22.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: ValueListenableBuilder<String>(
          valueListenable: _titleNotifier,
          builder: (_, title, __) {
            return Text(
              title,
              style: const TextStyle(
                fontFamily: 'CircularPro',
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            );
          },
        ),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 24), child: _MonthSelector()),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _CallLogsTabBar(controller: _tabController),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [TransactionsTab(), CallLogsTab()],
      ),
    );
  }
}

class _CallLogsTabBar extends StatelessWidget {
  final TabController controller;

  const _CallLogsTabBar({required this.controller});

  static const Color purple = Color(0xFF645D9C);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color blue = Color(0xFF0143EC);
  static const Color black = Color(0xFF21232A);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: purple, width: 2),
          insets: EdgeInsets.symmetric(horizontal: 32),
        ),
        labelColor: black,
        unselectedLabelColor: grey,
        labelStyle: const TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'CircularPro',
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'transactions'),
          Tab(text: 'call logs'),
        ],
      ),
    );
    // return Container(
    //   color: Colors.white,
    //   child: TabBar(
    //     indicatorSize: TabBarIndicatorSize.tab,
    //     indicator: const UnderlineTabIndicator(
    //       borderSide: BorderSide(color: purple, width: 3),
    //       insets: EdgeInsets.symmetric(horizontal: 32),
    //     ),
    //     labelColor: purple,
    //     unselectedLabelColor: grey,
    //     labelStyle: const TextStyle(
    //       fontFamily: 'CircularPro',
    //       fontSize: 14,
    //       fontWeight: FontWeight.w600,
    //     ),
    //     unselectedLabelStyle: const TextStyle(
    //       fontFamily: 'CircularPro',
    //       fontSize: 14,
    //       fontWeight: FontWeight.w400,
    //     ),
    //     tabs: const [
    //       Tab(text: 'transactions'),
    //       Tab(text: 'call logs'),
    //     ],
    //   ),
    // );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector();

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.calendar_today, size: 14),
          const SizedBox(width: 8),
          Text(
            'July 2024',
            style: TextStyle(
              color: const Color(0xFF222222),
              fontSize: 14,
              fontFamily: 'CircularPro',
              fontWeight: FontWeight.w500,
              height: 1.43,
            ),
          ),
          SizedBox(width: 8),
          // Icon(Icons.chevron_down, size: 18),
          SvgPicture.asset('assets/icons/CHEVRON-DOWN.svg'),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
