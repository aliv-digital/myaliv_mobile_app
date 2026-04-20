import 'package:equatable/equatable.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/model/reward_model.dart';

enum RewardPrepaidStatus { initial, loading, success, failure }

sealed class RewardPrepaidAction extends Equatable {
  const RewardPrepaidAction();
  @override
  List<Object?> get props => [];
}

class NavigateToDeals extends RewardPrepaidAction {
  const NavigateToDeals();
}

class OpenRewardDetails extends RewardPrepaidAction {
  final RewardModel reward;
  const OpenRewardDetails(this.reward);

  @override
  List<Object?> get props => [reward];
}

class StartGetThisFlow extends RewardPrepaidAction {
  final RewardModel reward;
  const StartGetThisFlow(this.reward);

  @override
  List<Object?> get props => [reward];
}

class RewardPrepaidState extends Equatable {
  final RewardPrepaidStatus status;
  final List<RewardModel> rewards;
  final String? errorMessage;
  final RewardPrepaidAction? action;

  const RewardPrepaidState({
    required this.status,
    required this.rewards,
    this.errorMessage,
    this.action,
  });

  factory RewardPrepaidState.initial() => const RewardPrepaidState(
        status: RewardPrepaidStatus.initial,
        rewards: [],
        errorMessage: null,
        action: null,
      );

  @override
  List<Object?> get props => [status, rewards, errorMessage, action];

  RewardPrepaidState copyWith({
    RewardPrepaidStatus? status,
    List<RewardModel>? rewards,
    String? errorMessage,
    RewardPrepaidAction? action,
    bool clearAction = false,
  }) {
    return RewardPrepaidState(
      status: status ?? this.status,
      rewards: rewards ?? this.rewards,
      errorMessage: errorMessage ?? this.errorMessage,
      action: clearAction ? null : (action ?? this.action),
    );
  }
}
