import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/call_log_tab.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/cubit/call_logs_cubit.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/cubit/transactions_cubit.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/transaction_tab.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/widgets/month_selector.dart';

enum CallLogsTabType { transactions, callLogs }

class CallLogsScreen extends StatelessWidget {
  final CallLogsTabType initialTab;

  const CallLogsScreen({super.key, this.initialTab = CallLogsTabType.transactions});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => instance<CallLogsCubit>()..fetchUsages()),
        BlocProvider(create: (_) => instance<TransactionsCubit>()..fetchTransactions()),
      ],
      child: _CallLogsView(initialTab: initialTab),
    );
  }
}

class _CallLogsView extends StatefulWidget {
  final CallLogsTabType initialTab;

  const _CallLogsView({required this.initialTab});

  @override
  State<_CallLogsView> createState() => _CallLogsViewState();
}

class _CallLogsViewState extends State<_CallLogsView>
    with SingleTickerProviderStateMixin {
  static const Color _purple = Color(0xFF645D9C);
  static const Color _bg = Color(0xFFF4F6FB);

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTab == CallLogsTabType.transactions ? 0 : 1;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _purple,
        centerTitle: false,
        elevation: 0,
        toolbarHeight: 64,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: _purple,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 22.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'history',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 17,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 24), child: MonthSelector()),
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

  static const Color _purple = Color(0xFF645D9C);
  static const Color _grey = Color(0xFF9E9E9E);
  static const Color _black = Color(0xFF21232A);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: _purple, width: 2),
          insets: EdgeInsets.symmetric(horizontal: 32),
        ),
        labelColor: _black,
        unselectedLabelColor: _grey,
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
        tabs: const [Tab(text: 'transactions'), Tab(text: 'call logs')],
      ),
    );
  }
}
