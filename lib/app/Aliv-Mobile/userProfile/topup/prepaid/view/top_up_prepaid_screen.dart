import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/top_up_prepaid_bloc.dart';
import '../bloc/top_up_prepaid_event.dart';
import '../bloc/top_up_prepaid_state.dart';
import '../theme/top_up_prepaid_theme.dart';

import '../widgets/send_top_up_placeholder_tab.dart';
import '../widgets/top_up_prepaid_tabs.dart';
import '../widgets/top_up_prepaid_balance_row.dart';
import '../widgets/top_up_prepaid_amount_box.dart';
import '../widgets/top_up_prepaid_primary_button.dart';
import '../widgets/top_up_prepaid_placeholder_tab.dart';

class TopUpPrepaidScreen extends StatefulWidget {
  const TopUpPrepaidScreen({super.key});

  @override
  State<TopUpPrepaidScreen> createState() => _TopUpPrepaidScreenState();
}

class _TopUpPrepaidScreenState extends State<TopUpPrepaidScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TopUpPrepaidBloc()..add(const TopUpPrepaidStarted()),
      child: const _TopUpPrepaidView(),
    );
  }
}

class _TopUpPrepaidView extends StatefulWidget {
  const _TopUpPrepaidView();

  @override
  State<_TopUpPrepaidView> createState() => _TopUpPrepaidViewState();
}

class _TopUpPrepaidViewState extends State<_TopUpPrepaidView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // ✅ swipe করলে bloc এ state sync হবে
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      context.read<TopUpPrepaidBloc>().add(TopUpPrepaidTabChanged(_tabController.index));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TopUpPrepaidBloc, TopUpPrepaidState>(
      listenWhen: (p, c) => p.errorMessage != c.errorMessage || p.submitStatus != c.submitStatus,
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }

        if (state.submitStatus == TopUpPrepaidSubmitStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Top up successful')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: TopUpPrepaidTheme.pageBg,
        body: SafeArea(
          child: BlocBuilder<TopUpPrepaidBloc, TopUpPrepaidState>(
            builder: (context, state) {
              // ✅ bloc -> tab controller sync (tap থেকে index change হলে)
              if (_tabController.index != state.selectedTabIndex) {
                _tabController.animateTo(state.selectedTabIndex);
              }

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    backgroundColor: TopUpPrepaidTheme.primary,
                    centerTitle: false,
                    elevation: 0,
                    leading: IconButton(
                      icon: Padding(
                        padding: const EdgeInsets.only(left: 24.0),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    title: Text('top-up', style: TopUpPrepaidTheme.appBarTitle()),
                  ),

                  // Tabs row (below appbar)
                  SliverToBoxAdapter(
                    child: TopUpPrepaidTabs(controller: _tabController),
                  ),

                  if (state.loadStatus == TopUpPrepaidLoadStatus.loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(), // ✅ swipe support
                        children: [
                          // -------------------------
                          // Tab 0: My Number (DONE)
                          // -------------------------
                          _MyNumberTab(state: state),

                          // Tab 1: placeholder (future)
                          const TopUpPrepaidPlaceholderTab(title: 'auto top-up'),

                          // Tab 2: placeholder (future)
                           SendTopUpPlaceholderTab(title: 'send top-up'),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MyNumberTab extends StatelessWidget {
  final TopUpPrepaidState state;

  const _MyNumberTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TopUpPrepaidBloc>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          child: Column(
            children: [
              const SizedBox(height: 75),

              // Balance row
              Text(
                'enter top-up amount',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF222222),
                  fontSize: 12,
                  fontFamily: 'CircularPro',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),

              // Amount input box (gradient border)
              TopUpPrepaidAmountBox(
                value: state.amountText,
                onChanged: (v) => bloc.add(TopUpPrepaidAmountChanged(v)),
              ),
              const SizedBox(height: 16),

              TopUpPrepaidBalanceRow(balance: state.balance),

              const SizedBox(height: 44),

              // CTA button
              TopUpPrepaidPrimaryButton(
                enabled: state.canSubmit,
                loading: state.submitStatus == TopUpPrepaidSubmitStatus.loading,
                onTap: () {
                  //bloc.add(const TopUpPrepaidTopUpPressed());
                  context.push(AppRoutes.confirmTopUpPrepaidScreen);
                }
              ),

              // Keep spacing similar to screenshot (keyboard will push anyway)
            ],
          ),
        ),
      ),
    );
  }
}
