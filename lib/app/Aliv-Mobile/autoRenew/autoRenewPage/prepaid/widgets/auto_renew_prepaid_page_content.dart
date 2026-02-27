import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

import '../bloc/auto_renew_prepaid_bloc.dart';
import '../bloc/auto_renew_prepaid_event.dart';
import '../bloc/auto_renew_prepaid_state.dart';
import '../theme/auto_renew_prepaid_theme.dart';
import 'auto_renew_payment_method_section.dart';
import 'auto_renew_prepaid_proceed_action_button.dart';
import 'dashed_add_card_button.dart';

class AutoRenewPrepaidPageContent extends StatelessWidget {
  const AutoRenewPrepaidPageContent({super.key});

  // ==================== Page Scaffold ====================
  // Build the visual shell and bind bloc state to UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AutoRenewPrepaidTheme.pageBg,
      body: SafeArea(
        child: BlocBuilder<AutoRenewPrepaidBloc, AutoRenewPrepaidState>(
          builder: _buildFromState,
        ),
      ),
    );
  }

  // ==================== State Builder ====================
  // Rebuild slivers whenever feature state changes.
  Widget _buildFromState(
    BuildContext context,
    AutoRenewPrepaidState autoRenewPrepaidState,
  ) {
    final AutoRenewPrepaidBloc autoRenewPrepaidBloc = context
        .read<AutoRenewPrepaidBloc>();

    return CustomScrollView(
      slivers: [
        _buildPinnedAppBar(context, autoRenewPrepaidBloc),
        if (autoRenewPrepaidState.loadStatus == AutoRenewLoadStatus.loading)
          _buildLoadingSliver()
        else
          _buildContentSliver(
            context,
            autoRenewPrepaidState,
            autoRenewPrepaidBloc,
          ),
      ],
    );
  }

  // ==================== Pinned App Bar ====================
  // Keep top actions visible while content scrolls.
  Widget _buildPinnedAppBar(
    BuildContext context,
    AutoRenewPrepaidBloc autoRenewPrepaidBloc,
  ) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _PinnedHeaderDelegate(
        height: AutoRenewPrepaidTheme.appBarHeight,
        child: DefaultAppBar(
          showHome: true,
          title: 'auto renew',
          onBack: () {
            Navigator.of(context).maybePop();
          },
          onHomeTap: () {
            // autoRenewPrepaidBloc.add(const AutoRenewHomePressed());
            context.go(AppRoutes.home);
          },
        ),
      ),
    );
  }

  // ==================== Loading State ====================
  // Use full remaining space for loading feedback.
  Widget _buildLoadingSliver() {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  // ==================== Content Wrapper ====================
  // Apply feature-level page padding around content sections.
  Widget _buildContentSliver(
    BuildContext context,
    AutoRenewPrepaidState autoRenewPrepaidState,
    AutoRenewPrepaidBloc autoRenewPrepaidBloc,
  ) {
    return SliverPadding(
      padding: AutoRenewPrepaidTheme.bodyPadding,
      sliver: SliverToBoxAdapter(
        child: _buildContentColumn(
          context,
          autoRenewPrepaidState,
          autoRenewPrepaidBloc,
        ),
      ),
    );
  }

  // ==================== Content Sections ====================
  // Render payment method list, add-card action, and proceed action.
  Widget _buildContentColumn(
    BuildContext context,
    AutoRenewPrepaidState autoRenewPrepaidState,
    AutoRenewPrepaidBloc autoRenewPrepaidBloc,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoRenewPaymentMethodSection(
          methods: autoRenewPrepaidState.methods,
          selectedMethodId: autoRenewPrepaidState.selectedMethodId,
          onSelect: (String selectedMethodId) {
            autoRenewPrepaidBloc.add(AutoRenewMethodSelected(selectedMethodId));
          },
        ),
        const SizedBox(height: AutoRenewPrepaidTheme.sectionToDashedGap),
        DashedAddCardButton(
          onTap: () {
            autoRenewPrepaidBloc.add(const AutoRenewAddNewCardPressed());
          },
        ),
        const SizedBox(height: AutoRenewPrepaidTheme.dashedToActionGap),
        AutoRenewPrepaidProceedActionButton(
          isEnabled: autoRenewPrepaidState.canProceed,
          isLoading: autoRenewPrepaidState.savingSelection,
          onPressed: () => context.push(AppRoutes.autoRenewAuthPrepaidScreen),
        ),
      ],
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Widget child;

  const _PinnedHeaderDelegate({required this.height, required this.child});

  // ==================== Sliver Extent ====================
  // Fix both extents to avoid dynamic height changes.
  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  // ==================== Header Build ====================
  // Respect fixed extent contract by wrapping child in SizedBox.
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: height, child: child);
  }

  // ==================== Rebuild Rule ====================
  // Rebuild only when layout inputs are changed.
  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
