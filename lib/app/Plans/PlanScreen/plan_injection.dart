import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/plans_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/plans_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_api_service.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_cache_service.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_categorizer_service.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_model_factory.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/services/plan_parser_service.dart';

/// Setup dependency injection for plan feature
///
/// Call this function during app initialization to register
/// the plan bloc and repository with GetIt.
///
/// Example in main_injection_container.dart:
/// ```dart
/// await setupPlanInjection();
/// ```
Future<void> setupPlanInjection() async {
  // ========== New Single-Pass Architecture Services ==========

  // Register categorizer service
  instance.registerLazySingleton<PlanCategorizerService>(
    () => PlanCategorizerService(),
  );

  // Register model factory
  instance.registerLazySingleton<PlanModelFactory>(
    () => PlanModelFactory(),
  );

  // Register API service
  instance.registerLazySingleton<PlanApiService>(
    () => PlanApiService(),
  );

  // Register parser service (depends on categorizer and factory)
  instance.registerLazySingleton<PlanParserService>(
    () => PlanParserService(
      categorizer: instance<PlanCategorizerService>(),
      modelFactory: instance<PlanModelFactory>(),
    ),
  );

  // Register cache service
  instance.registerLazySingleton<PlanCacheService>(
    () => PlanCacheService(),
  );

  // Register new PlansRepository
  instance.registerLazySingleton<PlansRepository>(
    () => PlansRepository(
      apiService: instance<PlanApiService>(),
      parserService: instance<PlanParserService>(),
      cacheService: instance<PlanCacheService>(),
    ),
  );

  // Register PlansCubit as singleton (state persists, reset on logout)
  instance.registerLazySingleton<PlansCubit>(
    () => PlansCubit(
      repository: instance<PlansRepository>(),
    ),
  );
}
