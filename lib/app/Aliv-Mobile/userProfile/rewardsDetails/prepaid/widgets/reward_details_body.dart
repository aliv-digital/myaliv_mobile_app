import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/reward_details_prepaid_bloc.dart';
import '../bloc/reward_details_prepaid_state.dart';
import '../widgets/reward_details_section.dart';

class RewardDetailsBody extends StatelessWidget {
  const RewardDetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RewardDetailsPrepaidBloc, RewardDetailsPrepaidState>(
      builder: (context, state) {
        if (state.status == RewardDetailsPrepaidStatus.initial ||
            state.status == RewardDetailsPrepaidStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == RewardDetailsPrepaidStatus.failure) {
          return Padding(
            padding: const EdgeInsets.all(18),
            child: Text(state.errorMessage ?? 'Something went wrong'),
          );
        }

        final d = state.details;
        if (d == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RewardDetailsSection(label: 'group name', value: d.groupName),
              const SizedBox(height: 18),
              RewardDetailsSection(label: 'promo start date', value: d.promoStartDate),
              const SizedBox(height: 18),
              RewardDetailsSection(label: 'duration', value: d.duration),
              const SizedBox(height: 18),
              RewardDetailsSection(label: 'limit', value: d.limit),
              const SizedBox(height: 18),
              RewardDetailsSection(label: 'offer', value: d.offer),
              const SizedBox(height: 18),
              RewardDetailsSection(label: 'status', value: d.statusText),
            ],
          ),
        );
      },
    );
  }
}
