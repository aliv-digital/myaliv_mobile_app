import 'package:get_it/get_it.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/cubit/best_plan_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/repository/best_plan_repository.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/repository/services/best_plan_api_service.dart';
import 'package:myaliv_mobile_app/app/Home/best-plans/repository/services/best_plan_parser_service.dart';

final instance = GetIt.instance;

/// Setup dependency injection for Best Plan feature
///
/// Registers:
/// - BestPlanApiService (API layer)
/// - BestPlanParserService (JSON parsing)
/// - BestPlanRepository (business logic)
/// - BestPlanCubit (state management)
///
/// Call this in main_injection_container.dart
Future<void> setupBestPlanInjection() async {
  // API Service
  instance.registerLazySingleton<BestPlanApiService>(
    () => BestPlanApiService(),
  );

  // Parser Service
  instance.registerLazySingleton<BestPlanParserService>(
    () => BestPlanParserService(),
  );

  // Repository
  instance.registerLazySingleton<BestPlanRepository>(
    () => BestPlanRepositoryImpl(
      apiService: instance<BestPlanApiService>(),
      parserService: instance<BestPlanParserService>(),
    ),
  );

  // Cubit
  instance.registerLazySingleton<BestPlanCubit>(
    () => BestPlanCubit(instance<BestPlanRepository>()),
  );
}
