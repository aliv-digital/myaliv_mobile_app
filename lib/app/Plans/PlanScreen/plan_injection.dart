import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/cubit/home_plan_cubit.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/base_plan_repository.dart';
import 'package:myaliv_mobile_app/app/Plans/PlanScreen/repository/home_plan_repository_v2.dart';

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
  // Register repository
  instance.registerLazySingleton<BasePlanRepository>(
    () => HomePlanRepositoryV2(),
  );

  instance.registerLazySingleton<HomePlanCubit>(
    () => HomePlanCubit(instance<BasePlanRepository>()),
  );
}
