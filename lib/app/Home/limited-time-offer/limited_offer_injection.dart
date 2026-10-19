import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/cubit/limited_offer_cubit.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/repository/limited_offer_repository.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/repository/services/limited_offer_api_service.dart';
import 'package:myaliv_mobile_app/app/Home/limited-time-offer/repository/services/limited_offer_parser_service.dart';

/// Setup dependency injection for Limited Time Offer feature
///
/// Call this function during app initialization to register all
/// services, repositories, and cubits with GetIt.
///
/// Example in main_injection_container.dart:
/// ```dart
/// await setupLimitedOfferInjection();
/// ```
///
/// Registers:
/// - LimitedOfferApiService (LazySingleton)
/// - LimitedOfferParserService (LazySingleton)
/// - LimitedOfferRepository (LazySingleton)
/// - LimitedOfferCubit (Singleton - shared state across app)
Future<void> setupLimitedOfferInjection() async {
  // ========== Services Layer ==========

  // Register API service (handles HTTP calls)
  instance.registerLazySingleton<LimitedOfferApiService>(
    () => LimitedOfferApiService(),
  );

  // Register parser service (handles JSON parsing)
  instance.registerLazySingleton<LimitedOfferParserService>(
    () => LimitedOfferParserService(),
  );

  // ========== Repository Layer ==========

  // Register repository (orchestrates services)
  instance.registerLazySingleton<LimitedOfferRepository>(
    () => LimitedOfferRepositoryImpl(
      apiService: instance<LimitedOfferApiService>(),
      parserService: instance<LimitedOfferParserService>(),
    ),
  );

  // ========== State Management Layer ==========

  // Register cubit as singleton (shared state across app)
  // Use singleton because we want to share the countdown timer and cache
  // across all screens that might display the offer card
  instance.registerLazySingleton<LimitedOfferCubit>(
    () => LimitedOfferCubit(instance<LimitedOfferRepository>()),
  );
}
