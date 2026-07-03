import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/card_payment_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/change_bundle_service.dart';
import 'package:myaliv_mobile_app/app/common/services/payments/top_up_payment_service.dart';

/// Registers the shared payments services with GetIt.
///
/// Call this once during app bootstrap so any screen can resolve
/// `instance<ChangeBundleService>()` or `instance<TopUpPaymentService>()`
/// without further setup.
Future<void> setupPaymentsInjection() async {
  instance.registerLazySingleton<CardPaymentService>(
    () => CardPaymentService(),
  );
  instance.registerLazySingleton<ChangeBundleService>(
    () => ChangeBundleService(),
  );
  instance.registerLazySingleton<TopUpPaymentService>(
    () => TopUpPaymentService(),
  );
}
