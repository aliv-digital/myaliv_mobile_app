import '../model/reward_model.dart';

class RewardPrepaidRepository {
  Future<List<RewardPrepaid>> fetchRewards() async {
    // Simulate API call to fetch rewards (you can replace this with actual API call)
    await Future.delayed(const Duration(seconds: 2));

    // Example data, replace with actual API data
    return [
      RewardPrepaid(
        title: 'Freeport Giveaway',
        description:
        'Congratulations! you are now eligible to purchase a one-time freedom30 plan for 10.00.',
        rewardAmount: 10.00,
      ),
      RewardPrepaid(
        title: 'Freeport Giveaway',
        description:
        'Congratulations! you are now eligible to purchase a one-time freedom30 plan for 10.00.',
        rewardAmount: 10.00,
      ),
    ];
  }
}
