import 'package:flutter/material.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/transaction_tab.dart';

import 'call_log_tab.dart';

class CallLogsScreen extends StatelessWidget {
  const CallLogsScreen({super.key});

  static const Color purple = Color(0xFF6C63A6);
  static const Color bg = Color(0xFFF4F6FB);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: purple,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'call logs',
            style: TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: _MonthSelector(),
            ),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(52),
            child: _CallLogsTabBar(),
          ),
        ),
        body: const TabBarView(
          children: [
            TransactionsTab(),
            CallLogsTab(),
          ],
        ),
      ),
    );
  }
}
class _CallLogsTabBar extends StatelessWidget {
  const _CallLogsTabBar();

  static const Color purple = Color(0xFF6C63A6);
  static const Color grey = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: purple, width: 3),
          insets: EdgeInsets.symmetric(horizontal: 32),
        ),
        labelColor: purple,
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
  }
}
class _MonthSelector extends StatelessWidget {
  const _MonthSelector();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Text(
            'July 2024',
            style: TextStyle(
              fontFamily: 'CircularPro',
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }
}
