import 'package:country_picker/country_picker.dart';

class GuestSplashRepository {
  // Splash data load (as you already had)
  Future<bool> loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
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
