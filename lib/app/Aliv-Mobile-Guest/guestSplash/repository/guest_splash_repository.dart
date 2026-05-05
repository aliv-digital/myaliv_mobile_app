import 'package:country_picker/country_picker.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/core/networkService/app_settings_repository.dart';

class GuestSplashData {
  const GuestSplashData({
    required this.isLoaded,
    this.mobileImageUrl,
  });

  final bool isLoaded;
  final String? mobileImageUrl;
}

class GuestSplashRepository {
  GuestSplashRepository({AppSettingsRepository? appSettingsRepository}) : _appSettingsRepository = appSettingsRepository ?? AppSettingsRepository();

  final AppSettingsRepository _appSettingsRepository;

  Future<GuestSplashData> loadData() async {
    final mobileImageUrl = await _appSettingsRepository.fetchUrlValue(Api.guestPageMobileImage);

    return GuestSplashData(
      isLoaded: true,
      mobileImageUrl: mobileImageUrl,
    );
  }

  // ✅ Purchase plan validation (optional, reusable)
  // If you want validation to stay in Bloc, you can still keep this for reuse.
  String? validatePurchasePlanInput({
    required Country? country,
    required String phone,
    required String confirmPhone,
  }) {
    final p1 = phone.trim();
    final p2 = confirmPhone.trim();

    if (country == null) return 'Select a country';
    if (p1.isEmpty) return 'Enter mobile number';
    if (p2.isEmpty) return 'Confirm mobile number';
    if (p1 != p2) return 'Numbers do not match';

    return null; // valid
  }
}
