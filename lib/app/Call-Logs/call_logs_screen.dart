import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/call_log_tab.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/cubit/call_logs_cubit.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/cubit/transactions_cubit.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/transaction_tab.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_otp_route_args.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_gate_screen.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/call_logs_verification_repository.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/verification/history_route_observer.dart';
import 'package:myaliv_mobile_app/app/Call-Logs/widgets/month_selector.dart';
import 'package:myaliv_mobile_app/app/common/verification/protected_access_entry.dart';
import 'package:myaliv_mobile_app/app/common/verification/protected_account_access_verification_session.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

enum CallLogsTabType { transactions, callLogs }

class CallLogsScreen extends StatefulWidget {
  final CallLogsTabType initialTab;

  const CallLogsScreen({
    super.key,
    this.initialTab = CallLogsTabType.transactions,
  });

  @visibleForTesting
  static Widget buildTabBarForTesting(TabController controller) =>
      _CallLogsTabBar(controller: controller);

  @override
  State<CallLogsScreen> createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends State<CallLogsScreen> {
  @override
  Widget build(BuildContext context) {
    final tree = MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => instance<CallLogsCubit>()..fetchUsages()),
        BlocProvider(
          create: (_) => instance<TransactionsCubit>()..fetchTransactions(),
        ),
      ],
      child: _CallLogsView(initialTab: widget.initialTab),
    );
    // Only the Call Logs tab is protected. Entering directly on Call Logs
    // keeps the screen-level gate so no fetches run before OTP success.
    // Entering on Transactions skips the gate; switching to the Call Logs
    // tab mid-screen is intercepted inside `_CallLogsView`.
    if (widget.initialTab == CallLogsTabType.callLogs) {
      return ProtectedAccessEntry(
        observer: historyRouteObserver,
        gate: const CallLogsVerificationGateScreen(
          destination: HistoryDestination.callLogs,
        ),
        child: tree,
      );
    }
    return tree;
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
  static const int _transactionsIndex = 0;
  static const int _callLogsIndex = 1;

  late final TabController _tabController;
  late final ProtectedAccountAccessVerificationSession _session;
  int _lastHandledIndex = 0;
  bool _requestingCallLogsChallenge = false;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTab == CallLogsTabType.transactions
        ? _transactionsIndex
        : _callLogsIndex;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialIndex,
    );
    _lastHandledIndex = initialIndex;
    _session = instance<ProtectedAccountAccessVerificationSession>();
    _tabController.addListener(_onTabChanged);
    _session.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _session.removeListener(_onSessionChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == _lastHandledIndex) return;
    _lastHandledIndex = _tabController.index;
    if (_tabController.index == _callLogsIndex && !_session.isVerified) {
      _tabController.animateTo(_transactionsIndex);
      _lastHandledIndex = _transactionsIndex;
      _requestCallLogsVerification();
    }
  }

  void _onSessionChanged() {
    if (!mounted) return;
    if (_session.isVerified) return;
    if (_tabController.index != _callLogsIndex) return;
    _tabController.animateTo(_transactionsIndex);
    _lastHandledIndex = _transactionsIndex;
    AppToast.show(
      message: 'Session expired. Please re-verify to view call logs.',
      type: ToastType.error,
    );
  }

  Future<void> _requestCallLogsVerification() async {
    if (_requestingCallLogsChallenge) return;
    if (_session.isVerified) {
      _tabController.animateTo(_callLogsIndex);
      return;
    }
    setState(() => _requestingCallLogsChallenge = true);
    final generation = _session.generation;
    final ownerRoute = ModalRoute.of(context);
    try {
      final challenge = await instance<CallLogsVerificationRepository>()
          .requestChallenge();
      if (!mounted) return;
      if (_session.generation != generation || ownerRoute?.isCurrent != true) {
        return;
      }
      final verified = await context.push<bool>(
        AppRoutes.callLogsOtp,
        extra: CallLogsOtpRouteArgs(
          mfaToken: challenge.mfaToken,
          apiPhoneNumber: challenge.apiPhoneNumber,
          destination: HistoryDestination.callLogs,
          returnInPlace: true,
        ),
      );
      if (!mounted) return;
      if (verified == true && _session.isVerified) {
        _tabController.animateTo(_callLogsIndex);
        _lastHandledIndex = _callLogsIndex;
      }
    } catch (error) {
      if (!mounted) return;
      AppToast.show(message: error.toString(), type: ToastType.error);
    } finally {
      if (mounted) {
        setState(() => _requestingCallLogsChallenge = false);
      }
    }
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
  static const Color _grey = Color(0xFF707070);

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
        labelColor: _purple,
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
        tabs: const [
          Tab(text: 'transactions'),
          Tab(text: 'call logs'),
        ],
      ),
    );
  }
}
