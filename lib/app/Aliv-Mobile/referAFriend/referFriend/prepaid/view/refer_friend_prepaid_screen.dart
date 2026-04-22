import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/refer_friend_prepaid_bloc.dart';
import '../bloc/refer_friend_prepaid_event.dart';
import '../bloc/refer_friend_prepaid_state.dart';
import '../repository/refer_friend_prepaid_repository.dart';
import '../theme/refer_friend_prepaid_theme.dart';
import '../widgets/refer_friend_prepaid_redeem_tab.dart';
import '../widgets/refer_friend_prepaid_refer_tab.dart';
import '../widgets/refer_friend_prepaid_tabs.dart';

class ReferFriendPrepaidScreen extends StatelessWidget {
  const ReferFriendPrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    _useLightStatusBar();

    return BlocProvider(
      create: _createBloc,
      child: const _ReferFriendPrepaidView(),
    );
  }

  ReferFriendPrepaidBloc _createBloc(BuildContext context) {
    return ReferFriendPrepaidBloc(repository: ReferFriendPrepaidRepository())
      ..add(const ReferFriendPrepaidStarted());
  }

  void _useLightStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }
}

class _ReferFriendPrepaidView extends StatefulWidget {
  const _ReferFriendPrepaidView();

  @override
  State<_ReferFriendPrepaidView> createState() =>
      _ReferFriendPrepaidViewState();
}

class _ReferFriendPrepaidViewState extends State<_ReferFriendPrepaidView> {
  static const bool _allowTabSwipe = true;
  static const Duration _tabAnimationDuration = Duration(milliseconds: 220);

  late final PageController _tabPageController;

  // Prevents the same successful share state from pushing the success screen
  // again if the widget rebuilds or another unrelated state field changes.
  int _lastHandledShareSuccessRequestId = 0;

  @override
  void initState() {
    super.initState();
    _tabPageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _tabPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ReferFriendPrepaidTheme.bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocListener<ReferFriendPrepaidBloc, ReferFriendPrepaidState>(
          listenWhen: _shouldHandleStateSideEffects,
          listener: _handleStateSideEffects,
          child: Column(
            children: [_buildAppBar(), _buildTabs(), _buildTabPages()],
          ),
        ),
      ),
    );
  }

  bool _shouldHandleStateSideEffects(ReferFriendPrepaidState previous,ReferFriendPrepaidState current) {
    return previous.toastMessage != current.toastMessage ||
        previous.errorMessage != current.errorMessage ||
        previous.selectedTab != current.selectedTab ||
        previous.shareSuccessRequestId != current.shareSuccessRequestId;
  }

  void _handleStateSideEffects(
    BuildContext context,
    ReferFriendPrepaidState state,
  ) {
    _syncPageWithSelectedTab(state.selectedTab);
    _showToastMessage(context, state.toastMessage);
    _showErrorMessage(context, state.errorMessage);
    _openSuccessScreenWhenReferralIsReady(context, state);
  }

  void _syncPageWithSelectedTab(int selectedTab) {
    final currentPage =
        (_tabPageController.page ?? _tabPageController.initialPage).round();

    if (currentPage == selectedTab) return;

    _tabPageController.animateToPage(
      selectedTab,
      duration: _tabAnimationDuration,
      curve: Curves.easeOut,
    );
  }

  void _showToastMessage(BuildContext context, String? message) {
    if (message == null || message.isEmpty) return;

    AppToast.show(message: message, type: ToastType.success);
    context.read<ReferFriendPrepaidBloc>().add(
      const ReferFriendPrepaidToastConsumed(),
    );
  }

  void _showErrorMessage(BuildContext context, String? message) {
    if (message == null || message.isEmpty) return;

    AppToast.show(message: message, type: ToastType.error);
    context.read<ReferFriendPrepaidBloc>().add(
      const ReferFriendPrepaidErrorConsumed(),
    );
  }

  void _openSuccessScreenWhenReferralIsReady(
    BuildContext context,
    ReferFriendPrepaidState state,
  ) {
    final hasNewSuccessRequest =
        state.shareSuccessRequestId > _lastHandledShareSuccessRequestId;
    final referralCode = state.referralCode.trim();

    // The share API owns navigation. The refer tab only submits the form;
    // this listener opens the next screen after the API returns a code.
    if (!hasNewSuccessRequest || referralCode.isEmpty) return;

    _lastHandledShareSuccessRequestId = state.shareSuccessRequestId;

    final encodedCode = Uri.encodeComponent(referralCode);
    context.push('${AppRoutes.invitingSuccess}?code=$encodedCode');
  }

  Widget _buildAppBar() {
    return BlocBuilder<ReferFriendPrepaidBloc, ReferFriendPrepaidState>(
      buildWhen: (previous, current) =>
          previous.selectedTab != current.selectedTab,
      builder: (context, state) {
        return DefaultAppBar(
          title: _titleForTab(state.selectedTab),
          showHome: false,
          backgroundColor: ReferFriendPrepaidTheme.brand,
          onBack: () => context.pop(),
        );
      },
    );
  }

  Widget _buildTabs() {
    return BlocBuilder<ReferFriendPrepaidBloc, ReferFriendPrepaidState>(
      buildWhen: (previous, current) => previous.selectedTab != current.selectedTab,
      builder: (context, state) {
        return ReferFriendPrepaidTabs(
          selectedIndex: state.selectedTab,
          onChanged: (index) => context.read<ReferFriendPrepaidBloc>().add(
            ReferFriendPrepaidTabChanged(index),
          ),
        );
      },
    );
  }

  Widget _buildTabPages() {
    return Expanded(
      child: BlocBuilder<ReferFriendPrepaidBloc, ReferFriendPrepaidState>(
        buildWhen: (previous, current) =>
            previous.selectedTab != current.selectedTab ||
            previous.history != current.history,
        builder: (context, state) {
          return PageView(
            controller: _tabPageController,
            physics: _allowTabSwipe
                ? const BouncingScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => context
                .read<ReferFriendPrepaidBloc>()
                .add(ReferFriendPrepaidTabChanged(index)),
            children: const [
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: ReferFriendPrepaidReferTab(),
              ),
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: ReferFriendPrepaidRedeemTab(),
              ),
            ],
          );
        },
      ),
    );
  }

  String _titleForTab(int selectedTab) {
    return selectedTab == 2 ? 'Refer/Redeem' : 'refer a friend';
  }
}
