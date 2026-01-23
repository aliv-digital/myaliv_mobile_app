import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import '../../../../login/widgets/login_bottom_stripes.dart';

import '../bloc/refer_friend_prepaid_bloc.dart';
import '../bloc/refer_friend_prepaid_event.dart';
import '../bloc/refer_friend_prepaid_state.dart';
import '../repository/refer_friend_prepaid_repository.dart';
import '../theme/refer_friend_prepaid_theme.dart';
import '../widgets/refer_friend_prepaid_tabs.dart';
import '../widgets/refer_friend_prepaid_refer_tab.dart';
import '../widgets/refer_friend_prepaid_redeem_tab.dart';
import '../widgets/refer_friend_prepaid_history_card.dart';

class ReferFriendPrepaidScreen extends StatelessWidget {
  const ReferFriendPrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return BlocProvider(
      create: (_) => ReferFriendPrepaidBloc(
        repository: ReferFriendPrepaidRepository(),
      )..add(const ReferFriendPrepaidStarted()),
      child: const _ReferFriendPrepaidView(),
    );
  }
}

class _ReferFriendPrepaidView extends StatefulWidget {
  const _ReferFriendPrepaidView();

  @override
  State<_ReferFriendPrepaidView> createState() => _ReferFriendPrepaidViewState();
}

class _ReferFriendPrepaidViewState extends State<_ReferFriendPrepaidView> {
  //  Future toggle:
  // true  => swipe enabled
  // false => swipe disabled
  static const bool _enableTabSwipe = true;

  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncPageToTab(int tabIndex) {
    final current = (_controller.page ?? _controller.initialPage).round();
    if (current == tabIndex) return;

    _controller.animateToPage(
      tabIndex,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReferFriendPrepaidTheme.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocListener<ReferFriendPrepaidBloc, ReferFriendPrepaidState>(
          listenWhen: (p, c) =>
          p.toastMessage != c.toastMessage ||
              p.errorMessage != c.errorMessage ||
              p.selectedTab != c.selectedTab,
          listener: (context, state) {
            // sync page when tab changes
            _syncPageToTab(state.selectedTab);

            final toast = state.toastMessage;
            if (toast != null && toast.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(toast)),
              );
              context.read<ReferFriendPrepaidBloc>().add(
                const ReferFriendPrepaidToastConsumed(),
              );
            }

            final err = state.errorMessage;
            if (err != null && err.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(err)),
              );
              context.read<ReferFriendPrepaidBloc>().add(
                const ReferFriendPrepaidErrorConsumed(),
              );
            }
          },
          child: Column(
            children: [
              // ✅ sticky appbar (won't scroll)
              BlocBuilder<ReferFriendPrepaidBloc, ReferFriendPrepaidState>(
                buildWhen: (p, c) => p.selectedTab != c.selectedTab,
                builder: (context, state) {
                  final title = state.selectedTab == 2 ? 'Refer/Redeem' : 'refer a friend';

                  return DefaultAppBar(
                    title: title,
                    showHome: false,
                    backgroundColor: ReferFriendPrepaidTheme.brand,

                    onBack: () => context.pop(),
                  );
                },
              ),

              // ✅ sticky tabs (also won't scroll)
              BlocBuilder<ReferFriendPrepaidBloc, ReferFriendPrepaidState>(
                buildWhen: (p, c) => p.selectedTab != c.selectedTab,
                builder: (context, state) {
                  return ReferFriendPrepaidTabs(
                    selectedIndex: state.selectedTab,
                    onChanged: (i) => context
                        .read<ReferFriendPrepaidBloc>()
                        .add(ReferFriendPrepaidTabChanged(i)),
                  );
                },
              ),

              // ✅ tab content area (scrolls inside)
              Expanded(
                child: BlocBuilder<ReferFriendPrepaidBloc, ReferFriendPrepaidState>(
                  buildWhen: (p, c) =>
                  p.selectedTab != c.selectedTab || p.history != c.history,
                  builder: (context, state) {
                    return PageView(
                      controller: _controller,
                      physics: _enableTabSwipe
                          ? const BouncingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        // user swiped -> update tab
                        context
                            .read<ReferFriendPrepaidBloc>()
                            .add(ReferFriendPrepaidTabChanged(index));
                      },
                      children: [
                        // Refer
                        const SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: ReferFriendPrepaidReferTab(),
                        ),

                        // Redeem
                        const SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: ReferFriendPrepaidRedeemTab(),
                        ),

                        // History
                        _HistoryTab(history: state.history),
                      ],
                    );
                  },
                ),
              ),

              const BottomStripes(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final List<dynamic> history; // actual type in state is ReferralHistoryItem

  const _HistoryTab({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          'No history found',
          style: TextStyle(
            fontFamily: 'CircularPro',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: ReferFriendPrepaidTheme.muted,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        itemCount: history.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, index) {
          final item = history[index];
          return ReferFriendPrepaidHistoryCard(
            item: item,
            onCopy: () => context.read<ReferFriendPrepaidBloc>().add(
              ReferFriendPrepaidCopyPressed(item.code),
            ),
          );
        },
      ),
    );
  }
}
