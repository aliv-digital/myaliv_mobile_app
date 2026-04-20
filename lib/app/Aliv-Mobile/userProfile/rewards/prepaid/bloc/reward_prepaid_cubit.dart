import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/model/reward_model.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/repository/reward_prepaid_repository.dart';

import 'reward_prepaid_state.dart';

class RewardPrepaidCubit extends Cubit<RewardPrepaidState> {
  final RewardPrepaidRepository rewardRepository;

  RewardPrepaidCubit(this.rewardRepository) : super(RewardPrepaidState.initial());

  Future<void> fetchRewards() async {
    emit(state.copyWith(
      status: RewardPrepaidStatus.loading,
      errorMessage: null,
      clearAction: true,
    ));
    try {
      final rewards = await rewardRepository.fetchRewards();
      emit(state.copyWith(status: RewardPrepaidStatus.success, rewards: rewards));
    } catch (e) {
      emit(state.copyWith(
        status: RewardPrepaidStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void onGetThisTapped(RewardModel reward) {
    emit(state.copyWith(action: StartGetThisFlow(reward)));
  }

  void onReadMoreTapped(RewardModel reward) {
    emit(state.copyWith(action: OpenRewardDetails(reward)));
  }

  void onDealsLinkTapped() {
    emit(state.copyWith(action: const NavigateToDeals()));
  }

  void clearAction() {
    emit(state.copyWith(clearAction: true));
  }
}
