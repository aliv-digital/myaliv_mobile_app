import 'package:core/core.dart';

import 'cubit/payment_iframe_cubit.dart';
import 'repository/payment_iframe_repository.dart';
import 'repository/services/payment_iframe_api_service.dart';

/// Registers all payment_iframe dependencies into GetIt.
///
/// Call from the main app's `AppMainInjection.initInjection()`:
/// ```dart
/// await setupPaymentIFrameInjection();
/// ```
///
/// [PaymentIFrameApiService] and [PaymentIFrameRepository] are lazy singletons.
/// [PaymentIFrameCubit] is a **factory** — a fresh instance is created for
/// every payment screen so state never leaks between flows.
Future<void> setupPaymentIFrameInjection() async {
  instance.registerLazySingleton<PaymentIFrameApiService>(
    () => PaymentIFrameApiService(networkService: instance<NetworkService>()),
  );

  instance.registerLazySingleton<PaymentIFrameRepository>(
    () => PaymentIFrameRepositoryImpl(
      apiService: instance<PaymentIFrameApiService>(),
    ),
  );

  instance.registerFactory<PaymentIFrameCubit>(
    () => PaymentIFrameCubit(instance<PaymentIFrameRepository>()),
  );
}
