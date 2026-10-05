import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/model/reward_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewardsDetails/prepaid/theme/reward_details_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewardsDetails/prepaid/widgets/reward_details_section.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/resources/widgets/striped_scaffold.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class RewardDetailsPrepaidScreen extends StatelessWidget {
  final RewardModel? reward;

  const RewardDetailsPrepaidScreen({super.key, this.reward});

  @override
  Widget build(BuildContext context) {
    return StripedScaffold(
      backgroundColor: RewardDetailsTheme.bg,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            DefaultAppBar(
              title: reward?.name ?? 'Reward Details',
              showHome: false,
              onHomeTap: () => context.go(AppRoutes.home),
              onBack: () => context.pop(),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (reward == null) {
      return const Center(child: Text('No reward details available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 31, 24, 18),
      child: SizedBox(
        width: double.infinity,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RewardDetailsSection(label: 'group name', value: reward!.name),
          const SizedBox(height: 18),
          RewardDetailsSection(
            label: 'promo start date',
            value: _formatDate(reward!.startDate),
          ),
          const SizedBox(height: 18),
          RewardDetailsSection(
            label: 'duration',
            value: reward!.duration == 0 ? '-' : reward!.duration.toString(),
          ),
          const SizedBox(height: 18),
          RewardDetailsSection(
            label: 'limit',
            value: reward!.limit == 0 ? '-' : reward!.limit.toString(),
          ),
          const SizedBox(height: 18),
          RewardDetailsSection(
            label: 'offer',
            value: reward!.offer ?? '-',
          ),
          const SizedBox(height: 18),
          RewardDetailsSection(label: 'status', value: reward!.status),
        ],
      ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('MMMM dd, yyyy').format(date);
  }
}
