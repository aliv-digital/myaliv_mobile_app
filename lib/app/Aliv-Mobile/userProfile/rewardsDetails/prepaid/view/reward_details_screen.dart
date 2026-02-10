import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';
import '../../../../login/widgets/login_bottom_stripes.dart';
import '../bloc/reward_details_prepaid_bloc.dart';
import '../bloc/reward_details_prepaid_event.dart';
import '../bloc/reward_details_prepaid_state.dart';
import '../repository/reward_details_prepaid_repository.dart';
import '../widgets/reward_details_section.dart';
import '../theme/reward_details_theme.dart';

class RewardDetailsPrepaidScreen extends StatelessWidget {
  const RewardDetailsPrepaidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RewardDetailsPrepaidBloc(
        repository: RewardDetailsPrepaidRepository(),
      )..add(const FetchRewardDetailsPrepaid()),
      child: const _RewardDetailsView(),
    );
  }
}

class _RewardDetailsView extends StatelessWidget {
  const _RewardDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RewardDetailsTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            DefaultAppBar(
              title: 'Freeport Giveaway',
              showHome: true,
              onHomeTap: () => context.go(AppRoutes.home),
              onBack: () => context.pop(),
            ),
            Expanded(
              child: BlocBuilder<RewardDetailsPrepaidBloc, RewardDetailsPrepaidState>(
                builder: (context, state) {
                  return CustomScrollView(
                    slivers: [
                      if (state.status == RewardDetailsPrepaidStatus.initial ||
                          state.status == RewardDetailsPrepaidStatus.loading)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (state.status == RewardDetailsPrepaidStatus.failure)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Text(state.errorMessage ?? 'Something went wrong'),
                          ),
                        )
                      else
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 31, 24, 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RewardDetailsSection(
                                  label: 'group name',
                                  value: state.details?.groupName ?? '-',
                                ),
                                const SizedBox(height: 18),
                                RewardDetailsSection(
                                  label: 'promo start date',
                                  value: state.details?.promoStartDate ?? '-',
                                ),
                                const SizedBox(height: 18),
                                RewardDetailsSection(
                                  label: 'duration',
                                  value: state.details?.duration ?? '-',
                                ),
                                const SizedBox(height: 18),
                                RewardDetailsSection(
                                  label: 'limit',
                                  value: state.details?.limit ?? '-',
                                ),
                                const SizedBox(height: 18),
                                RewardDetailsSection(
                                  label: 'offer',
                                  value: state.details?.offer ?? '-',
                                ),
                                const SizedBox(height: 18),
                                RewardDetailsSection(
                                  label: 'status',
                                  value: state.details?.statusText ?? '-',
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const BottomStripes(),
          ],
        ),
      ),
    );
  }
}
