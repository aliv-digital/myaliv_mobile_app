import 'package:core/core.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/repository/gift_data_repository.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/repository/services/gift_data_api_client.dart';
import 'package:myaliv_mobile_app/app/Aliv-Mobile/userProfile/giftData/repository/services/gift_data_parser_service.dart';

Future<void> setupGiftDataInjection() async {
  if (!instance.isRegistered<GiftDataApiClient>()) {
    instance.registerLazySingleton<GiftDataApiClient>(
      () => GiftDataApiClient(),
    );
  }
  if (!instance.isRegistered<GiftDataParserService>()) {
    instance.registerLazySingleton<GiftDataParserService>(
      () => GiftDataParserService(),
    );
  }
  if (!instance.isRegistered<GiftDataRepository>()) {
    instance.registerLazySingleton<GiftDataRepository>(
      () => GiftDataRepository(
        apiClient: instance<GiftDataApiClient>(),
        parserService: instance<GiftDataParserService>(),
      ),
    );
  }
}
