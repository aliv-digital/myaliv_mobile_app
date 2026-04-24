import 'package:core/core.dart';
import 'cubit/saved_cards_cubit.dart';
import 'repository/saved_cards_repository.dart';
import 'repository/services/saved_cards_api_client.dart';

/// Sets up dependency injection for the saved cards feature.
///
/// Registers:
/// - [SavedCardsApiClient] - API client for fetching saved cards
/// - [SavedCardsRepository] - Repository for data operations
/// - [SavedCardsCubit] - State management (singleton)
///
/// Call this in [AppMainInjection.initInjection()].
Future<void> setupSavedCardsInjection() async {
  // Register API client
  instance.registerLazySingleton<SavedCardsApiClient>(
    () => SavedCardsApiClient(),
  );

  // Register repository
  instance.registerLazySingleton<SavedCardsRepository>(
    () => SavedCardsRepositoryImpl(
      apiClient: instance<SavedCardsApiClient>(),
    ),
  );

  // Register cubit as singleton
  instance.registerLazySingleton<SavedCardsCubit>(
    () => SavedCardsCubit(
      repository: instance<SavedCardsRepository>(),
    ),
  );
}
