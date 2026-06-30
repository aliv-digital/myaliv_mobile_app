import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/change_bundle_service.dart';

/// Registers the shared payments service with GetIt.
///
/// Call this once during app bootstrap so any screen can do
/// `instance<ChangeBundleService>()` without further setup.
Future<void> setupPaymentsInjection() async {
  instance.registerLazySingleton<ChangeBundleService>(
    () => ChangeBundleService(),
  );
}
