import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/cubit/consumption_limit_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/repository/consumption_limit_repository.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/repository/services/consumption_limit_api_service.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/repository/services/consumption_limit_parser_service.dart';

/// Setup dependency injection for Consumption Limit (My Limits) feature
///
/// Call this function during app initialization to register all
/// services, repositories, and cubits with GetIt.
///
/// Example in main_injection_container.dart:
/// ```dart
/// await setupConsumptionLimitInjection();
/// ```
///
/// Registers:
/// - ConsumptionLimitApiService (LazySingleton - uses NetworkService)
/// - ConsumptionLimitParserService (LazySingleton)
/// - ConsumptionLimitRepository (LazySingleton)
/// - ConsumptionLimitCubit (LazySingleton - shared state across app)
Future<void> setupConsumptionLimitInjection() async {
  // ========== Services Layer ==========

  // Register API service (uses NetworkService from core package)
  instance.registerLazySingleton<ConsumptionLimitApiService>(
    () => ConsumptionLimitApiService(
      networkService: instance<NetworkService>(),
    ),
  );

  // Register parser service (handles JSON parsing)
  instance.registerLazySingleton<ConsumptionLimitParserService>(
    () => ConsumptionLimitParserService(),
  );

  // ========== Repository Layer ==========

  // Register repository (orchestrates services)
  instance.registerLazySingleton<ConsumptionLimitRepository>(
    () => ConsumptionLimitRepositoryImpl(
      apiService: instance<ConsumptionLimitApiService>(),
      parserService: instance<ConsumptionLimitParserService>(),
    ),
  );

  // ========== State Management Layer ==========

  // Register cubit as singleton (shared state across app)
  instance.registerLazySingleton<ConsumptionLimitCubit>(
    () => ConsumptionLimitCubit(instance<ConsumptionLimitRepository>()),
  );
}
