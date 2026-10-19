import 'package:country_picker/country_picker.dart';

abstract class GuestSplashEvent {}

class GuestSplashLoaded extends GuestSplashEvent {
  // keep as-is
}

// ✅ Bottom sheet events (সবই GuestSplash prefix)
class GuestSplashPurchasePlanInit extends GuestSplashEvent {
  final Country? initialCountry;
  GuestSplashPurchasePlanInit({this.initialCountry});
}

class GuestSplashPurchasePlanCountryChanged extends GuestSplashEvent {
  final Country country;
  GuestSplashPurchasePlanCountryChanged(this.country);
}

class GuestSplashPurchasePlanPhoneChanged extends GuestSplashEvent {
  final String phone;
  GuestSplashPurchasePlanPhoneChanged(this.phone);
}

class GuestSplashPurchasePlanConfirmPhoneChanged extends GuestSplashEvent {
  final String phone;
  GuestSplashPurchasePlanConfirmPhoneChanged(this.phone);
}

class GuestSplashPurchasePlanSubmitted extends GuestSplashEvent {}

class GuestSplashPurchasePlanReset extends GuestSplashEvent {}
