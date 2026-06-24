import 'package:core/core.dart';

import 'cubit/alt_number_validation_cubit.dart';
import 'repository/alt_number_validation_repository.dart';
import 'repository/services/alt_number_validation_api_client.dart';

/// DI for the MiFi alt-contact screen.
///
/// Registers the AltNumber validation chain:
/// - API client (singleton)
/// - Repository (singleton)
/// - Cubit (factory — fresh state per screen visit)
Future<void> setupMifiAltContactInjection() async {
  instance.registerLazySingleton<AltNumberValidationApiClient>(
    () => AltNumberValidationApiClient(),
  );

  instance.registerLazySingleton<AltNumberValidationRepository>(
    () => AltNumberValidationRepository(
      apiClient: instance<AltNumberValidationApiClient>(),
    ),
  );

  instance.registerFactory<AltNumberValidationCubit>(
    () => AltNumberValidationCubit(
      repository: instance<AltNumberValidationRepository>(),
    ),
  );
}
