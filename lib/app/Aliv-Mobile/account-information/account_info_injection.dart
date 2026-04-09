import 'package:core/core.dart';
import 'cubit/account_info_cubit.dart';
import 'repository/account_info_repository.dart';
import 'repository/services/account_info_api_client.dart';

/// Setup dependency injection for account information feature
///
/// Call this function during app initialization to register
/// the account information cubit and repository with GetIt.
///
/// Example in main.dart:
/// ```dart
/// await setupAccountInfoInjection();
/// ```
Future<void> setupAccountInfoInjection() async {
  // Register API client
  instance.registerLazySingleton<AccountInfoApiClient>(
    () => AccountInfoApiClient(),
  );

  // Register repository
  instance.registerLazySingleton<AccountInfoRepository>(
    () => AccountInfoRepository(
      apiClient: instance<AccountInfoApiClient>(),
    ),
  );

  // Register hydrated cubit as singleton
  // This ensures the same cubit instance is used throughout the app
  instance.registerLazySingleton<AccountInfoCubit>(
    () => AccountInfoCubit(
      repository: instance<AccountInfoRepository>(),
    ),
  );
}
