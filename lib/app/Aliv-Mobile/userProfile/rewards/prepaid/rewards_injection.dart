import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/bloc/reward_prepaid_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/repository/reward_prepaid_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/rewards/prepaid/repository/services/rewards_api_client.dart';

/// Sets up dependency injection for Rewards feature.
///
/// Registers:
/// - RewardsApiClient (API layer)
/// - RewardPrepaidRepository (business logic)
/// - RewardPrepaidCubit (state management) - Factory for new instance per screen
Future<void> setupRewardsInjection() async {
  // Register API client
  if (!instance.isRegistered<RewardsApiClient>()) {
    instance.registerLazySingleton<RewardsApiClient>(
      () => RewardsApiClient(networkService: instance<NetworkService>()),
    );
  }

  // Register repository
  if (!instance.isRegistered<RewardPrepaidRepository>()) {
    instance.registerLazySingleton<RewardPrepaidRepository>(
      () => RewardPrepaidRepository(apiClient: instance<RewardsApiClient>()),
    );
  }

  // Register cubit as factory (new instance per screen)
  if (!instance.isRegistered<RewardPrepaidCubit>()) {
    instance.registerFactory<RewardPrepaidCubit>(
      () => RewardPrepaidCubit(instance<RewardPrepaidRepository>()),
    );
  }
}
