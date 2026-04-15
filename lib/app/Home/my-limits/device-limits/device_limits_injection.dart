import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/cubit/device_limits_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/repository/device_limits_api_service.dart';
import 'package:myaliv_mobile_app/app/Home/my-limits/device-limits/repository/device_limits_repository.dart';

/// Setup dependency injection for Device Limits feature
///
/// Used for upgrade credit limit screen to pre-populate values.
///
/// Registers:
/// - DeviceLimitsApiService (LazySingleton)
/// - DeviceLimitsRepository (LazySingleton)
/// - DeviceLimitsCubit (LazySingleton)
Future<void> setupDeviceLimitsInjection() async {
  // ========== Services Layer ==========

  instance.registerLazySingleton<DeviceLimitsApiService>(
    () => DeviceLimitsApiService(
      networkService: instance<NetworkService>(),
    ),
  );

  // ========== Repository Layer ==========

  instance.registerLazySingleton<DeviceLimitsRepository>(
    () => DeviceLimitsRepository(
      apiService: instance<DeviceLimitsApiService>(),
    ),
  );

  // ========== State Management Layer ==========

  instance.registerLazySingleton<DeviceLimitsCubit>(
    () => DeviceLimitsCubit(instance<DeviceLimitsRepository>()),
  );
}
