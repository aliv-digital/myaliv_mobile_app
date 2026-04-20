import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/login/widgets/login_bottom_stripes.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/model/reward_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewardsDetails/prepaid/theme/reward_details_theme.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewardsDetails/prepaid/widgets/reward_details_section.dart';
import 'package:myaliv_mobile_app/resources/widgets/default_app_bar.dart';
import 'package:myaliv_mobile_app/router/app_routes.dart';

class RewardDetailsPrepaidScreen extends StatelessWidget {
  final RewardModel? reward;

  const RewardDetailsPrepaidScreen({super.key, this.reward});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RewardDetailsTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            DefaultAppBar(
              title: reward?.name ?? 'Reward Details',
              showHome: false,
              onHomeTap: () => context.go(AppRoutes.home),
              onBack: () => context.pop(),
            ),
            Expanded(child: _buildContent()),
            const BottomStripes(),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RewardDetailsSection(label: 'name', value: reward!.name),
          const SizedBox(height: 18),
          RewardDetailsSection(label: 'category', value: reward!.categoryName),
          const SizedBox(height: 18),
          RewardDetailsSection(label: 'level', value: reward!.levelName),
          const SizedBox(height: 18),
          RewardDetailsSection(label: 'short description', value: reward!.shortDesc),
          const SizedBox(height: 18),
          RewardDetailsSection(label: 'full description', value: reward!.fullDesc),
          const SizedBox(height: 18),
          RewardDetailsSection(label: 'terms & conditions', value: reward!.terms),
          const SizedBox(height: 18),
          RewardDetailsSection(
            label: 'start date',
            value: _formatDate(reward!.startDate),
          ),
          const SizedBox(height: 18),
          RewardDetailsSection(
            label: 'end date',
            value: _formatDate(reward!.endDate),
          ),
          const SizedBox(height: 18),
          RewardDetailsSection(
            label: 'status',
            value: reward!.isActive ? 'Active' : 'Expired',
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('MMMM dd, yyyy').format(date);
  }
}
