import '../model/reward_details_prepaid_model.dart';

class RewardDetailsPrepaidRepository {
  Future<RewardDetailsPrepaidModel> fetchDetails() async {
    // TODO: replace with real API call
    await Future.delayed(const Duration(milliseconds: 600));

    return const RewardDetailsPrepaidModel(
      groupName: 'Freeport Giveaway',
      promoStartDate: '1 Month',
      duration: '1 month',
      limit: '1 time use only',
      offer: 'freedom6 plan For \$4.00',
      statusText: 'still active',
    );
  }
}
