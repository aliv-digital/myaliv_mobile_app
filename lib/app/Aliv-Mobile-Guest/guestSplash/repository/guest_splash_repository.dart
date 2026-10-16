import 'package:country_picker/country_picker.dart';
import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:myaliv_mobile_app/core/networkService/api_paths.dart';
import 'package:myaliv_mobile_app/core/networkService/app_settings_repository.dart';

class GuestSubscriberInfo {
  final String? accountStatus;
  final String? paymentOption;

  const GuestSubscriberInfo({this.accountStatus, this.paymentOption});

  bool get isActivePrepaid =>
      (accountStatus?.trim().toUpperCase() == 'AC' ||
          accountStatus?.trim().toLowerCase() == 'active') &&
      (paymentOption?.trim().toLowerCase() == 'prepay');
}

class GuestSplashData {
  const GuestSplashData({required this.isLoaded, this.mobileImageUrl});

  final bool isLoaded;
  final String? mobileImageUrl;
}

class GuestSplashRepository {
  GuestSplashRepository({
    AppSettingsRepository? appSettingsRepository,
    NetworkService? networkService,
  }) : _appSettingsRepository =
           appSettingsRepository ?? AppSettingsRepository(),
       _networkService = networkService;

  final AppSettingsRepository _appSettingsRepository;
  final NetworkService? _networkService;

  Future<GuestSubscriberInfo> verifySubscriber(String phoneNumber) async {
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final rawPhone = digits.length == 7 ? '242$digits' : digits;
    final networkService = _networkService ?? instance<NetworkService>();
    final response = await networkService.request<dynamic>(
      Api.guestBalanceUrl,
      method: HttpMethod.post,
      data: <String, dynamic>{
        'ChannelType': 'SelfCare',
        'PhoneNumber': rawPhone,
      },
      options: Options(extra: {'skipAuth': true}),
    );
    final data = response.data;
    if (data is! Map) return const GuestSubscriberInfo();
    final statusRaw = data['AccountStatus'] ?? data['accountStatus'];
    final paymentRaw = data['PaymentOption'] ?? data['paymentOption'];
    return GuestSubscriberInfo(
      accountStatus: statusRaw is String ? statusRaw.trim() : null,
      paymentOption: paymentRaw is String ? paymentRaw.trim() : null,
    );
  }

  Future<GuestSplashData> loadData() async {
    final mobileImageUrl = await _appSettingsRepository.fetchUrlValue(
      Api.guestPageMobileImage,
    );

    return GuestSplashData(isLoaded: true, mobileImageUrl: mobileImageUrl);
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
