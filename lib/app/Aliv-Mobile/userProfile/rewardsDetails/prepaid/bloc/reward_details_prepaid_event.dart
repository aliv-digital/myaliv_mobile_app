import 'package:equatable/equatable.dart';

abstract class RewardDetailsPrepaidEvent extends Equatable {
  const RewardDetailsPrepaidEvent();

  @override
  List<Object?> get props => [];
}

class FetchRewardDetailsPrepaid extends RewardDetailsPrepaidEvent {
  const FetchRewardDetailsPrepaid();
}
