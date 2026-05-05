import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/core/networkService/app_settings_repository.dart';

class WelcomeData {
  const WelcomeData({
    required this.isLoaded,
    this.mobileImageUrl,
  });

  final bool isLoaded;
  final String? mobileImageUrl;
}

class WelcomeRepository {
  WelcomeRepository({AppSettingsRepository? appSettingsRepository}) : _appSettingsRepository = appSettingsRepository ?? AppSettingsRepository();

  final AppSettingsRepository _appSettingsRepository;

  Future<WelcomeData> loadData() async {
    final mobileImageUrl = await _appSettingsRepository.fetchUrlValue(Api.welcomePageMobileImage);

    return WelcomeData(
      isLoaded: true,
      mobileImageUrl: mobileImageUrl,
    );
  }
}
