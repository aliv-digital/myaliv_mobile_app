import 'package:equatable/equatable.dart';
import '../model/reward_model.dart';

abstract class RewardPrepaidEvent extends Equatable {
  const RewardPrepaidEvent();
  @override
  List<Object?> get props => [];
}

class FetchRewardPrepaidEvent extends RewardPrepaidEvent {}

class GetThisTapped extends RewardPrepaidEvent {
  final RewardPrepaid reward;
  const GetThisTapped(this.reward);

  @override
  List<Object?> get props => [reward];
}

class ReadMoreTapped extends RewardPrepaidEvent {
  final RewardPrepaid reward;
  const ReadMoreTapped(this.reward);

  @override
  List<Object?> get props => [reward];
}

class DealsLinkTapped extends RewardPrepaidEvent {
  const DealsLinkTapped();
}

class ClearRewardPrepaidAction extends RewardPrepaidEvent {
  const ClearRewardPrepaidAction();
}
