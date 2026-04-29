import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/login_bottom_stripes.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/bloc/reward_prepaid_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/bloc/reward_prepaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/widgets/NoRewardCard..dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/widgets/reward_card.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/top_toast.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class RewardPrepaidScreen extends StatelessWidget {
  const RewardPrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => instance<RewardPrepaidCubit>()..fetchRewards(),
      child: const _RewardPrepaidView(),
    );
  }
}

class _RewardPrepaidView extends StatelessWidget {
  const _RewardPrepaidView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F9),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocListener<RewardPrepaidCubit, RewardPrepaidState>(
          listenWhen: (p, c) => p.action != c.action && c.action != null,
          listener: (context, state) async {
            final action = state.action;
            final rewardCubit = context.read<RewardPrepaidCubit>();

            if (action is NavigateToDeals) {
              final uri = Uri.parse('https://www.bealiv.com/deals/');

              if (!await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              )) {
                AppToast.show(
                  message: 'Could not open rewards',
                  type: ToastType.error,
                );
              }
            } else if (action is OpenRewardDetails) {
              context.push(
                AppRoutes.rewardDetailsPrepaidScreen,
                extra: action.reward,
              );
            } else if (action is StartGetThisFlow) {
              context.go(AppRoutes.plans);
            }

            rewardCubit.clearAction();
          },
          child: Column(
            children: [
              Expanded(child: _buildContent(context)),
              const BottomStripes(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: DefaultAppBar(
            title: 'rewards',
            showHome: true,
            onHomeTap: () => context.go(AppRoutes.home),
            onBack: () => context.pop(),
          ),
        ),
        BlocBuilder<RewardPrepaidCubit, RewardPrepaidState>(
          builder: (context, state) {
            if (state.status == RewardPrepaidStatus.loading ||
                state.status == RewardPrepaidStatus.initial) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state.status == RewardPrepaidStatus.failure) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(state.errorMessage ?? 'Something went wrong'),
                ),
              );
            }

            if (state.rewards.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                  child: NoRewardsPrepaid(
                    prefixText: "looks like you're currently not eligible\nfor any rewards. visit ",
                    linkText: "bealiv.com/\ndeals",
                    suffixText: " to discover exciting offers!",
                    onLinkPressed: () =>
                        context.read<RewardPrepaidCubit>().onDealsLinkTapped(),
                  ),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final reward = state.rewards[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                    child: RewardPrepaidCard(
                      reward: reward,
                      onGetThisPressed: () => context
                          .read<RewardPrepaidCubit>()
                          .onGetThisTapped(reward),
                      onReadMorePressed: () => context
                          .read<RewardPrepaidCubit>()
                          .onReadMoreTapped(reward),
                    ),
                  );
                },
                childCount: state.rewards.length,
              ),
            );
          },
        ),
      ],
    );
  }
}
