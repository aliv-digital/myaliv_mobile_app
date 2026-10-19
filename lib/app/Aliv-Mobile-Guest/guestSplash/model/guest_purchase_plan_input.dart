class GuestSplashPurchasePlanInput {
  final String countryCode;
  final String dialCode;
  final String phone;
  final String confirmPhone;

  const GuestSplashPurchasePlanInput({
    required this.countryCode,
    required this.dialCode,
    required this.phone,
    required this.confirmPhone,
  });

  String get fullPhone => '+$dialCode$phone';
}
