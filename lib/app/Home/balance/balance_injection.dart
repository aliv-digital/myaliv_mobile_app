import 'package:core/core.dart';
import 'package:get_it/get_it.dart';
import 'package:myaliv_mobile_app/app/Home/balance/cubit/balance_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/balance/repository/balance_repository.dart';
import 'package:myaliv_mobile_app/app/Home/balance/repository/services/balance_api_service.dart';
import 'package:myaliv_mobile_app/app/Home/balance/repository/services/balance_parser_service.dart';

final instance = GetIt.instance;

/// Setup dependency injection for Balance feature
///
/// Registers:
/// - BalanceApiService (API layer with NetworkService)
/// - BalanceParserService (JSON parsing)
/// - BalanceRepository (business logic)
/// - BalanceCubit (state management)
///
/// Call this in main_injection_container.dart
Future<void> setupBalanceInjection() async {
  // API Service (uses NetworkService from core package)
  instance.registerLazySingleton<BalanceApiService>(
    () => BalanceApiService(
      networkService: instance<NetworkService>(),
    ),
  );

  // Parser Service
  instance.registerLazySingleton<BalanceParserService>(
    () => BalanceParserService(),
  );

  // Repository
  instance.registerLazySingleton<BalanceRepository>(
    () => BalanceRepositoryImpl(
      apiService: instance<BalanceApiService>(),
      parserService: instance<BalanceParserService>(),
    ),
  );

  // Cubit
  instance.registerLazySingleton<BalanceCubit>(
    () => BalanceCubit(instance<BalanceRepository>()),
  );
}
