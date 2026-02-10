import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/bloc/reward_prepaid_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/bloc/reward_prepaid_event.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/bloc/reward_prepaid_state.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/repository/reward_prepaid_repository.dart';
import '../../../../login/widgets/login_bottom_stripes.dart';
import '../widgets/NoRewardCard..dart';
import '../widgets/reward_card.dart';

class RewardPrepaidScreen extends StatelessWidget {
  const RewardPrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RewardPrepaidBloc(RewardPrepaidRepository())
        ..add(FetchRewardPrepaidEvent()),
      child: const _RewardPrepaidView(),
    );
  }
}

class _RewardPrepaidView extends StatelessWidget {
  const _RewardPrepaidView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFFF0F1F9),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: BlocListener<RewardPrepaidBloc, RewardPrepaidState>(
          // one-time UI actions only
          listenWhen: (p, c) => p.action != c.action && c.action != null,
          listener: (context, state) {
            final action = state.action;

            if (action is NavigateToDeals) {
              // TODO: open url / deeplink
              // launchUrlString('https://bealiv.com/deals');
            } else if (action is OpenRewardDetails) {
              // TODO: navigate to details
              // context.push(AppRoutes.rewardDetails, extra: action.reward);
            } else if (action is StartGetThisFlow) {
              // TODO: start purchase/flow
              // context.push(AppRoutes.getThisFlow, extra: action.reward);
            }

            context.read<RewardPrepaidBloc>().add(const ClearRewardPrepaidAction());
          },
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: DefaultAppBar(
                        title: 'rewards',
                        showHome: true,
                        onHomeTap: () => context.go(AppRoutes.home),
                        onBack: () => context.pop(),
                      ),
                    ),

                    BlocBuilder<RewardPrepaidBloc, RewardPrepaidState>(
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

                        // success state
                        if (state.rewards.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                              child: NoRewardsPrepaid(
                                prefixText:
                                "looks like you're currently not eligible\nfor any rewards. visit ",
                                linkText: "bealiv.com/\ndeals",
                                suffixText: " to discover exciting offers!",
                                onLinkPressed: () => context
                                    .read<RewardPrepaidBloc>()
                                    .add(const DealsLinkTapped()),
                              ),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              final item = state.rewards[index];
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                                child: RewardPrepaidCard(
                                  title: item.title,
                                  description: item.description,
                                  amount: item.rewardAmount.toStringAsFixed(2),
                                  onGetThisPressed: () => context
                                      .read<RewardPrepaidBloc>()
                                      .add(GetThisTapped(item)),
                                  onReadMorePressed: () => context
                                      .read<RewardPrepaidBloc>()
                                      .add(ReadMoreTapped(item)),
                                ),
                              );
                            },
                            childCount: state.rewards.length,
                          ),
                        );
                      },
                    ),
                  ],
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
