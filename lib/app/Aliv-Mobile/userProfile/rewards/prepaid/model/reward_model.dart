import 'package:equatable/equatable.dart';

class RewardPrepaid extends Equatable {
  final String title;
  final String description;
  final double rewardAmount;

  const RewardPrepaid({
    required this.title,
    required this.description,
    required this.rewardAmount,
  });

  @override
  List<Object?> get props => [title, description, rewardAmount];
}
