import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/cubit/account_info_cubit.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/repository/account_info_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/repository/services/account_info_api_client.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/account-information/repository/services/role_api_client.dart';

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
  instance.registerLazySingleton<RoleApiClient>(
    () => RoleApiClient(instance<NetworkService>()),
  );

  // Register API client
  instance.registerLazySingleton<AccountInfoApiClient>(
    () => AccountInfoApiClient(),
  );

  // Register repository
  instance.registerLazySingleton<AccountInfoRepository>(
    () => AccountInfoRepository(apiClient: instance<AccountInfoApiClient>()),
  );

  // Register hydrated cubit as singleton
  // This ensures the same cubit instance is used throughout the app
  instance.registerLazySingleton<AccountInfoCubit>(
    () => AccountInfoCubit(repository: instance<AccountInfoRepository>()),
  );
}
